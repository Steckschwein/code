; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
.ifndef _ZEROPAGE_INC_
  _ZEROPAGE_INC_=1

.globalzp ptr1, ptr2 ;, ptr3, ptr4, ptr5, ptr6
; .globalzp tmp1, tmp2, tmp3, tmp4

; .globalzp spi_sr
; .globalzp vdp_ptr, vdp_tmp
; .globalzp __volatile_ptr
;  .globalzp __volatile_tmp

; .globalzp filenameptr, dirptr
; .globalzp read_blkptr, write_blkptr

; .globalzp cmdptr
; .globalzp paramptr
; .globalzp flags

; shell related - TODO FIXME away from kernel stuff, conflicts with basic. but after basic start, we dont care about shell zp. maybe if we want to return to shell one day !!!
cmdptr    = $e0
paramptr  = $e2

; have to use fixed zp locations to avoid ehbasic clashes
vdp_ptr   = $e4
vdp_tmp   = $e6

; FAT32
filenameptr   = $e7  ; 2 byte
dirptr        = $e9  ; 2 byte

; SDCARD/storage block pointer
read_blkptr    = $ed 
write_blkptr   = $ef

; spi shift register location
spi_sr            = $f1
__volatile_ptr    = $f2
__volatile_tmp    = $f4

; flags/signals (like ctrl-c, etc)
flags             = $f5


; lower memory after i/o

.global retvec
.global user_isr

.global lba_addr
.global blocks
.global key

.global crs_ptr
.global crs_x
.global crs_y

.global video_mode

VIDEO_MODE_PAL      = 1<<7
VIDEO_MODE_80_COLS  = 1<<6

.endif

