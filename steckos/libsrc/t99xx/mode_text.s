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

        .include "vdp.inc"
        .include "common.inc"
        .include "zeropage.inc"

        .importzp vdp_ptr
        .import vdp_init_reg
        .import vdp_fill
        .import vdp_fills

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
;
vdp_text_on:
.ifdef V9958
	vdp_sreg <.HIWORD(ADDRESS_TEXT_SCREEN<<2), v_reg14
	; enable V9958 /WAIT pin
	vdp_sreg v_reg25_wait, v_reg25
.endif
      SetVector vdp_init_bytes_text, vdp_ptr
      ldy #0
      ldx	#v_reg0
      bit max_cols
      bvc @l1
      SetVector vdp_init_bytes_text_80cols, vdp_ptr
@l1:
      lda (vdp_ptr),y
      vdp_wait_s 5
      sta a_vreg
      iny
      vdp_wait_s 2
      stx a_vreg
      inx
      cpy #(vdp_init_bytes_text-vdp_init_bytes_text_80cols)  ; table length below
      bne @l1
      rts

vdp_init_bytes_text_80cols:
      .byte v_reg0_m4 ; text mode 2, 80 cols
      .byte v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
      .byte >(ADDRESS_TEXT_SCREEN>>2) | $03	; name table - value * $1000 (v9958)      R#02
      .byte >(ADDRESS_TEXT_COLOR<<2) | $07	; color table - value * $1000 (v9958)
      .byte >(ADDRESS_TEXT_PATTERN>>3) ; pattern table (charset) - value * $800  	--> offset in VRAM
      .byte	0	; not used
      .byte 0	; not used
      .byte	Medium_Green<<4|Black
      .byte v_reg8_VR	; VR - 64k VRAM TODO FIXME aware of max vram (bios) - #R08
      .byte 0
      .byte <.HIWORD(ADDRESS_TEXT_COLOR<<2)   ;#R10
      .byte 0
      .byte Black<<4|Medium_Green ; blink color to inverse text   #R12
      .byte $f0 ; "on time" to max value, per default, means no off time and therefore no blink at all  #R13
vdp_init_bytes_text:
      .byte	0
      .byte v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
      .byte >(ADDRESS_TEXT_SCREEN>>2) ; name table - value * $1000 (v9958)      R#02
      .byte 0	; not used
      .byte >(ADDRESS_TEXT_PATTERN>>3); pattern table (charset) - value * $800  	--> offset in VRAM
      .byte	0	; not used
      .byte 0	; not used
      .byte	Medium_Green<<4|Black
      .byte v_reg8_VR	; VR - 64k VRAM TODO set per define   ;#R08
      .byte 0 ;#R09
      .byte 0 ;#R10
      .byte 0 ;#R11
      .byte 0 ;#R12
      .byte 0 ;#R13