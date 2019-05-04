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
.import vdp_nopslide_8m

.export vdp_gfx6_on, vdp_mode6_on
.export vdp_gfx6_blank
.export vdp_gfx6_set_pixel

.importzp vdp_ptr, vdp_tmp
.code
;
;	gfx 6 - 512x192/212px, 16colors, sprite mode 2
;
vdp_mode6_on:
vdp_gfx6_on:
			lda #<vdp_init_bytes_gfx6
			ldy #>vdp_init_bytes_gfx6
      ldx #<(vdp_init_bytes_gfx6_end-vdp_init_bytes_gfx6)-1
			jmp vdp_init_reg

vdp_init_bytes_gfx6:
			.byte v_reg0_m5|v_reg0_m3												; reg0 mode bits
			.byte v_reg1_display_on|v_reg1_spr_size |v_reg1_int 			; TODO FIXME verify v_reg1_16k t9929 specific, therefore 0
      .byte $7f	; => 0<A16>11 1111 - either bank 0 oder 1 (64k)
			.byte	$0
			.byte $0
      .byte	>(ADDRESS_GFX6_SPRITE<<1) | $07 ; sprite attribute table => $07 -> see V9938_MSX-Video_Technical_Data_Book_Aug85.pdf S.93
			.byte	>(ADDRESS_GFX6_SPRITE_PATTERN>>3);  
			.byte	Black
			.byte v_reg8_VR	; VR - 64k VRAM TODO FIXME aware of max vram (bios)
			.byte 0; NTSC/262, PAL/313 => v_reg9_nt | v_reg9_ln
      .byte 0
      .byte <.hiword(ADDRESS_GFX6_SPRITE<<1); sprite attribute high
vdp_init_bytes_gfx6_end:
;
; blank gfx mode 2 with
; 	A - color to fill (RGB) 3+3+2)
;
vdp_gfx6_blank:		; 64K
  vdp_vram_w ADDRESS_GFX6_SCREEN
  lda #Black<<4|Black
	ldx #192
	jmp vdp_fill

;	set pixel to gfx2 mode screen
;
;	X - x coordinate [0..ff]
;	Y - y coordinate [0..bf]
;	A - color [0..f]
;
; 	VRAM ADDRESS = 8(INT(X DIV 8)) + 256(INT(Y DIV 8)) + (Y MOD 8)
vdp_gfx6_set_pixel:
		beq vdp_gfx6_set_pixel_e	; 0 - not set, leave blank
;		sta tmp1					; otherwise go on and set pixel
		; calculate low byte vram adress
		txa						;2
		and	#$f8
		sta	vdp_tmp
		tya
		and	#$07
		ora	vdp_tmp
		sta	a_vreg	;4 set vdp vram address low byte
		sta	vdp_tmp	;3 safe vram low byte

		; high byte vram address - div 8, result is vram address "page" $0000, $0100, ...
		tya						;2
		lsr						;2
		lsr						;2
		lsr						;2
		sta	a_vreg				;set vdp vram address high byte
		ora #WRITE_ADDRESS		;2 adjust for write
		tay						;2 safe vram high byte for write in y

		txa						;2 set the appropriate bit
		and	#$07				;2
		tax						;2
		lda	bitmask,x			;4
		ora	a_vram				;4 read current byte in vram and OR with new pixel
		tax						;2 or value to x
		nop						;2
		nop						;2
		nop						;2
		lda	vdp_tmp			;2
		sta a_vreg
		tya						;2
		nop						;2
		nop						;2
		sta	a_vreg
		vnops
		stx a_vram	;set vdp vram address high byte
vdp_gfx6_set_pixel_e:
		rts
bitmask:
	.byte $80,$40,$20,$10,$08,$04,$02,$01