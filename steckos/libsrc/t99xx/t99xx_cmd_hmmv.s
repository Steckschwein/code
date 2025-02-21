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

.setcpu "6502"

.export vdp_cmd_hmmv
.export vdp_cmd_hmmv_wait

.import vdp_wait_cmd

.importzp vdp_ptr, vdp_tmp

.code

;@name: vdp_cmd_hmmv_wait - hmmv with wait until cmd has been finished
;@desc: execute highspeed memory move (vdp/vram) or "fill"
;@in: A/X - ptr to rectangle coordinates (4 word with x1,y1, len x, len y)
;@in: Y - color to fill in (reg #44)
vdp_cmd_hmmv_wait:
              php
              sei

              jsr _vdp_cmd_hmmv
              jsr vdp_wait_cmd

              plp
              rts

;@name: vdp_cmd_hmmv
;@desc: execute highspeed memory move (vdp/vram) or "fill"
;@in: A/X - ptr to rectangle coordinates (4 word with x1,y1, len x, len y)
;@in: Y - color to fill in (reg #44)
vdp_cmd_hmmv:
              php
              sei

              jsr _vdp_cmd_hmmv

              plp
              rts

_vdp_cmd_hmmv:
              sta vdp_ptr
              stx vdp_ptr+1

              jsr vdp_wait_cmd        ; previous cmd in execution?

              vdp_sreg 36, v_reg17    ; set reg index to #36

              sty vdp_tmp             ; safe color

              ldy #0
@loop:        vdp_wait_s 9
              lda (vdp_ptr),y
              sta a_vregi
              iny
              cpy #08
              bne @loop

              lda vdp_tmp             ; color (r#44)
              vdp_wait_s 9
              sta a_vregi

              lda #0
              vdp_wait_s 2
              sta a_vregi

              lda #v_cmd_hmmv
              vdp_wait_s 2
              sta a_vregi
              rts
