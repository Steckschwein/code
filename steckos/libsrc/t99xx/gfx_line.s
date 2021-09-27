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

.importzp __volatile_ptr
.importzp __volatile_tmp

.export gfx_line

; X/Y ptr to line_t struct
;
gfx_line:
      php
      sei

      sta __volatile_ptr
      sty __volatile_ptr+1

      lda #v_reg45_dix | v_reg45_diy | v_reg45_maj; initial x transfer left, y transfer up and y as long side
      sta __volatile_tmp

      vdp_sreg 36, v_reg17 ; start at r#36

      ; dx
;      ldy #line_t::x1+0
      lda (__volatile_ptr)
      sta a_vregi             ; vdp #r36
      ldy #line_t::x2+0
      sec
      sbc (__volatile_ptr),y
      sta (__volatile_ptr),y
      ldy #line_t::x1+1
      lda (__volatile_ptr),y
      sta a_vregi             ; vdp #r37
      ldy #line_t::x2+1
      sbc (__volatile_ptr),y
      bpl :+                  ; x1>x2 ?

      eor #$ff
      sta (__volatile_ptr),y
      lda #v_reg45_dix        ; x1<x2, x transfer to right
      trb __volatile_tmp      ; clear bit
      dey ; ldy #line_t::x2+0
      lda (__volatile_ptr),y
      eor #$ff ;two's complement
      inc
:     sta (__volatile_ptr),y

      ; dy
      ldy #line_t::y1+0
      lda (__volatile_ptr),y
      sta a_vregi             ; vdp #r38
      ldy #line_t::y2+0
      sec
      sbc (__volatile_ptr),y
      sta (__volatile_ptr),y
      ; TODO FIXME - adjust y according to current gfx mode
      lda #ADDRESS_GFX7_SCREEN>>16
      sta a_vregi             ; vdp #r39
      
      ldy #line_t::y1+1
      lda (__volatile_ptr),y
      ldy #line_t::y2+1
      sbc (__volatile_ptr),y
      bpl :+                  ; y1>y2 ?

      eor #$ff
      sta (__volatile_ptr),y
      lda #v_reg45_diy        ; y1<y2, y transfer down
      trb __volatile_tmp      ; clear bit
      dey ; ldy #line_t::y2+0
      lda (__volatile_ptr),y
      eor #$ff ;two's complement
      inc
:     sta (__volatile_ptr),y

      ; compare |dx| |dy|
      ldy #line_t::x2+0
      lda (__volatile_ptr),y
      ldy #line_t::y2+0
      cmp (__volatile_ptr),y  ; set carry for sbc
      ldy #line_t::x2+1
      lda (__volatile_ptr),y
      ldy #line_t::y2+1
      sbc (__volatile_ptr),y
      bcc @_y ; C=0 |dx| < |dy|

      dec __volatile_tmp
@_x:  ldy #line_t::x2+0       ; |dx| is longest
      lda (__volatile_ptr),y
      sta a_vregi             ; vdp #r40/42
      iny ; ldy #line_t::x2+1
      lda (__volatile_ptr),y
      sta a_vregi             ; vdp #r41/43
      bcc :+
@_y:
      ldy #line_t::y2+0       ; |dy| is longest
      lda (__volatile_ptr),y
      sta a_vregi             ; vdp #r40/42
      iny ; ldy #line_t::y2+1
      lda (__volatile_ptr),y
      sta a_vregi             ; vdp #r41/43
      bcc @_x                 ; carry branch magic ;)

:     ; color
      ldy #line_t::color
      lda (__volatile_ptr),y
      sta a_vregi             ; vdp #r44

      ; meta
      lda __volatile_tmp
      vdp_wait_s 3
      sta a_vregi             ; vdp r#45

     	lda #v_cmd_line
      vdp_wait_s 2
     	sta a_vregi             ; r#46 - exec line command

      jsr vdp_wait_cmd

      plp
      rts
      