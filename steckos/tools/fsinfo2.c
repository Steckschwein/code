
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <stdint.h>
#include "sdcard.h"

struct PartitionEntry
{
   uint8_t  Bootflag;
   uint8_t  CHSBegin[3];
   uint8_t  TypeCode;
   uint8_t  CHSEnd[3];
   uint32_t LBABegin;
   uint32_t NumSectors;
};
struct Bootsector
{
   uint8_t bootcode[446];
   struct  PartitionEntry partition[4];
   uint8_t signature[2];
} bootsector;

struct EBPB
{

  uint32_t FATSz32; // 36-39 ; sectors per FAT
  uint16_t MirrorFlags; // 40-41; Bits 0-3: number of active FAT (if bit 7 is 1)
                  // Bits 4-6: reserved
                  // Bit 7: one: single active FAT; zero: all FATs are updated at runtime
                  // Bits 8-15: reserved
                  // https://www.win.tue.nl/~aeb/linux/fs/fat/fat-1.html

  uint16_t Version; // 42-43
  uint32_t RootClus; //44-47
  uint16_t FSInfoSec; //48-49
  uint16_t BootSectCpy; // 50-51
  uint8_t  Reserved3[12]; // 52-63
  uint8_t  PhysDrvNum; // 64
  uint8_t  Reserved4; // 65 - bit 7-2 0, bit 0 "dirty flag"
  uint8_t  ExtBootSig ; // 66
  uint32_t VolumeID; // 67-70
  uint8_t  VolumeLabel[11]; // 71-82
  uint8_t  FSType[8]; // 83-90
};

struct BPB
{
  uint16_t BytsPerSec; // 11-12  ; 512 usually
  uint8_t  SecPerClus; // 13     ; Sectors per Cluster as power of 2. valid are: 1,2,4,8,16,32,64,128
  uint16_t RsvdSecCnt; //14-15  ; number of reserved sectors
  uint8_t  NumFATs ; // 16     ; usually 2
  uint8_t  Reserved[4]; //17-20 (max root entries, total logical sectors skipped)
  uint8_t  Media; // 21 ; For removable media, 0xF0 is frequently used.
                       // The legal values for this field are
                       // 0xF0, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, and 0xFF.
  uint16_t SectsPerFAT;    // 22-23 ; Number of sectors per FAT. 0 for fat32

};

struct FAT32_VolumeID
{
   uint8_t JmpToBoot[3]; //JMP command to bootstrap code ( in x86-world )
   uint8_t OEMName[8];   //OEM name/version (E.g. "IBM  3.3", "IBM 20.0", "MSDOS5.0", "MSWIN4.0".
                               //Various format utilities leave their own name, like "CH-FOR18".
                               //Sometimes just garbage. Microsoft recommends "MSWIN4.1".)
                               // https://www.win.tue.nl/~aeb/linux/fs/fat/fat-1.html

   struct  BPB BPB;

   uint8_t Reserved2[12]; //24-35 Placeholder until FAT32 EBPB

   // FAT32 Extended BIOS Parameter Block begins here
   struct  EBPB EBPB;
} volid;

struct F32FSInfo
{
  uint32_t Signature1;
  uint8_t  Reserved1[0x1e0];
  uint32_t Signature2;
  uint32_t FreeClus; //amount of free clusters
  uint32_t LastClus; //last known cluster number
  uint8_t  Reserved2[11];
  uint16_t Signature;
} fsinfo;

uint32_t fat[128];

int main (int argc, const char* argv[])
{
  char r;
  uint8_t i=0;
  uint32_t fat_start;

  r = read_block((uint8_t *)&bootsector, 0);
  if (r != 0)
  {
    printf("E: %d\n", r);
    return EXIT_FAILURE;
  }

  if (!bootsector.signature[0] == 0x55 || !bootsector.signature[1] == 0xaa)
  {
    printf("Block signature error\n");
    return EXIT_FAILURE;
  }

  printf("Partition table:\n");
  for (i=0; i<=3; i++)
  {
    if (bootsector.partition[i] == 0)
    {
      continue;
    }
    printf(
      "# Boot Type   LBABegin NumSectors \n%1d %4x  $%02x %10lu %10lu\n", 
      i,
      bootsector.partition[i].Bootflag,
      bootsector.partition[i].TypeCode,
      bootsector.partition[i].LBABegin,
      bootsector.partition[i].NumSectors
    );
  }

  printf("\n");
  r = read_block((uint8_t *)&volid, bootsector.partition[0].LBABegin);
  if (r != 0)
  {
    printf("E: %d\n", r);
    return EXIT_FAILURE;
  }

  printf("FS type        : %.*s\n", 8, volid.EBPB.FSType);
  printf("OEM name       : %.*s\n", 8, volid.OEMName);
  printf("Volume Label   : %.*s\n", 11, volid.EBPB.VolumeLabel);
  printf("Res. sectors   : %d\n", volid.BPB.RsvdSecCnt);
  printf("Bytes/sector   : %d\n", volid.BPB.BytsPerSec);
  printf("Sectors/clus.  : %d\n", volid.BPB.SecPerClus);
  printf("Cluster size   : %d\n", volid.BPB.SecPerClus * volid.BPB.BytsPerSec);
  printf("Number of FATs : %d\n", volid.BPB.NumFATs);
  printf("Active FAT     : %x\n", volid.EBPB.MirrorFlags);
  printf("FSInfoSec      : %lu\n", bootsector.partition[0].LBABegin + volid.EBPB.FSInfoSec);

  r = read_block((uint8_t *)&fsinfo, bootsector.partition[0].LBABegin + volid.EBPB.FSInfoSec);
  if (r != 0)
  {
    printf("E: %d\n", r);
    return EXIT_FAILURE;
  }

  printf("Free clusters  : %lu\n", fsinfo.FreeClus);
  printf("Last cluster   : %lu\n", fsinfo.LastClus);

  printf("\nFS size        : %lu\n", bootsector.partition[0].NumSectors * volid.BPB.BytsPerSec);
  printf("bytes free     : %lu\n", fsinfo.FreeClus * volid.BPB.SecPerClus * volid.BPB.BytsPerSec);

  // fat_start = bootsector.partition[0].LBABegin + volid.BPB.RsvdSecCnt;
  // r = read_block((uint8_t *)&fat, fat_start);
  // if (r != 0)
  // {
  //   printf("E: %d\n", r);
  //   return EXIT_FAILURE;
  // }

  // for( i=0; i<=128; i++)
  // {
  //   printf("%08x\n", fat[i]);
  // }



  return EXIT_SUCCESS;
}
