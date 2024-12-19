// MIT License
//
// Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

#include <xmodem/xmodem.h>
#include <rom/flashrom.h>
#include <steckschwein.h>

#define OPT_CHIP_ERASE 1<<0
#define OPT_UPLOAD     1<<1
#define OPT_VERIFY     1<<2
#define OPT_RESET      1<<3

#define ARGCH    ':'
#define BADCH    '?'
#define ENDARGS  "--"

static FILE *imageFile = NULL;

static unsigned long bt_image = 0;
static unsigned long bt_write = 0;

flash_block flash_wr_block;

static void doExit(int code){
  if(imageFile){
    fclose(imageFile);
  }
  exit(code);
}

static void usage(){
  fprintf(stderr, \
  "Usage: flash_ah [OPTION]... [FILE]\n\
  -a - target address format $????? (default $10000)\n\
  -c - chip erase (defaults to sector erase upon given target address)\n\
  -r - reset after flash\n\
  -u - start xmodem upload\n\
  -v - verify\n\
  -h - this help\n");
  doExit(EXIT_FAILURE);
}

static void printDone(){
  printf(" Done\n");
}

static int write_flash_block(){

  int r;

  flash_wr_block.len = bt_image - bt_write;
  if(flash_wr_block.len > 0){
    //TODO check whether we already did a sector erase beforehand
    //flash_sector_erase(flash_wr_block.address;
    r = flash_write(&flash_wr_block);
    if(r){
      printf("\nWrite Error: %d\n", r);
      return r;
    }else{
      bt_write+=flash_wr_block.len;
      printf("Bytes written: 0x%05lx", bt_write);
      flash_wr_block.address+=flash_wr_block.len;
    }
  }
  return 0;
}

static void xmodem_receive_block(xmodem_block *xm_block){

  if(bt_image == 0){
    printf("\n");
  }
  //printf("%lu\n", (bt_image & (sizeof(flash_wr_block.data)-1)));
  memcpy(flash_wr_block.data + (bt_image & (sizeof(flash_wr_block.data)-1)), xm_block->data, sizeof(xm_block->data));
  bt_image+=sizeof(xm_block->data);
  //printf("bn: 0x%02x\n", xm_block->n);
  printf("\rBytes received: 0x%05lx ", bt_image);

  // write to flash rom if flash write buffer is filled
  if((bt_image & (sizeof(flash_wr_block.data)-1)) == 0){ // buffer full?
    //printf("0x%02x %lu\n", xm_block->n, bt_image);
    write_flash_block();
  }
}

static void erase(unsigned chip_erase){

  int i;

  if(chip_erase){
    printf("\nChip erase...");
    i = flash_chip_erase();
  }else{
    printf("\nSector erase...");
    i = flash_sector_erase(flash_wr_block.address);
  }
  if(i){
    printf("FAIL (0x%04x)\n", i);
    doExit(EXIT_FAILURE);
  }
//  printDone();
  printf(" Done\n");
}

int main (int argc, char **argv)
{
    unsigned char opts      = 0;
    unsigned char resetBank = 0;

    int i;

    //flash_wr_block.slot = Slot2;
    flash_wr_block.address = 0x010000; //default to sector 1 (0 almost used by current bios)

    while ((i = getopt(argc, argv, "uvrhca:")) != EOF) {
      switch (i) {
        case 'c':
          opts |= OPT_CHIP_ERASE;
          break;
        case 'u':
          opts |= OPT_UPLOAD;
          break;
        case 'v':
          opts |= OPT_VERIFY;
          break;
        case 'r':
          opts |= OPT_RESET;
          break;
        case 'a':
          if(*optarg == '$'){
            i = sscanf(optarg+1, "%lx", &flash_wr_block.address);
          }
          if(i){
            printf("address... 0x%06lx\n", flash_wr_block.address);
          }else{
            fprintf(stderr, "invalid address format, expected $????? but was %s\n", optarg);
            usage();
          }
          break;
        case 'h':
        case BADCH:
        default:
          usage();
        }
    }
    if(argc <= 1){
      usage();
    }
    if(optind < argc){
      imageFile = fopen(argv[optind], "rb");
      if(imageFile == NULL){
        fprintf(stderr, "Error (%d): %s - %s\n", errno, argv[optind], strerror(errno));
        doExit(EXIT_FAILURE);
      }
    }
    if(imageFile != NULL && (opts & OPT_UPLOAD)){
      fprintf(stderr, "-u (upload) option given, cannot be used together with a file!\n");
      usage();
    }
    if(imageFile == NULL && !(opts & OPT_UPLOAD)){
      fprintf(stderr, "Either -u (upload) or file must be given!\n");
      usage();
    }

    resetBank = 0x80 | flash_wr_block.address >> 14; // save start address for reset

    printf("ROM Type: %s (0x%04x)\n", flash_get_device_name(), flash_get_device_id());
    printf("ROM Address: 0x%05lx\n", flash_wr_block.address);
    printf("Image from: %s\n", imageFile == NULL ? "<upload>" : argv[optind]);
    if(opts & OPT_CHIP_ERASE){
      printf("Chip Erase: y\n");
    }else{
      printf("Sector Erase: 0x%05lx-0x%05lx\n", flash_wr_block.address & 0x70000, (flash_wr_block.address & 0x70000) + 0xffff);
    }
    printf("Verify: %s\n", (opts & OPT_VERIFY) && imageFile ? "y" : imageFile ? "n" : "n.a.");
    printf("Reset: %s (Slot 0x8000/0xc000 with Bank: 0x%02x/0x%02x)\n", (opts & OPT_RESET) ? "y" : "n", resetBank, resetBank+1);
    printf("\nProcceed Y/n");

    while(!kbhit());
    if(getch() == 'n'){
      doExit(EXIT_SUCCESS);
    }

    erase(opts & OPT_CHIP_ERASE);

    if(opts & OPT_UPLOAD){
      printf("\nROM Image ");
      if(!xmodem_upload(&xmodem_receive_block)){
        write_flash_block(); // write remaining bytes
      }
    }else if(imageFile){
      while((i = fread(flash_wr_block.data, 1, sizeof(flash_wr_block.data), imageFile)) != 0){
        bt_image+=i;
        //TODO check overflow and required sector erase
        printf("\rBytes read: 0x%05lx ", bt_image);
        write_flash_block();
      }
    }
    printDone();
//    printf(" Done\n");
//    printDone();
    if(opts & OPT_VERIFY){
      if(imageFile && !fseek(imageFile, 0, SEEK_SET)){
        bt_image = 0;
        while((i = fread(flash_wr_block.data, 1, sizeof(flash_wr_block.data), imageFile)) != 0){
          bt_image+=i;
          printf("\rVerify: 0x%05lx ", bt_image);
  //            read_flash_block();
        }
      }
      //printf(" Done\n");
      printDone();
      //printDone();
    }
    if(opts & OPT_RESET){
      printf("Reset...\n");
      __asm__("sei");  // critical, disable irq
      sys_slot_set(Slot2, resetBank);
      sys_slot_set(Slot3, resetBank+1);
      sys_reset();
    }
    if(imageFile){
      fclose(imageFile);
    }
    return EXIT_SUCCESS;
}