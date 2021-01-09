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

.export vdp_display_off
.export vdp_bgcolor
.export vdp_nopslide_8m
.export vdp_nopslide_2m
.export vdp_nopslide_end
.export vdp_set_reg, vdp_set_sreg

.code
m_vdp_nopslide

vdp_display_off:
	vdp_sreg v_reg1_16k, v_reg1 	;enable 16K? ram, disable screen
	rts

;
;	input:	a - color
;
vdp_bgcolor:
	ldy #v_reg7
;
; .A/.Y - value / register
vdp_set_sreg:
vdp_set_reg:
	vdp_wait_s 6 ; 6cl already wasted by jsr
	sta a_vreg
	vdp_wait_s
	sty a_vreg
	rts
