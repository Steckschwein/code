#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include "include/util/crc7.h"


int main (int args, unsigned char* argv[]){

   unsigned char crc_res;

   if(args <= 1){
      return EXIT_FAILURE;
   }
   crc_res = crc7(argv[1], strlen(argv[1]));

   cprintf("\n crc7 '%s' 0x%x\n", argv[1], crc_res);

   return EXIT_SUCCESS;
}
