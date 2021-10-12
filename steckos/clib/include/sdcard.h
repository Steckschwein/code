#ifndef _SDCARD_H
#define _SDCARD_H

#include "spi.h"

extern unsigned char __fastcall__ read_block(unsigned char *address, SpiDevice device);

#endif
