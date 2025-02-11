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

static unsigned long byte_cnt_read = 0;
static unsigned long byte_cnt_flashio = 0;
static flash_block flash_block_io;
static unsigned char verify_block[sizeof(((flash_block *)0)->data)];

static unsigned char xmodem_state = 0; // 0 - write, 1 - verify

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

static int verify_flash_block(){

  int r=0;

  flash_block_io.len = byte_cnt_read - byte_cnt_flashio;
  if(flash_block_io.len > 0){
    r = flash_read(&flash_block_io);
    if(r){
      printf("\nRead Error: %d\n", r);
      return r;
    }else{
      byte_cnt_flashio+=flash_block_io.len;
      r = memcmp(&flash_block_io.data, &verify_block, flash_block_io.len);
      printf("Bytes verified: 0x%05lx", byte_cnt_flashio);
      if(r){
        printf("\nFailed (%d) at 0x%05lx, exp: 0x%02x, was: 0x%02x\n", r, flash_block_io.address+r, verify_block[r], flash_block_io.data[r]);
        return r;
      }
      flash_block_io.address+=flash_block_io.len;
    }
  }
  return r;
}

static int write_flash_block(){

  int r=0;

  flash_block_io.len = byte_cnt_read - byte_cnt_flashio;
  if(flash_block_io.len > 0){
    //TODO check whether we already did a sector erase beforehand
    //flash_sector_erase(flash_block_io.address;
    r = flash_write(&flash_block_io);
    if(r){
      printf("\nWrite Error: %d\n", r);
      return r;
    }else{
      byte_cnt_flashio+=flash_block_io.len;
      printf("Bytes written: 0x%05lx", byte_cnt_flashio);
      flash_block_io.address+=flash_block_io.len;
    }
  }
  return 0;
}

static void xmodem_receive_block(xmodem_block *xm_block){

  if(byte_cnt_read == 0){
    printf("\n");
  }
  if(xmodem_state){//verify
    // printf("verify %lu\n", (byte_cnt_read & (sizeof(flash_block_io.data)-1)));
    memcpy(verify_block, xm_block->data, sizeof(xm_block->data));
  }else{//write
    //printf("%lu\n", (byte_cnt_read & (sizeof(flash_block_io.data)-1)));
    memcpy(flash_block_io.data + (byte_cnt_read & (sizeof(flash_block_io.data)-1)), xm_block->data, sizeof(xm_block->data));
  }
  byte_cnt_read+=sizeof(xm_block->data);
  //printf("bn: 0x%02x\n", xm_block->n);
  printf("\rBytes received: 0x%05lx ", byte_cnt_read);

  // write to flash rom if flash write buffer is filled
  if((byte_cnt_read & (sizeof(flash_block_io.data)-1)) == 0){ // buffer full?
    if(xmodem_state){//verify
      verify_flash_block();
    }else{
      //printf("0x%02x %lu\n", xm_block->n, byte_cnt_read);
      write_flash_block();
    }
  }
}

static void erase(unsigned chip_erase){

  int i;

  if(chip_erase){
    printf("\nChip erase...");
    i = flash_chip_erase();
  }else{
    printf("\nSector erase...");
    i = flash_sector_erase(flash_block_io.address);
  }
  if(i){
    printf("FAIL (0x%04x)\n", i);
    doExit(EXIT_FAILURE);
  }
  printDone();
}

int main (int argc, char **argv)
{
    unsigned char opts      = 0;
    unsigned char resetBank = 0;

    int i;

    //flash_block_io.slot = Slot2;
    unsigned long romAddress = 0x010000; //default to sector 1 (sector 0 almost used by current bios)

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
            i = sscanf(optarg+1, "%lx", &romAddress);
          }
          if(!i){
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

    flash_block_io.address = romAddress;  // init with romAddress
    resetBank = 0x80 | romAddress >> 14;  // calculate bank for reset from romAddress

    printf("ROM Type: %s (0x%04x)\n", flash_get_device_name(), flash_get_device_id());
    printf("ROM Address: 0x%05lx\n", flash_block_io.address);
    printf("Image from: %s\n", imageFile == NULL ? "<xmodem upload>" : argv[optind]);
    if(opts & OPT_CHIP_ERASE){
      printf("Chip Erase: y\n");
    }else{
      printf("Sector Erase: 0x%05lx-0x%05lx\n", flash_block_io.address & 0x70000, (flash_block_io.address & 0x70000) + 0xffff);
    }
    printf("Verify: %c\n", (opts & OPT_VERIFY) ? 'y' : 'n');
    printf("Reset: %c (Slot 0x8000/0xc000 with Bank: 0x%02x/0x%02x)\n", (opts & OPT_RESET) ? 'y' : 'n', resetBank, resetBank+1);
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
      while((i = fread(flash_block_io.data, 1, sizeof(flash_block_io.data), imageFile)) != 0){
        byte_cnt_read+=i;
        //TODO check overflow and required sector erase
        printf("\rBytes read: 0x%05lx ", byte_cnt_read);
        if(write_flash_block()){
          doExit(EXIT_FAILURE);
        }
      }
    }
    printDone();

    if(opts & OPT_VERIFY){
      byte_cnt_read = 0;
      byte_cnt_flashio = 0;
      flash_block_io.address = romAddress;  // init with initial romAddress
      if(opts & OPT_UPLOAD){
        printf("ROM Image Verify ");
        xmodem_state = 1; //write
        if(!xmodem_upload(&xmodem_receive_block)){
          if(verify_flash_block()){ // verify remaining bytes
            doExit(EXIT_FAILURE);
          }
        }
      }else if(imageFile && !fseek(imageFile, 0, SEEK_SET)){
        while((i = fread(verify_block, 1, sizeof(verify_block), imageFile)) != 0){
          byte_cnt_read+=i;
          printf("\rBytes read: 0x%05lx ", byte_cnt_read);
          if(verify_flash_block()){
            doExit(EXIT_FAILURE);
          }
        }
      }
      printDone();
    }
    if(imageFile){
      fclose(imageFile);
    }
    if(opts & OPT_RESET){
      printf("Reset...\n");
      sys_slot_ctrl_reset(resetBank, resetBank+1);
    }
    return EXIT_SUCCESS;
}