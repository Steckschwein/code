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

.importzp vdp_tmp

.export vdp_mode4_set_pixel

.code

;@name: vdp_mode4_set_pixel
;@desc: VRAM ADDRESS = X/2 + 128*Y
;@in: X - x coordinate [0..ff]
;@in: Y - y coordinate [0..d3]
;@in. A - color [0..f] from current palette
vdp_mode4_set_pixel:
      php
      sei

      and #$0f
      sta vdp_tmp

      tya
      lsr                   ; Y Bit 0 to carry
      txa
      ror                   ; X/2 OR with Y Bit 0
      sta a_vreg            ; A7-A0 vram address low byte
      pha

      tya
      lsr
      and #$3f              ; A13-A8 vram address highbyte
      ora #WRITE_ADDRESS
      vdp_wait_s 8
      sta a_vreg
      pha

      tya
      clc
      rol                   ; A16-A14 bank select via reg#14, rol over carry
      rol
      and #$03
      ora #<.HIWORD(ADDRESS_GFX4_SCREEN<<2)
      vdp_wait_s 12
      sta a_vreg
      lda #v_reg14
      vdp_wait_s 2
      sta a_vreg

      txa
      and #$01
      tax
      bne :+
      asl vdp_tmp
      asl vdp_tmp
      asl vdp_tmp
      asl vdp_tmp

:     vdp_wait_l 10
      lda a_vram            ; read pixels
      and @mask,x           ; mask pixel
      ora vdp_tmp

      plx
      ply
      sty a_vreg
      vdp_wait_s
      stx a_vreg
      vdp_wait_l
      sta a_vram            ; set color

      plp
      rts
@mask:
  .byte $0f, $f0