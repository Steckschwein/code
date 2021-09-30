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
.import vdp_nopslide_2m
.import vdp_nopslide_8m
.import vdp_fill
.import vdp_wait_cmd

.export vdp_mode7_on
.export vdp_mode7_blank

.code
;
;	gfx 7 - each pixel can be addressed - e.g. for image
;
vdp_mode7_on:
vdp_gfx7_on:
			lda #<vdp_init_bytes_gfx7
			ldy #>vdp_init_bytes_gfx7
			ldx #<(vdp_init_bytes_gfx7_end-vdp_init_bytes_gfx7)-1
			jmp vdp_init_reg

vdp_init_bytes_gfx7:
			.byte v_reg0_m5|v_reg0_m4|v_reg0_m3									; reg0 mode bits
			.byte v_reg1_display_on|v_reg1_spr_size |v_reg1_int 				; TODO FIXME verify v_reg1_16k t9929 specific, therefore 0
			.byte >(ADDRESS_GFX7_SCREEN>>3) | $1f	; => 00<A16>1 1111 - entw. bank 0 (offset $0000) or 1 (offset $10000)
			.byte $0
			.byte $0
			.byte $ff
			.byte $3f
			.byte %00000000 ; border color
			.byte v_reg8_SPD | v_reg8_VR	; SPD - sprite disabled, VR - 64k VRAM  - R#8
			.byte v_reg9_nt ; #R9, set bit to 1 for PAL
			.byte 0;  #R10
			.byte 0;  #R11
			.byte 0;  #R12
			.byte 0;  #R13
            .byte <.HIWORD(ADDRESS_GFX7_SCREEN<<2) ; #R14
vdp_init_bytes_gfx7_end:
;
; blank gfx mode 7 with
; 	A - color to fill in GRB (3+3+2)
;
vdp_mode7_blank:
	php
	sei
	phx
	sta colour
	jsr vdp_wait_cmd
;	vdp_vram_w ADDRESS_GFX7_SCREEN
;	vdp_sreg <.HIWORD(ADDRESS_GFX7_SCREEN<<2), v_reg14
;	vdp_sreg <.LOWORD(ADDRESS_GFX7_SCREEN), (WRITE_ADDRESS + >.LOWORD(ADDRESS_GFX7_SCREEN))
	vdp_sreg 36, v_reg17 ; set reg index to #36
	ldx #0
@loop:
	vdp_wait_s 4
	lda data,x
	sta a_vregi
	inx
	cpx #12
	bne @loop
	jsr vdp_wait_cmd

	plx
	plp
	rts

data:
	.word 0 ;x
	.word (ADDRESS_GFX7_SCREEN>>8) ;y - from page offset
	.word 256 ; len x
	.word 212 ; len y
colour:
	.byte %00011100 ; colour
	.byte $00 ; destination memory, x direction, y direction, yada yada
	.byte v_cmd_hmmv ; command
