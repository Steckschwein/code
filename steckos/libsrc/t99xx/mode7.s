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

.export vdp_mode7_on
.export vdp_mode7_blank
.export vdp_mode7_set_pixel
.export vdp_gfx7_on
.export vdp_gfx7_blank
.export vdp_gfx7_set_pixel
.export vdp_gfx7_set_pixel_cmd
.export vdp_gfx7_set_pixel_direct

.export vdp_wait_cmd

.code
;
;	gfx 7 - each pixel can be addressed - e.g. for image
;
vdp_mode7_on:
vdp_gfx7_on:
			vdp_sreg 0, v_reg23	; reset vertical scroll
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
			.byte Black ; border color
			.byte v_reg8_SPD | v_reg8_VR	; SPD - sprite disabled, VR - 64k VRAM  - R#8
			.byte v_reg9_nt ; #R9, set bit to 1 for PAL
			.byte 0;  #R10
			.byte 0;  #R11
			.byte 0;  #R12
			.byte 0;  #R13
vdp_init_bytes_gfx7_end:
;
; blank gfx mode 7 with
; 	A - color to fill in GRB (3+3+2)
;
vdp_mode7_blank:
vdp_gfx7_blank:
	phx
	php
	sei
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

	plp
	plx
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

;	.X - x coordinate [0..ff]
;	.Y - y coordinate [0..bf]
;	.A - color [0..ff] as GRB 332 (green bit 7-5, red bit 4-2, blue bit 1-0)
; 	VRAM ADDRESS = .X + 256*.Y
vdp_mode7_set_pixel:
vdp_gfx7_set_pixel:
		  php
		  sei
		  stx a_vreg					  ; A7-A0 vram address low byte
		  pha
		  tya
		  and #$3f						 ; A13-A8 vram address highbyte
		  ora #WRITE_ADDRESS
		  nop
		  nop
		  nop
		  nop
		  sta a_vreg
		  tya
		  rol								; A16-A14 bank select via reg#14, rol over carry
		  rol
		  rol
		  and #$03
		  ora #<.HIWORD(ADDRESS_GFX7_SCREEN<<2)
		  nop
		  nop
		  sta a_vreg
		  vdp_wait_s 2
		  lda #v_reg14
		  sta a_vreg
		  vdp_wait_l 2
		  pla
		  sta a_vram					  ; set color
		  plp
		  rts

; requires
;	- int handling is done outside
;	- page register set accordingly (v_reg14)
;	.X - x coordinate [0..ff]
;	.Y - y coordinate [0..bf]
;	.A - color GRB [0..ff] as 332
; 	VRAM ADDRESS = .X + 256*.Y
vdp_gfx7_set_pixel_direct:
		  stx a_vreg					  ; A7-A0 vram address low byte
		  pha
		  tya
		  and #$3f						 ; A13-A8 vram address highbyte
		  ora #WRITE_ADDRESS
		  nop
		  nop
		  nop
		  nop
		  sta a_vreg
		  vdp_wait_l 2
		  pla
		  sta a_vram					  ; set color
		  rts

vdp_wait_cmd:
	 vdp_sreg 2, v_reg15			; 2 - to select status register S#2
@wait:
	 vdp_wait_s 4
	 lda a_vreg
	 ror
	 bcs @wait
	 vdp_sreg 0, v_reg15			; 0 - reset status register selection to S#0
	 rts

;	set pixel to gfx7 using v9958 command engine
;
;	X - x coordinate [0..ff]
;	Y - y coordinate [0..bf]
;	A - color [0..f]
;
; 	VRAM ADDRESS = 8(INT(X DIV 8)) + 256(INT(Y DIV 8)) + (Y MOD 8)
vdp_gfx7_set_pixel_cmd:
		php
		sei
		pha
		vdp_reg 17,36

		vdp_wait_s
		stx a_vregi

		; dummy highbyte
		vdp_wait_s
		stz a_vregi

		vdp_wait_s
		sty a_vregi
		vnops

		; dummy highbyte
		vdp_wait_s 2
		lda #$01
		sta a_vregi

		vdp_wait_s
		vdp_reg 17,44

		pla
		;	colour
		;	GGGRRRBB
		vdp_wait_s 2
		sta a_vregi

		vdp_wait_s 2
		lda #$0
		sta a_vregi

		vdp_wait_s 2
		lda #v_cmd_pset
		sta a_vregi

		vdp_wait_s 4
		jsr vdp_wait_cmd

		plp
		rts
