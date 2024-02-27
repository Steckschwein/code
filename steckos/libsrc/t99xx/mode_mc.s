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

;@module: vdp

.include "vdp.inc"

.import vdp_init_reg
.import vdp_fill

.export vdp_mc_on
.export vdp_mc_blank
.export vdp_mc_init_screen

.importzp vdp_tmp

.code

;@name: vdp_mc_on
;@desc: gfx multi color mode - 4x4px blocks where each can have one of the 15 colors
vdp_mc_on:
      jsr vdp_mc_init_screen
      lda #<@vdp_init_bytes_mc
      ldy #>@vdp_init_bytes_mc
      ldx #<(@vdp_init_bytes_mc_end-@vdp_init_bytes_mc)-1
      jmp vdp_init_reg

@vdp_init_bytes_mc:
      .byte 0;
      .byte v_reg1_16k|v_reg1_display_on|v_reg1_m2|v_reg1_spr_size|v_reg1_int
      .byte >(ADDRESS_GFX_MC_SCREEN>>2) ; name table - value * $400 -> 3 * 256 pattern names (3 pages)
      .byte  $ff                  ; color table not used in multicolor mode
      .byte  >(ADDRESS_GFX_MC_PATTERN>>3)   ; pattern table, 1536 byte - 3 * 256
      .byte >(ADDRESS_GFX_MC_SPRITE<<1) ; sprite attribute table - value * $80 --> offset in VRAM
      .byte  >(ADDRESS_GFX_MC_SPRITE_PATTERN>>3)  ; sprite pattern table - value * $800  --> offset in VRAM
      .byte  Black
      .byte v_reg8_SPD | v_reg8_VR  ; SPD - sprite disabled, VR - 64k VRAM  - R#8
      .byte v_reg9_nt ; #R9, set bit 1 to 1 for PAL
@vdp_init_bytes_mc_end:

;@name: vdp_mc_init_screen
;@desc: init mc screen
vdp_mc_init_screen:
         php
         sei ; critical section vdp access

      vdp_vram_w ADDRESS_GFX_MC_SCREEN
      stz vdp_tmp
      lda #32
      sta vdp_tmp+1
@l1:    ldy #0
@l2:    ldx vdp_tmp
@l3:    vdp_wait_l 6
      stx a_vram
      inx
      cpx vdp_tmp+1
      bne @l3
      iny
      cpy #4    ; 4 rows filled ?
      bne @l2
      cpx #32*6  ; 6 pages overall
      beq @le
      stx vdp_tmp  ; next
      clc
      txa
      adc #32
      sta vdp_tmp+1
      bra @l1
@le:
      plp
      rts


;@name: vdp_mc_blank
;@desc: blank multi color mode, set all pixel to black
;@in: A - color to blank
vdp_mc_blank:
      php
      sei
      vdp_vram_w ADDRESS_GFX_MC_PATTERN
      lda #0
      ldx #(1536/256)
      jsr vdp_fill
      plp
      rts

