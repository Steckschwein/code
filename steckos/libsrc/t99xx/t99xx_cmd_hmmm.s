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

.export vdp_cmd_hmmm, vdp_cmd_lmmm

.import vdp_wait_cmd
.importzp vdp_ptr, vdp_tmp

.code

;@name: vdp_cmd_hmmm
;@desc: execute highspeed memory move (vram/vram)
;@in: A/X - ptr to rectangle coordinates (4 word with x1,y1, len x, len y)
vdp_cmd_hmmm:
              ldy #0

;@name: vdp_cmd_hmmm
;@desc: execute highspeed memory move (vram/vram)
;@in: A/X - ptr to rectangle coordinates (4 word with x1,y1, len x, len y)
;@in: Y - logical operation - IMP (0), AND (1), OR (2), XOR (3), NOT (4) and TIMP (8), TAND (9), ...
vdp_cmd_lmmm:
              php
              sei

              sta vdp_ptr
              stx vdp_ptr+1

              lda #v_reg45_dix | v_reg45_diy    ; initial x left, y up
              sta vdp_tmp

              jsr vdp_wait_cmd

              vdp_sreg 32, v_reg17   ; set reg index to #32

              phy

              ldy #0
:             lda (vdp_ptr),y         ; SX/SY, DX/DY, NX/NY
              vdp_wait_s 12
              sta a_vregi             ; vdp #r32-#43
              iny
              cpy #12
              bne :-

              ldy #1
              lda (vdp_ptr),y ; SX
              ldy #5
              cmp (vdp_ptr),y ; DX
              bcs :+          ; SX<DX => move right
              lda (vdp_ptr)
              dey
              cmp (vdp_ptr),y
              bcs :+
              rmb2 vdp_tmp    ; set DIX bit
:
              stz a_vregi     ; set R#44 0

              ldy #3
              lda (vdp_ptr),y ; SY
              ldy #7
              cmp (vdp_ptr),y ; DY
              bcs :+          ; SY<DY => move down
              ldy #2
              lda (vdp_ptr),y
              ldy #6
              cmp (vdp_ptr),y
              bcs :+
              rmb3 vdp_tmp    ; set DIY bit
:
              lda vdp_tmp
              sta a_vregi     ; R#45 DIX/DIY and memory destination

              pla
              beq :+
              and #$0f
              ora #v_cmd_lmmm
              bne @cmd
:             lda #v_cmd_hmmm

@cmd:         sta a_vregi     ; R#46 cmd

              plp
              rts