
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

#include "sdcard.h"

struct PartitionEntry
{
   unsigned char Bootflag;
   unsigned char CHSBegin[3];
   unsigned char TypeCode;
   unsigned char CHSEnd [3];
   unsigned char LBABegin[4];
   unsigned char NumSectors[4];
};
struct Bootsector
{
   unsigned char bootcode[446];
   struct PartitionEntry partition[4];
   unsigned char signature[2];
} bootsector;

char r;

int main (int argc, const char* argv[])
{
  r = read_block((unsigned char *)&bootsector, 0);
  if (r != 0)
  {
    return EXIT_FAILURE;
  }

  printf("%x %x\n", 
    bootsector.signature[0], 
    bootsector.signature[1] 
  );

  printf(
    "[%c] [%x] [%x%x%x%x] [%4x]\n", 
    bootsector.partition[0].Bootflag,
    bootsector.partition[0].TypeCode,
    bootsector.partition[0].LBABegin[0],
    bootsector.partition[0].LBABegin[1],
    bootsector.partition[0].LBABegin[2],
    bootsector.partition[0].LBABegin[3],
    bootsector.partition[0].NumSectors
  );

  return EXIT_SUCCESS;
}