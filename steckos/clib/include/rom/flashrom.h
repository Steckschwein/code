// MIT License
//
// Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#ifndef _ROM_H
#define _ROM_H

#include <steckschwein.h>

typedef struct {
//  Slot slot;              // write slot to use - TODO not supported yet
  unsigned long address;    // target address
  unsigned char len;        // length of data to write
  unsigned char data[128];  // data to write
} flash_block;

/*
  return 2 byte deviceid - manufacturer, chip device id
*/
extern unsigned int __fastcall__ flash_get_device_id();

/*
  get device name
*/
extern unsigned char* __fastcall__ flash_get_device_name();

/*
  chip erase
*/
extern int __fastcall__ flash_chip_erase();

/*
  erase sector upon the given address
*/
extern int __fastcall__ flash_sector_erase(long address);

/*
  use flash_block to read data from flash ROM
*/
extern int __fastcall__ flash_read(flash_block *);

/*
  use flash_block to write to flash ROM
*/
extern int __fastcall__ flash_write(flash_block*);

#endif
