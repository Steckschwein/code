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

.import vdp_init_reg
.import vdp_fills, vdp_fill
.import vdp_nopslide_8m

.export vdp_gfx1_blank
.export vdp_gfx1_on

.code

vdp_gfx1_blank:		; 3 x 256 bytes
		vdp_vram_w ADDRESS_GFX1_SCREEN
		lda	#' '	 ;fill vram screen with blank
		ldx	#$03	 ;3 pages
		jmp	vdp_fill

vdp_init_bytes_gfx1:
		.byte 0
		.byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size|v_reg1_int
		.byte >(ADDRESS_GFX1_SCREEN>>2) ; name table - value * $1000 (v9958)		R#02
		.byte (ADDRESS_GFX1_COLOR /  $40)	; color table - value * $40 (gfx1), 7f/ff (gfx2)
		.byte (ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM 
		.byte (ADDRESS_GFX1_SPRITE / $80)	; sprite attribute table - value * $80 		--> offset in VRAM
		.byte (ADDRESS_GFX1_SPRITE_PATTERN / $800)  ; sprite pattern table - value * $800  		--> offset in VRAM
		.byte Black
		.byte v_reg8_VR	; VR - 64k VRAM  - R#8
		.byte 0
		.byte 0;  #R10
		.byte 0;  #R11
		.byte 0;  #R12
		.byte 0;  #R13
vdp_init_bytes_gfx1_end:

;
;	gfx mode 1 - 32x24 character mode, 16 colors with same color for 8 characters in a block
;
vdp_gfx1_on:
		tax
		vdp_vram_w ADDRESS_GFX1_COLOR ;color vram
		txa
		ldx #$20		;32 colors
		jsr vdp_fills
		lda #<vdp_init_bytes_gfx1
		ldy #>vdp_init_bytes_gfx1
		ldx #<(vdp_init_bytes_gfx1_end-vdp_init_bytes_gfx1)-1
		jmp vdp_init_reg