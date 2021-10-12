
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
   unsigned int signature[2];
} bootsector;

char r;

int main (int argc, const char* argv[])
{
  r = read_block((unsigned char *)&bootsector, 0);
  if (r != 0)
  {
    return EXIT_FAILURE;
  }

  printf("Block signature [%04x]\n", bootsector.signature);

  printf(
    "Bootable [%d]\nTypeCode [$%02x]\nLBABegin [%d]\nNumSectors [%d]\n", 
    bootsector.partition[0].Bootflag,
    bootsector.partition[0].TypeCode,
    bootsector.partition[0].LBABegin,
    bootsector.partition[0].NumSectors
  );

  return EXIT_SUCCESS;
}