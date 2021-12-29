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
.include "gfx.inc"

.import vdp_wait_cmd
.import _gfx_prepare_x_y

.importzp __volatile_ptr
.importzp __volatile_tmp

.export gfx_point

; A/Y ptr to point_t struct
;
gfx_point:
      php
      sei

      ldx #32
      jsr _gfx_prepare_x_y
      
      vdp_sreg 0, v_reg45     ; VRAM read
      vdp_sreg v_cmd_point, v_reg46      ; R#46 ; POINT

      jsr vdp_wait_cmd

      vdp_sreg 7, v_reg15	; select status register S#7
      vdp_wait_s
      ldy a_vreg              ; read color value - result to Y
      
      vdp_sreg 0, v_reg15     ; reset status register selection to S#0

      plp
      rts
