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

;
; int write (int fd, const void* buf, unsigned count);
;
			.include "zeropage.inc"
			.include "errno.inc"

		  .export			_write
		  .constructor	 initstdout

			.import popax,popptr1
			.import	_cputc
			.importzp ptr1
			.importzp tmp1

;--------------------------------------------------------------------------
; initstdout: Open the stdout and stderr file descriptors for the screen.

.segment "ONCE"
.proc	initstdout
	rts
.endproc

;--------------------------------------------------------------------------
.proc   _write 

    pha
    phx
	; count
	sta tmp1 ; 8bit length string only - TODO
	; *buf
	jsr popax
    sta ptr1
    stx ptr1+1    
	; fd
	jsr popax ; assume stdout, ignore fd

    plx
    pla
	cmp #0 ; shortcut, zero length?
    bne @li
    cpx #0
    beq @exit
@li:
    ldy #0
@l0:
	lda (ptr1),y
    beq @exit
    phy
    jsr _cputc
    ply
	iny
	cpy tmp1
	bne @l0
@lex:
    tya
    ldx #0
@exit:
    clc
    rts
.endproc
