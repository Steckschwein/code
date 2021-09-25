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
		  .export vdp_text_on
		  .export vdp_text_blank
		  .export vdp_text_init_bytes

		  .include "vdp.inc"
		  .include "common.inc"
		  .include "zeropage.inc"

		  .importzp vdp_ptr
		  .import vdp_init_reg
		  .import vdp_fill
		  .import vdp_fills
		  .import vdp_set_reg
		  .import vdp_bgcolor

.ifdef COLS80
	.ifndef V9958
		.assert 0, error, "80 COLUMNS ARE SUPPORTED ON V9958 ONLY! MAKE SURE -DV9958 IS ENABLED"
	.endif
.endif

.code

; blank screen
vdp_text_blank:
		vdp_vram_w ADDRESS_TEXT_SCREEN
		ldx #8
		lda #' '
		jsr vdp_fill
		vdp_vram_w ADDRESS_TEXT_COLOR
		lda #0
		ldx #0
		jmp vdp_fills
;
;	text mode - 40x24/80x24 character mode, 2 colors
;	.A - color settings (#R07)
vdp_text_on:

    php
    sei

	pha ; push color

    lda #<vdp_text_init_bytes
	ldy #>vdp_text_init_bytes
	ldx #(vdp_text_init_bytes_end-vdp_text_init_bytes-1)
	jsr vdp_init_reg

	bit video_mode
	bvc @_mode_40
@_mode_80:
	lda #v_reg0_m4 ; text mode 2, 80 cols ; R#00
	ldy #v_reg0
	jsr vdp_set_reg
	lda #>(ADDRESS_TEXT_SCREEN>>2) | $03	; name table - value * $1000 (v9958)		R#02
	ldy #v_reg2
	jsr vdp_set_reg
@_mode_40:
    lda #VIDEO_MODE_PAL
    tsb video_mode

	pla
	jsr vdp_bgcolor

    plp
    rts

vdp_text_init_bytes:
	.byte 0 ; R#0
	.byte v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1	; #R01
	.byte >(ADDRESS_TEXT_SCREEN>>2) ; name table - value * $1000 (v9958)		#R02
	.byte >(ADDRESS_TEXT_COLOR<<2) | $07	; color table - value * $1000 (v9958)
	.byte >(ADDRESS_TEXT_PATTERN>>3) ; pattern table (charset) - value * $800  	--> offset in VRAM
	.byte 0	; not used
	.byte 0	; not used
	.byte Medium_Green<<4|Black ; #R07
	.byte v_reg8_VR	| v_reg8_SPD ; VR - 64k VRAM TODO FIXME aware of max vram (bios) - #R08
	.byte v_reg9_nt 	; #R9, set bit to 1 for PAL
	.byte <.HIWORD(ADDRESS_TEXT_COLOR<<2)	;#R10
	.byte 0
	.byte Black<<4|Medium_Green ; blink color to inverse text	#R12
	.byte $f0 ; "on time" to max value, per default, means no off time and therefore no blink at all  #R13
    .byte <.HIWORD(ADDRESS_TEXT_SCREEN<<2)
vdp_text_init_bytes_end:
