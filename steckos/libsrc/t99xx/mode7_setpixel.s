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

.export vdp_mode7_set_pixel

.code

;@name: vdp_mode7_set_pixel
;@desc: VRAM ADDRESS = .X + 256*.Y
;@in: X - x coordinate [0..ff]
;@in: Y - y coordinate [0..bf]
;@in. A - color [0..ff] as GRB 332 (green bit 7-5, red bit 4-2, blue bit 1-0)
vdp_mode7_set_pixel:
      php
      sei
      stx a_vreg            ; A7-A0 vram address low byte
      pha
      tya
      and #$3f             ; A13-A8 vram address highbyte
      ora #WRITE_ADDRESS
      nop
      nop
      nop
      nop
      sta a_vreg
      tya
      rol                ; A16-A14 bank select via reg#14, rol over carry
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
      sta a_vram            ; set color
      plp
      rts

;@name: vdp_gfx7_set_pixel_direct
;@desc:
; requires
;  - int handling is done outside
;  - page register set accordingly (v_reg14)
;   VRAM ADDRESS = .X + 256*.Y
;@in: X - x coordinate [0..ff]
;@in: Y - y coordinate [0..bf]
;@in: A - color GRB [0..ff] as 332
vdp_gfx7_set_pixel_direct:
      stx a_vreg            ; A7-A0 vram address low byte
      pha
      tya
      and #$3f             ; A13-A8 vram address highbyte
      ora #WRITE_ADDRESS
      nop
      nop
      nop
      nop
      sta a_vreg
      vdp_wait_l 2
      pla
      sta a_vram            ; set color
      rts
