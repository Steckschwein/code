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

.globalzp ptr1, ptr2, ptr3, ptr4, ptr5, ptr6
.globalzp tmp1, tmp2, tmp3, tmp4

.globalzp spi_sr
.globalzp vdp_ptr, vdp_tmp
.globalzp __volatile_ptr
.globalzp __volatile_tmp

.globalzp filenameptr, dirptr
.globalzp sd_blkptr

.globalzp cmdptr
.globalzp paramptr
.globalzp flags

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

trampolin	    = $0010

.endif
