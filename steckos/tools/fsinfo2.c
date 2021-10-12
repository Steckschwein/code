
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

#include "sdcard.h"

struct PartitionEntry
{
   unsigned char Bootflag;
   unsigned char CHSBegin[3];
   unsigned char TypeCode;
   unsigned char CHSEnd[3];
   unsigned long LBABegin;
   unsigned long NumSectors;
};
struct Bootsector
{
   unsigned char bootcode[446];
   struct PartitionEntry partition[4];
   unsigned char signature[2];
} bootsector;


int main (int argc, const char* argv[])
{
  char r;
  unsigned char i=0;
  r = read_block((unsigned char *)&bootsector, 0);
  if (r != 0)
  {
    return EXIT_FAILURE;
  }

  printf("Bootsector size: $%x\n", sizeof(struct Bootsector));
  printf("Block signature [%02x%02x]\n", bootsector.signature[0], bootsector.signature[1]);

  printf(
    "Bootable [%x]\nTypeCode [$%02x]\nLBABegin [%lu]\nNumSectors [%lu]\n", 
    bootsector.partition[0].Bootflag,
    bootsector.partition[0].TypeCode,
    bootsector.partition[0].LBABegin,
    bootsector.partition[0].NumSectors
  );

  return EXIT_SUCCESS;
}