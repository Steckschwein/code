
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <stdint.h>
#include <string.h>
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
};


struct FAT32_VolumeID
{
   uint8_t JmpToBoot[3]; //JMP command to bootstrap code ( in x86-world )
   uint8_t OEMName[8];   //OEM name/version (E.g. "IBM  3.3", "IBM 20.0", "MSDOS5.0", "MSWIN4.0".
                        //Various format utilities leave their own name, like "CH-FOR18".
                        //Sometimes just garbage. Microsoft recommends "MSWIN4.1".)
                        // https://www.win.tue.nl/~aeb/linux/fs/fat/fat-1.html

  // BPB
  uint16_t BytsPerSec; // 11-12  ; 512 usually
  uint8_t  SecPerClus; // 13     ; Sectors per Cluster as power of 2. valid are: 1,2,4,8,16,32,64,128
  uint16_t RsvdSecCnt; //14-15  ; number of reserved sectors
  uint8_t  NumFATs ; // 16     ; usually 2
  uint8_t  Reserved[2]; //17-20 (max root entries, total logical sectors skipped)
  uint16_t Sectors;
  uint8_t  Media; // 21 ; For removable media, 0xF0 is frequently used.
                       // The legal values for this field are
                       // 0xF0, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, and 0xFF.
  uint16_t SectsPerFAT;    // 22-23 ; Number of sectors per FAT. 0 for fat32
  uint16_t SectsPerTrack;    // 24-25 ; Number of sectors per track
  uint16_t NumHeads; // 26
  uint32_t SectsHidden; // 28
  uint32_t TotalSects; // 32 Number of sectors

  // EBPB
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

struct F32FSInfo
{
  uint32_t Signature1;
  uint8_t  Reserved1[0x1e0];
  uint32_t Signature2;
  uint32_t FreeClus; //amount of free clusters
  uint32_t LastClus; //last known cluster number
  uint8_t  Reserved2[11];
  uint16_t Signature;
};

struct F32DirEntry      // https://en.wikipedia.org/wiki/Design_of_the_FAT_file_system
{
  uint8_t Name[8];
  uint8_t Ext[3];
  uint8_t Attr;
  uint8_t Reserved;
  uint8_t CrtTimeMillis;
  uint16_t CrtTime;     // hours as 0-23 bit 15-11, minutes as 0-59 bit 10-5, seconds/2 as 0-29 bit 4-0
  uint16_t CrtDate;     // year 0-119 (0=1980...127=2107) bit 15-9, month 1-12 bit 8-5, day 1-31 bit 4-0
  uint16_t LstModDate;  // -""-
  uint16_t FstClusHI;
  uint16_t WrtTime;     // hours as 0-23 bit 15-11, minutes as 0-59 bit 10-5, seconds/2 as 0-29 bit 4-0
  uint16_t WrtDate;    // year 0-119 (0=1980...127=2107) bit 15-9, month 1-12 bit 8-5, day 1-31 bit 4-0
  uint16_t FstClusLO;
  uint32_t FileSize;
};

uint8_t buf[512];
uint32_t fat[128];

int main (/*int argc, const char* argv[]*/)
{
  char r;
  uint8_t i=0, p=0;
  uint32_t j=0;

  uint16_t RsvdSecCnt;
  uint16_t BytsPerSec;
  uint8_t  SecPerClus;
  uint32_t FSInfoSec;
  uint32_t FATSz32;
  uint32_t TotalSects;


 // uint32_t fat_lba;
  uint32_t free=0;
  uint32_t used=0;


  struct PartitionEntry partitions[4];

  struct Bootsector     * bootsector = (struct Bootsector *)     buf;
  struct FAT32_VolumeID * volid      = (struct FAT32_VolumeID *) buf;
  struct F32FSInfo      * fsinfo     = (struct F32FSInfo *)      buf;

  r = read_block(buf, 0);
  if (r != 0)
  {
    printf("E: %d\n", r);
    return EXIT_FAILURE;
  }

  if (!bootsector->signature[0] == 0x55 || !bootsector->signature[1] == 0xaa)
  {
    printf("Block signature error\n");
    return EXIT_FAILURE;
  }

  memcpy(partitions, bootsector->partition, sizeof(partitions));

  
  printf("Partition table:\n");
  for (i=0; i<=3; i++)
  {
    if (partitions[i].TypeCode == 0)
    {
      continue;
    }
    printf(
      "# Boot Type   LBABegin NumSectors \n%1d %4x  $%02x %10lu %10lu\n", 
      i,
      partitions[i].Bootflag,
      partitions[i].TypeCode,
      partitions[i].LBABegin,
      partitions[i].NumSectors
    );
    p++;
  }
  if (p > 0)
  {
    printf("%d partitions\n", p);
  }
  else
  {
    printf("no partitions\n");
  }
  

  printf("\n");
  r = read_block(buf, partitions[0].LBABegin);
  if (r != 0)
  {
    printf("E: %d\n", r);
    return EXIT_FAILURE;
  }

  RsvdSecCnt = volid->RsvdSecCnt;
  BytsPerSec = volid->BytsPerSec;
  SecPerClus = volid->SecPerClus;
  TotalSects = volid->TotalSects;
  FATSz32    = volid->FATSz32;
  FSInfoSec  = partitions[0].LBABegin + volid->FSInfoSec;

  printf("FS type        : %.*s\n", 8, volid->FSType);
  printf("OEM name       : %.*s\n", 8, volid->OEMName);
  printf("Volume Label   : %.*s\n", 11, volid->VolumeLabel);
  printf("Res. sectors   : %d\n", volid->RsvdSecCnt);
  printf("Bytes/sector   : %d\n", volid->BytsPerSec);
  printf("Sectors/clus.  : %d\n", volid->SecPerClus);
  printf("Cluster size   : %u\n", volid->SecPerClus * volid->BytsPerSec);
  printf("Number of FATs : %d\n", volid->NumFATs);
  printf("Active FAT     : %x\n", volid->MirrorFlags);
  printf("Sectors/FAT    : %lu\n", volid->FATSz32);
  printf("TotalSectors   : %lu\n", TotalSects);
  printf("FSInfoSec      : %lu\n", FSInfoSec);

  r = read_block(buf, FSInfoSec);
  if (r != 0)
  {
    printf("E: %d\n", r);
    return EXIT_FAILURE;
  }

  printf("Free clusters  : %lu\n", fsinfo->FreeClus);
  printf("Last cluster   : %lu\n", fsinfo->LastClus);

  printf("fs bytes       : %lu\n", TotalSects * BytsPerSec);
 
  printf("bytes free     : %lu\n", fsinfo->FreeClus * SecPerClus * BytsPerSec);

  /*
  fat_lba = partitions[0].LBABegin + RsvdSecCnt;

  for(j=0; j<FATSz32; j++)
  {
    r = read_block((uint8_t *)fat, fat_lba);
    if (r != 0)
    {
      printf("E: %d\n", r);
      return EXIT_FAILURE;
    }

    for (i=0;i<128;i++)
    {
      // FAT starts at FAT entry 2 in first block
      // skip first 2 entries
      if (j==0 && i<2)
      {
        continue;
      }

      if (fat[i] == 0)
      {
        free++;
        continue;
      }
      used++;
    }

    fat_lba++;
  }

  printf("Free clusters (counted) : %lu\n", free);
  printf("Used clusters (counted) : %lu\n", used);
*/
  
  return EXIT_SUCCESS;
}