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

static void usage(int r){
  FILE* out = stdout;
  if(r == EXIT_FAILURE){
    out = stderr;
  }
  fprintf(out, \
  "Usage: flash_ah [OPTION]... [FILE]\n\
  -u - start xmodem upload\n\
  -a - target address\n\
  -r - reset after flash\n\
  -v - verify\n\
  -h - this help\n");
  exit(r);
}

static void write_flash_block(){

  unsigned r;

  flash_wr_block.len = bt_image - bt_write;
  r = flash_write(&flash_wr_block);
  if(r){
    printf("error %d\n", r);
  }else{
    bt_write+=flash_wr_block.len;
    printf("Bytes written: 0x%05lx", bt_write);
    flash_wr_block.address+=flash_wr_block.len;
  }
}

static void xmodem_receive_block(xmodem_block *xm_block){

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
    FILE *image = NULL;

    int opt;
    unsigned char key;
    unsigned char upload = 0;
    unsigned char doReset = 0;
    unsigned char doVerify = 0;

    int c;
    int i;

    flash_wr_block.slot = Slot2;
    flash_wr_block.address = 0x08000;

    while ((opt = getopt(argc, argv, "uvrha:")) != EOF) {
      switch (opt) {
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
              fprintf(stderr, "invalid address format, expected 0x?????? but was %s\n", optarg);
            }
            break;
        case 'v':
            doVerify = 1;
            break;
        case 'r':
            doReset = 1;
            printf("reset ...\n");
            break;
        case 'h':
            usage(EXIT_SUCCESS);
        case BADCH:
//            fprintf(stderr, "Unknown option: -%c\n", optopt);
        default:
            usage(EXIT_FAILURE);
        }
    }
    if(argc <= 1){
      usage(EXIT_FAILURE);
    }
    if(optind < argc){
      image = fopen(argv[optind], "rb");
      if(image == NULL){
        fprintf(stderr, "Error (%d): %s - %s\n", errno, argv[optind], strerror(errno));
        exit(EXIT_FAILURE);
      }
    }
    if(image != NULL && upload){
      fprintf(stderr, "-u (upload) option given, cannot be used together with a file!\n");
      usage(EXIT_FAILURE);
    }
    if(image == NULL && !upload){
      fprintf(stderr, "Either -u (upload) or file must be given!\n");
      usage(EXIT_FAILURE);
    }

    printf("ROM Type: %s (0x%04x)\n", flash_get_device_name(), flash_get_device_id());
    printf("ROM Address: 0x%05lx\n", flash_wr_block.address);
    printf("Image from: %s\n", image == NULL ? "<upload>" : argv[optind]);
    printf("\nProcceed Y/n");
    key = getch();
    if(key == 0x0d || key == 'y'){
      printf("\nSector Erase for 0x%06lx", flash_wr_block.address);
      flash_sector_erase(&flash_wr_block);
      if(upload){
        printf("\nROM Image ");
        if(!xmodem_upload(&xmodem_receive_block)){
          write_flash_block(); // write remaining bytes TODO FIXME multiple of xmodem data block size (128 byte)
        }
      }else if(image){
        while((i = fread(flash_wr_block.data, 1, sizeof(flash_wr_block.data), image)) != 0){
          bt_image+=i;
          printf("\rBytes read: 0x%05lx ", bt_image);
          write_flash_block();
        }
        fclose(image);
      }
      if(doVerify){

      }

      printf("\nDone\n");
    }

/*
    sys_slot_set(Slot2, 0x98);
    for(i=Slot0;i<=Slot3;i++){
      printf("Slot %d 0x%02x\n", i, sys_slot_get(i));
    }
*/
    if(doReset != 0){
      sys_reset();
    }

    return EXIT_SUCCESS;
}