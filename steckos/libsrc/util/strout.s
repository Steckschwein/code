; MIT License
;
; Copyright (c) 2023 Thomas Woinke, Marko Lauke, www.steckschein.de
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

.include "zeropage.inc"
.export strout

.import char_out
;.importzp ptr1

.segment "ZEROPAGE_LIB": zeropage
_ptr: .res 2

.code
;----------------------------------------------------------------------------------------------
; Output string on active output device
; in:
;	A - lowbyte  of string address
;	X - highbyte of string address
;----------------------------------------------------------------------------------------------
;.ifdef TEXTUI_STROUT
;strout = textui_strout
;.else
strout:
		sta _ptr		;init for output below
		stx _ptr+1
		pha					  ;save a, y to stack
		phy

		ldy #$00
@l1:	lda (_ptr),y
		beq @l2
		jsr char_out
		iny
		bne @l1

@l2:	ply					  ;restore a, y
		pla
		rts
;.endif