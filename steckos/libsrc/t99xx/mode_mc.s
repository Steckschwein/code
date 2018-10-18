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
.import vdp_nopslide_8m
.import vdp_fill

.export vdp_mc_on
.export vdp_mc_blank
.export vdp_mc_set_pixel
.export vdp_mc_init_screen

.code
;
;	gfx multi color mode - 4x4px blocks where each can have one of the 15 colors
;
vdp_mc_on:
			jsr vdp_mc_init_screen
			lda #<vdp_mc_init_bytes
			sta vdp_ptr
			lda #>vdp_mc_init_bytes
			sta vdp_ptr+1
			jmp vdp_init_reg

;
;
;
vdp_mc_init_screen:
			lda #<ADDRESS_GFX_MC_SCREEN
			ldy #WRITE_ADDRESS+ >ADDRESS_GFX_MC_SCREEN
			vdp_sreg
			stz vdp_tmp
			lda #32
			sta vdp_tmp
@l1:		ldy #0
@l2:		ldx vdp_tmp
@l3:		vnops
			stx a_vram
			inx
			cpx vdp_tmp
			bne @l3
			iny
			cpy #4		; 4 rows filled ?
			bne @l2
			cpx #32*6	; 6 pages overall
			beq @le
			stx vdp_tmp	; next
			clc
			txa
			adc #32
			sta vdp_tmp
			bra @l1
@le:		rts

;
; blank multi color mode, set all pixel to black
; 	A - color to blank
;
vdp_mc_blank:
			sta	vdp_tmp
			lda	#<ADDRESS_GFX_MC_PATTERN
			ldy	#WRITE_ADDRESS+ >ADDRESS_GFX_MC_PATTERN
			ldx #(1536/256)
			jmp vdp_fill

;	set pixel to mc screen
;
;	X - x coordinate [0..3f]
;	Y - y coordinate [0..2f]
;	A - color [0..f]
;
; 	VRAM ADDRESS = 8(INT(X DIV 2)) + 256(INT(Y DIV 8)) + (Y MOD 8)
;
; 	TODO FIXME 9929 timing support, should we differentiate ?!? /MLA
;
vdp_mc_set_pixel:
		and #$0f				;only the 16 colors
		sta vdp_tmp				;safe color

		txa
		and #$3e				; x div 2 * 8 => x div 2 * 2 * 2 * 2 => lsr, asl, asl, asl => lsr,asl = and #3e ($3f - x boundary), asl, asl
		asl
		asl
		sta vdp_tmp

		tya
		and	#$07				; y mod 8
		ora	vdp_tmp				; with x
		sta	a_vreg				;4 set vdp vram address low byte
		sta	vdp_tmp				;3 safe vram address low byte for write

		; high byte vram address - div 8, result is vram address "page" $0000, $0100, ... until $05ff
		tya						;2
		lsr						;2
		lsr						;2
		lsr						;2
		sta	a_vreg				;set vdp vram address high byte
		ora #WRITE_ADDRESS		;2 adjust for write
		tay						;2 safe vram high byte for write in y

		txa						;2
		bit #1					;3 test color shift required, upper nibble?
		beq l1					;2/3
		;nop						;2
		vnops
		lda #$f0				;2
		and a_vram				;4
		bra l2					;3
l1:	lda vdp_tmp				;3
		asl						;2
		asl						;2
		asl						;2
		asl						;2
		sta vdp_tmp
		lda #$0f
		and a_vram
l2:
		ora vdp_tmp				;3
		;nop						;2
		;nop						;2
		;nop						;2
        vnops
		ldx vdp_tmp				;3
		stx	a_vreg				;4 setup write adress
		;nop						;2
		;nop						;2
		;nop						;2
		vnops
		sty a_vreg
		vnops
		sta a_vram

		rts

vdp_mc_init_bytes:
			.byte 	0		;
			.byte 	v_reg1_16k|v_reg1_display_on|v_reg1_m2|v_reg1_spr_size;|v_reg1_int
			.byte 	(ADDRESS_GFX_MC_SCREEN / $400)		; name table - value * $400 -> 3 * 256 pattern names (3 pages)
			.byte	$ff									; color table not used in multicolor mode
			.byte	(ADDRESS_GFX_MC_PATTERN / $800) 	; pattern table, 1536 byte - 3 * 256
			.byte	(ADDRESS_GFX_MC_SPRITE / $80)	; sprite attribute table - value * $80 --> offset in VRAM
			.byte	(ADDRESS_GFX_MC_SPRITE_PATTERN / $800)	; sprite pattern table - value * $800  --> offset in VRAM
			.byte	Black
