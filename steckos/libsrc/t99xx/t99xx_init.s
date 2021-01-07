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

.export vdp_init_reg

.importzp vdp_ptr

.code
; setup video registers upon given table starting from register #R.X down to #R0
;	in:
;		.X - length of init table, corresponds to start register R#.X
;		.A/.Y - pointer to vdp init table
vdp_init_reg:
    php
    sei
	sta vdp_ptr
	sty vdp_ptr+1
	txa			; x length of init table
	tay
	ora #$80		; bit 7 = 1 => register write
	tax
@l:
	vdp_wait_s 4
	lda (vdp_ptr),y ; 5c
	sta a_vreg
	vdp_wait_s
	stx a_vreg
	dex				;2c
	dey				;2c
	bpl @l 		;3c

.ifdef V9958
	; enable V9958 /WAIT pin
    vdp_sreg 0, v_reg23	; reset vertical scroll
	vdp_sreg v_reg25_wait, v_reg25
.endif

    plp
	rts
