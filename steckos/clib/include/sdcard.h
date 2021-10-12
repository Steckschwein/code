#ifndef _SDCARD_H
#define _SDCARD_H

#include "spi.h"

/*
 * read block at given lba address and stores data to target address
 */
extern unsigned char __fastcall__ read_block(unsigned char *target, unsigned long lba);

#endif
