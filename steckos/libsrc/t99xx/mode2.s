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
.import vdp_fill

.export vdp_mode2_on
.export vdp_mode2_blank

.importzp vdp_ptr, vdp_tmp

.code
;
;	gfx 2 - each pixel can be addressed - e.g. for image
;
vdp_mode2_on:
		lda #<vdp_init_bytes_gfx2
		ldy #>vdp_init_bytes_gfx2
		ldx #<(vdp_init_bytes_gfx2_end-vdp_init_bytes_gfx2)-1
		jsr vdp_init_reg
		jmp vdp_fill_name_table

vdp_fill_name_table:
		;set 768 different patterns --> name table
		vdp_vram_w ADDRESS_GFX2_SCREEN
;        vdp_sreg <ADDRESS_GFX2_SCREEN, WRITE_ADDRESS+ >ADDRESS_GFX2_SCREEN
		ldy #$03
		ldx #$00
@0:	vdp_wait_l 6	;
		stx	a_vram  ;1
		inx			;2
		bne	@0		;3
		dey
		bne	@0
		rts

vdp_init_bytes_gfx2:
			.byte v_reg0_m3		;
			.byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
			.byte (ADDRESS_GFX2_SCREEN / $400)  ; name table - value * $400
			.byte	$ff	  ; color table setting for gfx mode 2 --> only Bit 7 is taken into account 0 => at vram $0000, 1 => at vram $2000, Bit 6-0 AND to character number
			.byte	$03	  ; pattern table - either at vram $0000 (Bit 2 = 0) or at vram $2000 (Bit 2=1), Bit 0,1 are AND to select the pattern array
			.byte	(ADDRESS_GFX2_SPRITE / $80)	; sprite attribute table - value * $80 --> offset in VRAM
			.byte	(ADDRESS_GFX2_SPRITE_PATTERN / $800)	; sprite pattern table - value * $800  --> offset in VRAM
			.byte	Black
	.ifdef V9958
			.byte v_reg8_VR	; VR - 64k VRAM TODO set per define
			.byte v_reg9_nt ; #R9, set bit to 1 for PAL
	.endif
vdp_init_bytes_gfx2_end:

;
; blank gfx mode 2 with
; 	.A - color to fill [0..f]
;
vdp_mode2_blank:		; 2 x 6K
	tax
	vdp_sreg <ADDRESS_GFX2_COLOR, WRITE_ADDRESS + >ADDRESS_GFX2_COLOR
	txa
	ldx #$18		;$1800 byte color map
	jsr vdp_fill

	vdp_sreg <ADDRESS_GFX2_PATTERN, WRITE_ADDRESS + >ADDRESS_GFX2_PATTERN
	ldx #$18		;$1800 byte pattern map
	lda #0
	jsr vdp_fill

	vdp_sreg <ADDRESS_GFX2_SCREEN, WRITE_ADDRESS + >ADDRESS_GFX2_SCREEN
	ldx #3		;768 byte screen map
	lda #0
	jmp vdp_fill
