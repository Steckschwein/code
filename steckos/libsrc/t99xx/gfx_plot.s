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
.include "gfx.inc"

.import vdp_wait_cmd

.importzp __volatile_ptr
.importzp __volatile_tmp

.export gfx_plot
.export _gfx_prepare_x_y

_gfx_prepare_x_y:

      stx a_vreg

      sta __volatile_ptr
      sty __volatile_ptr+1

      lda #v_reg17
      vdp_wait_s 3+3+2
      sta a_vreg

      ; dx
      lda (__volatile_ptr)    ; plot_t::x1+0
      vdp_wait_s 5
      sta a_vregi             ; vdp R#3X

      ldy #plot_t::x1+1
      lda (__volatile_ptr),y
      sta a_vregi             ; vdp #r3X+1

      ldy #plot_t::y1+0
      lda (__volatile_ptr),y
      sta a_vregi             ; vdp #r3X+2

      lda #ADDRESS_GFX7_SCREEN>>16 ; TODO FIXME - adjust y according to current gfx mode
      vdp_wait_s 2
      sta a_vregi             ; vdp #r3X+3

      rts

;@name: gfx_plot
;@desc: plot pixel
;@in: A/Y - pointer to plot_t struct
gfx_plot:
      php
      sei

      ldx #36                 ; start at r#36
      jsr _gfx_prepare_x_y

      vdp_sreg 44, v_reg17    ; index to r#44

      ldy #plot_t::color
      lda (__volatile_ptr),y
      sta a_vregi             ; vdp r#44 ; color

      ldy #plot_t::operator   ; code re-order to safe wait
      lda (__volatile_ptr),y

      stz a_vregi             ; vdp r#45 ; destination VRAM

      and #$0f                ; mask OPs
      ora #v_cmd_pset
      vdp_wait_s 4
      sta a_vregi             ; vdp r#46 ; PSET and OPs

      jsr vdp_wait_cmd

      plp
      rts
