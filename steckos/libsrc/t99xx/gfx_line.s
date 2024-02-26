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

.include "debug.inc"

.include "vdp.inc"
.include "gfx.inc"

.import vdp_wait_cmd

.importzp vdp_ptr
.importzp vdp_tmp

.export gfx_line

;@name: gfx_line
;@desc: draw line according to data in given line struct
;@in: A/Y ptr to line_t struct
gfx_line:
      php
      sei

      sta vdp_ptr
      sty vdp_ptr+1

      vdp_sreg 36, v_reg17    ; setup index register, start at r#36

      lda #v_reg45_dix | v_reg45_diy | v_reg45_maj    ; initial x transfer left, y transfer up and y as long side
      sta vdp_tmp

      ; dx
      lda (vdp_ptr)    ; line_t::x1+0
      sta a_vregi             ; vdp #r36
      ldy #line_t::x2+0
      sec
      sbc (vdp_ptr),y
      sta (vdp_ptr),y
      ldy #line_t::x1+1
      lda (vdp_ptr),y
      sta a_vregi             ; vdp #r37
      ldy #line_t::x2+1
      sbc (vdp_ptr),y
      bcs :+                  ; x1>x2 ?

      eor #$ff
      sta (vdp_ptr),y
      rmb2 vdp_tmp     ; x1<x2, x transfer to right, clear bit DIX (v_reg45_dix)
      dey ; ldy #line_t::x2+0
      lda (vdp_ptr),y
      eor #$ff ;two's complement
      ina
:     sta (vdp_ptr),y

      ; dy
      ldy #line_t::y1+0
      lda (vdp_ptr),y
      sta a_vregi             ; vdp #r38
      ldy #line_t::y2+0
      sec
      sbc (vdp_ptr),y
      sta (vdp_ptr),y
      bcs :+                  ; y1>y2 ?
      eor #$ff
      ina
      sta (vdp_ptr),y
      rmb3 vdp_tmp     ; y1<y2, y transfer down, clear bit DIY (v_reg45_diy)

      ; TODO FIXME - hard wired to mode 7 - adjust y offset according to current gfx mode
:     lda #ADDRESS_GFX7_SCREEN>>16
      sta a_vregi             ; vdp #r39

      ; compare |dx| |dy|
      ldy #line_t::x2+0
      lda (vdp_ptr),y
      ldy #line_t::y2+0
      cmp (vdp_ptr),y  ; sets carry for sbc
      ldy #line_t::x2+1
      lda (vdp_ptr),y
      sbc #0  ; y high always 0
      bcc @_y ; C=0 |dx| < |dy|

      rmb0 vdp_tmp     ; clear bit 0 (v_reg45_maj)
@_x:  ldy #line_t::x2+0       ; |dx| is longest
      lda (vdp_ptr),y
      sta a_vregi             ; vdp #r40/42
      iny ; ldy #line_t::x2+1
      lda (vdp_ptr),y
      sta a_vregi             ; vdp #r41/43
      bcc :+
@_y:
      ldy #line_t::y2+0       ; |dy| is longest
      lda (vdp_ptr),y
      sta a_vregi             ; vdp #r40/42
      vdp_wait_s
      stz a_vregi             ; vdp #r41/43  ; y high always 0
      bcc @_x                 ; carry branch magic ;)

:     ldy #line_t::color      ; color
      lda (vdp_ptr),y
      sta a_vregi             ; vdp #r44

      ; meta
      lda vdp_tmp
      vdp_wait_s 3
      sta a_vregi             ; vdp r#45

      iny ; ldy #line_t::operator
      lda (vdp_ptr),y
      and #$0f                ; mask ops
      ora #v_cmd_line
      sta a_vregi             ; r#46 - exec line command

      jsr vdp_wait_cmd

      plp
      rts
