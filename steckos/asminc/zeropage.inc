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
.globalzp tmp
.globalzp spi_sr
.globalzp vdp_ptr, vdp_tmp

.globalzp crs_ptr

.globalzp krn_ptr1,krn_ptr2, krn_ptr3
.globalzp krn_ptr2, krn_ptr3
.globalzp krn_tmp,krn_tmp2,krn_tmp3

.globalzp filenameptr, dirptr
.globalzp read_blkptr, write_blkptr
.globalzp sd_tmp

.globalzp cmdptr
.globalzp paramptr
.globalzp retvec
.globalzp flags

; custom isr, aligned with v-blank, called by kernel on each frame
user_isr	  = $028a

; TEXTUI
crs_x	= $028c
crs_y	= $028d

key = $0287 ; 1 byte keyboard char

lba_addr 		= $0280		; 4 bytes
blocks			= $0284		; 3 bytes blocks to read, 3 bytes sufficient to address 4GB -> 4294967296 >> 9 = 8388608 ($800000) max blocks/file

VIDEO_MODE_PAL      = 1<<7
VIDEO_MODE_80_COLS  = 1<<6

video_mode 		= $0288 ; video mode register
                ; TODO not implemented/used yet - bit 0-4 - video mode bits - m1-m5 refer to msx spec. - e.g.
                ;   TEXT1 - 00001
                ;   TEXT2 - 01001
                ;   MC    - 00010
                ;   G1    - 00000
                ;   G2    - 00100
                ;   G3    - 01000
                ; bit 6 - text mode with 0 - 40 / 1 - 80 columns
                ; bit 7 - 0 - NTSC / 1 - PAL


trampolin	    = $0010

.endif
