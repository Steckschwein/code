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

.export crc16_table_init
.import crc16_lo, crc16_hi

; Alternate solution is to build the two lookup tables at run-time.  This might
; be desirable if the program is running from ram to reduce binary upload time.
; The following code generates the data for the lookup tables.  You would need to
; un-comment the variable declarations for crc16_lo & crc16_hi in the Tables and Constants
; section above and call this routine to build the tables before calling the
; "xmodem" routine.
;
crc16_table_init:
		ldx #$00
:		stz crc16_lo,x
		stz crc16_hi,x
		inx
		bne	:-
fetch:
    txa
		eor	crc16_hi,x
		sta	crc16_hi,x
		ldy	#$08
fetch1:	asl	crc16_lo,x
		rol	crc16_hi,x
		bcc	fetch2
		lda	crc16_hi,x
		eor	#$10
		sta	crc16_hi,x
		lda	crc16_lo,x
		eor	#$21
		sta	crc16_lo,x
fetch2:	dey
		bne	fetch1
		inx
		bne	fetch
		rts