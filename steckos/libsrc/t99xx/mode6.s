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

.export vdp_mode6_on
.export vdp_mode6_blank

.importzp vdp_ptr, vdp_tmp
.code
;
;	gfx 6 - 512x192/212px, 16colors, sprite mode 2
;
vdp_mode6_on:
		lda #<vdp_init_bytes_gfx6
		ldy #>vdp_init_bytes_gfx6
		ldx #<(vdp_init_bytes_gfx6_end-vdp_init_bytes_gfx6)-1
		jmp vdp_init_reg

vdp_init_bytes_gfx6:
		.byte v_reg0_m5|v_reg0_m3												; reg0 mode bits
		.byte v_reg1_display_on|v_reg1_spr_size |v_reg1_int 			; TODO FIXME verify v_reg1_16k t9929 specific, therefore 0
		.byte $3f	; => 0<A16>11 1111 - either bank 0 oder 1 (64k)
		.byte $0
		.byte $0
		.byte	>(ADDRESS_GFX6_SPRITE<<1) | $07 ; sprite attribute table => $07 -> see V9938_MSX-Video_Technical_Data_Book_Aug85.pdf S.93
		.byte	>(ADDRESS_GFX6_SPRITE_PATTERN>>3);
		.byte	Black
		.byte v_reg8_VR	| v_reg8_SPD; VR - 64k VRAM TODO FIXME aware of max vram (bios)
		.byte 0; NTSC/262, PAL/313 => v_reg9_nt | v_reg9_ln
		.byte 0
		.byte <.hiword(ADDRESS_GFX6_SPRITE<<1); sprite attribute high
		.byte 0;  #R11
		.byte 0;  #R12
		.byte 0;  #R13
vdp_init_bytes_gfx6_end:

;
; blank gfx mode with given color
; 	A - color to fill 4|4 Bit
vdp_mode6_blank:		; 64K
  		tax
  		vdp_vram_w ADDRESS_GFX6_SCREEN
  		txa
		ldx #192
		jmp vdp_fill
