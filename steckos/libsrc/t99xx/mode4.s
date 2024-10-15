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

.setcpu "6502"

.include "vdp.inc"

.autoimport

.export vdp_mode4_on
.export vdp_mode4_blank

.code

;@name: vdp_mode4_on
;@desc: GRAPHIC4 / G4 (MSX SCREEN 5 - https://www.msx.org/wiki/SCREEN_5) - 16 colors from palette, each pixel can be addressed
vdp_mode4_on:
    lda #<@vdp_init_bytes_gfx4
    ldy #>@vdp_init_bytes_gfx4
    ldx #<(@vdp_init_bytes_gfx4_end-@vdp_init_bytes_gfx4)-1
    jmp vdp_init_reg

@vdp_init_bytes_gfx4:
    .byte v_reg0_m4 | v_reg0_m3
    .byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size|v_reg1_int
    .byte >(ADDRESS_GFX4_SCREEN>>2) | $1f  ; name table
    .byte 0 ; n.a.
    .byte 0 ; n.a.
    .byte >(ADDRESS_GFX4_SPRITE<<1) | $07    ; R#5 - sprite attribute table - value * $80 --> offset in VRAM
    .byte >(ADDRESS_GFX4_SPRITE_PATTERN>>3)  ; R#6 - sprite pattern table - value * $800  --> offset in VRAM
    .byte Black
  .ifdef V9958
    .byte v_reg8_VR   ; R#8 - VR - 64k VRAM TODO set per define
    .byte v_reg9_nt   ; R#9 - set bit to 1 for PAL
    .byte 0 ; n.a.
    .byte <.hiword(ADDRESS_GFX4_SPRITE<<1); R#11 sprite attribute high
    .byte 0;  #R12
    .byte 0;  #R13
    .byte <.hiword(ADDRESS_GFX4_SCREEN<<2) ; #R14
  .endif
@vdp_init_bytes_gfx4_end:

;@name: vdp_mode4_blank
;@desc: blank gfx mode 4 with given color in A
;@in: Y - color to fill [0..f]
vdp_mode4_blank:
              lda #<@cmd_hmmv_data
              ldx #>@cmd_hmmv_data
              jmp vdp_cmd_hmmv
@cmd_hmmv_data:
              .word 0 ;x #36/#37
              .word (ADDRESS_GFX4_SCREEN>>7) ;y - from page offset
              .word 256 ; len x #40/#41
              .word 256 ; len y #42/#43

