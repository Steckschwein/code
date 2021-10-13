
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

struct EBPB
{

  unsigned long FATSz32; // 36-39 ; sectors per FAT
  unsigned int  MirrorFlags; // 40-41; Bits 0-3: number of active FAT (if bit 7 is 1)
                  // Bits 4-6: reserved
                  // Bit 7: one: single active FAT; zero: all FATs are updated at runtime
                  // Bits 8-15: reserved
                  // https://www.win.tue.nl/~aeb/linux/fs/fat/fat-1.html

  unsigned int  Version; // 42-43
  unsigned long RootClus; //44-47
  unsigned int  FSInfoSec; //48-49
  unsigned int  BootSectCpy; // 50-51
  unsigned char Reserved3[12]; // 52-63
  unsigned char PhysDrvNum; // 64
  unsigned char Reserved4; // 65 - bit 7-2 0, bit 0 "dirty flag"
  unsigned char ExtBootSig ; // 66
  unsigned long VolumeID; // 67-70
  unsigned char VolumeLabel[11]; // 71-82
  unsigned char FSType[8]; // 83-90
};

struct BPB
{
  unsigned int  BytsPerSec; // 11-12  ; 512 usually
  unsigned char SecPerClus; // 13     ; Sectors per Cluster as power of 2. valid are: 1,2,4,8,16,32,64,128
  unsigned int  RsvdSecCnt; //14-15  ; number of reserved sectors
  unsigned char NumFATs ; // 16     ; usually 2
  unsigned char Reserved[4]; //17-20 (max root entries, total logical sectors skipped)
  unsigned char Media; // 21 ; For removable media, 0xF0 is frequently used.
                       // The legal values for this field are
                       // 0xF0, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, and 0xFF.
  unsigned int SectsPerFAT;    // 22-23 ; Number of sectors per FAT. 0 for fat32

};

struct FAT32_VolumeID
{
   unsigned char JmpToBoot[3]; //JMP command to bootstrap code ( in x86-world )
   unsigned char OEMName[8];   //OEM name/version (E.g. "IBM  3.3", "IBM 20.0", "MSDOS5.0", "MSWIN4.0".
                               //Various format utilities leave their own name, like "CH-FOR18".
                               //Sometimes just garbage. Microsoft recommends "MSWIN4.1".)
                               // https://www.win.tue.nl/~aeb/linux/fs/fat/fat-1.html

   struct BPB BPB;

   unsigned char Reserved2[12]; //24-35 Placeholder until FAT32 EBPB

   // FAT32 Extended BIOS Parameter Block begins here
   struct EBPB EBPB;
} volid;

struct F32FSInfo
{
  unsigned long Signature1;
  unsigned char Reserved1[0x1e0];
  unsigned long Signature2;
  unsigned long FreeClus; //amount of free clusters
  unsigned long LastClus; //last known cluster number
  unsigned char Reserved2[11];
  unsigned int  Signature;
} fsinfo;

int main (int argc, const char* argv[])
{
  char r;
  unsigned char i=0;
  r = read_block((unsigned char *)&bootsector, 0);
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

  printf(
    "Boot Type LBABegin   NumSectors \n[%x] [$%02x][%lu] [%lu]\n", 
    bootsector.partition[0].Bootflag,
    bootsector.partition[0].TypeCode,
    bootsector.partition[0].LBABegin,
    bootsector.partition[0].NumSectors
  );

  r = read_block((unsigned char *)&volid, bootsector.partition[0].LBABegin);
  if (r != 0)
  {
    printf("E: %d\n", r);
    return EXIT_FAILURE;
  }

  printf("FS type        : [%.*s]\n", 8, volid.EBPB.FSType);
  printf("OEM name       : [%.*s]\n", 8, volid.OEMName);
  printf("Volume Label   : [%.*s]\n", 11, volid.EBPB.VolumeLabel);
  printf("Res. sectors   : %d\n", volid.BPB.RsvdSecCnt);
  printf("Bytes/sector   : %d\n", volid.BPB.BytsPerSec);
  printf("Sectors/clus.  : %d\n", volid.BPB.SecPerClus);
  printf("Cluster size   : %d\n", volid.BPB.SecPerClus * volid.BPB.BytsPerSec);
  printf("Number of FATs : %d\n", volid.BPB.NumFATs);
  printf("Active FAT     : %x\n", volid.EBPB.MirrorFlags);
  printf("FSInfoSec      : %lu\n", bootsector.partition[0].LBABegin + volid.EBPB.FSInfoSec);

  r = read_block((unsigned char *)&fsinfo, bootsector.partition[0].LBABegin + volid.EBPB.FSInfoSec);
  if (r != 0)
  {
    printf("E: %d\n", r);
    return EXIT_FAILURE;
  }

  printf("Free clusters  : %lu\n", fsinfo.FreeClus);
  printf("Last cluster   : %lu\n", fsinfo.LastClus);

  printf("\nFS size        : %lu\n", bootsector.partition[0].NumSectors * volid.BPB.BytsPerSec);
  printf("bytes free     : %lu\n", fsinfo.FreeClus * volid.BPB.SecPerClus * volid.BPB.BytsPerSec);

  return EXIT_SUCCESS;
}
