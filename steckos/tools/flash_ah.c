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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

#define ARGCH    ':'
#define BADCH    '?'
#define ENDARGS  "--"

unsigned char buffer[16384];

static void usage(int r, char *prg){
  FILE* out = stdout;
  if(r == EXIT_FAILURE){
    out = stderr;
  }
  fprintf(out, "Usage: %s [-f image file] [-a target address] [-v] [-h]\n", prg);
  exit(r);
}


int main (int argc, char **argv)
{
    int opt;

    unsigned long rom_address=0;
    FILE *image;

    int c,i;

    while ((opt = getopt(argc, argv, "uf:a:vh")) != EOF) {
      switch (opt) {
        case 'u':
            printf("upload...\n");
            break;
        case 'f':
            image = fopen(optarg, "rb");
            if(image == NULL){
              fprintf(stderr, "Error (%d): %s - %s\n", errno, optarg, strerror(errno));
              exit(EXIT_FAILURE);
            }
            break;
        case 'a':
            if(*optarg == '$'){
              i = sscanf(optarg+1, "%lx", &rom_address);
            }
            if(i){
              printf("address... 0x%06lx\n", rom_address);
            }else{
              fprintf(stderr, "invalid address format, expected 0x?????? but was %s\n", optarg);
            }
            break;
        case 'v':
            break;
        case 'r':
            break;
        case 'h':
            usage(EXIT_SUCCESS, argv[0]);
        case BADCH:
            fprintf(stderr, "Unknown option: -%c\n", optopt);
            exit(EXIT_FAILURE);
        default:
            usage(EXIT_FAILURE, argv[0]);
        }
    }
    for (i = optind; i < argc; i++) {
        printf("Non-option argument: %s\n", argv[i]);
    }

    if(image){
      i = fread(buffer, 1, sizeof(buffer), image);
      printf("%0d\n", i);
    }
    fclose(image);

    return EXIT_SUCCESS;
}