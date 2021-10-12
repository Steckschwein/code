
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
   unsigned char LBABegin[4];
   unsigned char NumSectors[4];
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

  printf("Block signature [%02x%02x]\n", bootsector.signature[0], bootsector.signature[1]);

  for (i = 0; i<=3; i++)
  {
    printf(
      "Partition [%d]\n Bootable [%d]\n TypeCode [$%02x]\n LBABegin [%d]\n NumSectors [%d]\n\n", 
      i,
      bootsector.partition[i].Bootflag,
      bootsector.partition[i].TypeCode,
      (long)bootsector.partition[i].LBABegin,
      (long)bootsector.partition[i].NumSectors
    );
  }

  return EXIT_SUCCESS;
}