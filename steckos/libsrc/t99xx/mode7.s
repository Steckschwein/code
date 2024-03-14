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

.autoimport

.export vdp_mode7_on
.export vdp_mode7_blank

.code

;@name: vdp_mode7_on
;@desc: gfx 7 - each pixel can be addressed - e.g. for image
vdp_mode7_on:
      lda #<vdp_init_bytes_gfx7
      ldy #>vdp_init_bytes_gfx7
      ldx #<(vdp_init_bytes_gfx7_end-vdp_init_bytes_gfx7)-1
      jmp vdp_init_reg

vdp_init_bytes_gfx7:
      .byte v_reg0_m5|v_reg0_m4|v_reg0_m3                   ; R#0 reg0 mode bits
      .byte v_reg1_display_on|v_reg1_spr_size|v_reg1_int    ; R#1 TODO FIXME verify v_reg1_16k t9929 specific, therefore 0
      .byte >(ADDRESS_GFX7_SCREEN>>3) | $1f                 ; R#2 => 00<A16>1 1111 - bank 0 (offset $0000) or bank 1 (offset $10000)
      .byte 0
      .byte 0
      .byte >(ADDRESS_GFX7_SPRITE<<1 | $07)   ; sprite attribute table => $07 -> see V9938_MSX-Video_Technical_Data_Book_Aug85.pdf S.93
      .byte >(ADDRESS_GFX7_SPRITE_PATTERN>>3) ;
      .byte %00000000 ; border color
      .byte v_reg8_SPD | v_reg8_VR  ; SPD - sprite disabled, VR - 64k VRAM  - R#8
      .byte v_reg9_nt | v_reg9_ln ; R#9 NTSC/262, PAL/313 => v_reg9_nt | v_reg9_ln (212 lines)
      .byte 0
      .byte >(ADDRESS_GFX7_SPRITE >> 7)
      .byte 0;  #R12
      .byte 0;  #R13
      .byte <.HIWORD(ADDRESS_GFX7_SCREEN<<2 & $07) ; #R14
vdp_init_bytes_gfx7_end:

;@name: vdp_mode7_blank
;@desc: blank gfx mode 7 with
;@in: Y - color to fill in GRB (3+3+2)
vdp_mode7_blank:
  lda #<@cmd_hmmv_data
  ldx #>@cmd_hmmv_data
  jmp vdp_cmd_hmmv

@cmd_hmmv_data:
  .word 0 ;x #36/#37
  .word (ADDRESS_GFX7_SCREEN>>8) ;y - from page offset
  .word 256 ; len x #40/#41
  .word 212 ; len y #42/#43
