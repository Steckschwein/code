#include <stdlib.h>
#include <string.h>
#include "include/util/crc7.h"


int main (int args, unsigned char* argv[]){

   unsigned char crc_res;

   if(args <= 0){
      return EXIT_FAILURE;
   }
   crc_res = crc7(argv[0], strlen(argv[0]));

   return EXIT_SUCCESS;
}
