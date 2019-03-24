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
.export vdp_mode3_on

.code
vdp_mode3_on:
      lda #<vdp_init_bytes_mode3
      ldy #>vdp_init_bytes_mode3
      ldx #<(vdp_init_bytes_mode3_end-vdp_init_bytes_mode3)-1
      jmp vdp_init_reg

vdp_init_bytes_mode3:
      .byte v_reg0_m4
      .byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size|v_reg1_int
      .byte (ADDRESS_GFX2_SCREEN / $400)	; name table - value * $400
      .byte	$ff				; color table setting for gfx mode 2 --> only Bit 7 is taken into account 0 => at vram $0000, 1 => at vram $2000, Bit 6-0 AND to character number
      .byte	$03 			; pattern table - either at vram $0000 (Bit 2 = 0) or at vram $2000 (Bit 2=1), Bit 0,1 are AND to select the pattern array
      .byte	(ADDRESS_GFX2_SPRITE / $80)	; sprite attribute table - value * $80 --> offset in VRAM
      .byte	(ADDRESS_GFX2_SPRITE_PATTERN / $800)	; sprite pattern table - value * $800  --> offset in VRAM
      .byte	Black
vdp_init_bytes_mode3_end: