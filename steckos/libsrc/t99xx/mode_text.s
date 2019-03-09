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
.include "common.inc"
.include "zeropage.inc"

.importzp vdp_ptr
.import vdp_init_reg

.export vdp_text_on

.ifdef COLS80
	.ifndef V9958
		.assert 0, error, "80 COLUMNS ARE SUPPORTED ON V9958 ONLY! MAKE SURE -DV9958 IS ENABLED"
	.endif
.endif

.code
;
;	text mode - 40x24/80x24 character mode, 2 colors
;
vdp_text_on:
.ifdef V9958
	vdp_sreg <.HIWORD(ADDRESS_GFX1_SCREEN<<2), v_reg14
	; enable V9958 /WAIT pin
	vdp_sreg v_reg25_wait, v_reg25
.endif
	SetVector vdp_init_bytes_text, vdp_ptr
  bit max_cols
  bvc @l0
  SetVector vdp_init_bytes_text_80cols, vdp_ptr
@l0:  
  ldy #0
	ldx	#v_reg0
@l1:
	lda (vdp_ptr),y
	vdp_wait_s 5
	sta a_vreg
	iny
	vdp_wait_s 2
	stx a_vreg
	inx
	cpy #$08
	bne @l1
	rts

vdp_init_bytes_text_80cols:
	.byte v_reg0_m4 ; text mode 2, 80 cols
	.byte v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
	.byte (ADDRESS_GFX1_SCREEN / $1000)| 1<<1 | 1<<0	; name table - value * $1000 (v9958) --> charset
	.byte 0	; not used
	.byte (ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM
	.byte	0	; not used
	.byte 0	; not used
	.byte	Medium_Green<<4|Black
vdp_init_bytes_text:
	.byte	0
	.byte v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
	.byte (ADDRESS_GFX1_SCREEN / $1000) 	; name table - value * $400					--> charset
	.byte 0	; not used
	.byte (ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM
	.byte	0	; not used
	.byte 0	; not used
	.byte	Medium_Green<<4|Black