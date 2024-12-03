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

#define ARGCH    ':'
#define BADCH    '?'
#define ENDARGS  "--"

static unsigned long bt_image = 0;
static unsigned long bt_write = 0;

static flash_block flash_wr_block;

static void usage(){
  fprintf(stderr, \
  "Usage: flash_ah [OPTION]... [FILE]\n\
  -u - start xmodem upload\n\
  -a - target address, format $?????\n\
  -r - reset after flash\n\
  -v - verify\n\
  -h - this help\n");
  exit(EXIT_FAILURE);
}

static void write_flash_block(){

  unsigned r;

  flash_wr_block.len = bt_image - bt_write;
  if(flash_wr_block.len > 0){
    //TODO check whether we already did a sector erase beforehand
    //flash_sector_erase(flash_wr_block.address;
    r = flash_write(&flash_wr_block);
    if(r){
      printf("\nWrite rom error %d\n", r);
    }else{
      bt_write+=flash_wr_block.len;
      printf("Bytes written: 0x%05lx", bt_write);
      flash_wr_block.address+=flash_wr_block.len;
    }
  }
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

int main (int argc, char **argv)
{
    FILE *imageFile = NULL;

    unsigned char upload = 0;
    unsigned char doReset = 0;
    unsigned char doVerify = 0;
    unsigned char resetBank = 0;
    int i;

    //flash_wr_block.slot = Slot2;
    flash_wr_block.address = 0x010000; //default to sector 1 (0 almost used by current bios)

    while ((i = getopt(argc, argv, "uvrha:")) != EOF) {
      switch (i) {
        case 'u':
            upload = 1;
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
        case 'v':
            doVerify = 1;
            break;
        case 'r':
            doReset = 1;
            break;
        case 'h':
            usage();
        case BADCH:
//            fprintf(stderr, "Unknown option: -%c\n", optopt);
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
        exit(EXIT_FAILURE);
      }
    }
    if(imageFile != NULL && upload){
      fprintf(stderr, "-u (upload) option given, cannot be used together with a file!\n");
      usage();
    }
    if(imageFile == NULL && !upload){
      fprintf(stderr, "Either -u (upload) or file must be given!\n");
      usage();
    }

    resetBank = 0x80 | flash_wr_block.address >> 14; // save start address for reset

    printf("ROM Type: %s (0x%04x)\n", flash_get_device_name(), flash_get_device_id());
    printf("ROM Address: 0x%05lx\n", flash_wr_block.address);
    printf("Image from: %s\n", imageFile == NULL ? "<upload>" : argv[optind]);
    printf("Sector Erase: 0x%05lx-0x%05lx\n", flash_wr_block.address & 0x70000, (flash_wr_block.address & 0x70000) + 0xffff);
    printf("Verify: %s\n", doVerify && imageFile ? "y" : imageFile ? "n" : "n.a.");
    printf("Reset: %s (Slot 0x8000/0xc000 with Bank: 0x%02x/0x%02x)\n", doReset ? "y" : "n", resetBank, resetBank+1);
    printf("\nProcceed Y/n");

    while(!kbhit());
    if(getch() == 'n'){
      return EXIT_SUCCESS;
    }
    printf("\nSector erase... ");
    i = flash_sector_erase(flash_wr_block.address);
    if(i){
      printf("FAIL (0x%04x)\n", i);
      exit(EXIT_FAILURE);
    }else{
      printf("OK\n");
    }
    if(upload){
      printf("\nROM Image ");
      if(!xmodem_upload(&xmodem_receive_block)){
        write_flash_block();
      }
    }else if(imageFile){
      while((i = fread(flash_wr_block.data, 1, sizeof(flash_wr_block.data), imageFile)) != 0){
        bt_image+=i;
        //TODO check overflow and required sector erase
        printf("\rBytes read: 0x%05lx ", bt_image);
        write_flash_block();
      }
      fclose(imageFile);
    }
    printf("\nDone\n");
    if(doVerify){
      printf("Verify...\n");
    }
    if(doReset){
      printf("Reset...\n");
      __asm__("sei");  // critical, disable irq
      sys_slot_set(Slot2, resetBank);
      sys_slot_set(Slot3, resetBank+1);
      sys_reset();
    }

    return EXIT_SUCCESS;
}