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

.include "vdp.inc"

.export vdp_cmd_hmmv

.import vdp_wait_cmd

.importzp vdp_ptr

.code
;
; execure highspeed memory move (vdp/vram) or "fill"
;	A/X - ptr to rectangle coordinates (4 word with x1,y1, len x, len y)
; 	Y - color to fill in (reg #44)
vdp_cmd_hmmv:
	php
	sei

	sta vdp_ptr
	stx vdp_ptr+1

	vdp_sreg 36, v_reg17 	; set reg index to #36

	phy						; safe color

	ldy #0
@loop:
	vdp_wait_s 5
	lda (vdp_ptr),y
	sta a_vregi
	iny
	cpy #08
	bne @loop
	
	pla 					; color (r#44)
	sta a_vregi				

	vdp_wait_s 2
	lda #0
	sta a_vregi

	vdp_wait_s 2
	lda #v_cmd_hmmv
	sta a_vregi

	jsr vdp_wait_cmd
	plp
	rts