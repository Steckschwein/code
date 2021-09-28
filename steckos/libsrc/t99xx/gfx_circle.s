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

; greez fly to https://atariwiki.org/wiki/Wiki.jsp and Super%20fast%20circle%20routine

.include "gfx.inc"
.include "vdp.inc"

.import vdp_wait_cmd

.importzp __volatile_ptr
.importzp __volatile_tmp

.export gfx_circle

; X/Y ptr to circle_t struct
;
gfx_circle:
      php
      sei

      sta __volatile_ptr
      sty __volatile_ptr+1

      ldy #0
      lda (__volatile_ptr),y     ; x low
      STA _XLO
      STA _X1
      iny
      lda (__volatile_ptr),y     ; x high
      STA _X2
      STA _XHI
      iny
      lda (__volatile_ptr),y     ; y
;      TAY
      STA _Y
      ldy #circle_t::radius
      lda (__volatile_ptr),y     ; radius
      BNE NEXT ; R=0 ?
      ldy _Y
      TYA
      jsr PLOT
      plp
      rts
NEXT: STA _B
      dec
      STA _A
      LDY #$0
      STY _C

; -----------------------------
; PLOT X+C,Y+B
; -----------------------------
LOOP: LDA _X1
      CLC
      ADC _C
      STA _XLO
      TYA
      ADC _X2
      STA _XHI
      LDA _Y
      ADC _B
      STA _YVIB
      JSR PLOT
; -----------------------------
; PLOT X+C,Y-B
; -----------------------------
      LDA _Y
      SEC
      SBC _B
      STA _YMAB
      JSR PLOT
; -----------------------------
; PLOT X-C,Y-B
; -----------------------------
      LDA _X1
      SEC
      SBC _C
      STA _XLO
      LDA _X2
      SBC #$0
      STA _XHI
      LDA _YMAB
      JSR PLOT
; -----------------------------
; PLOT X-C,Y+B
; -----------------------------
      LDA _YVIB
      JSR PLOT
; -----------------------------
; PLOT X+B,Y+C
; -----------------------------
      LDA _X1
      CLC
      ADC _B
      STA _XLO
      TYA
      ADC _X2
      STA _XHI
      LDA _Y
      ADC _C
      STA _YVIC
      JSR PLOT
; -----------------------------
; PLOT X+B,Y-C
; -----------------------------
      LDA _Y
      SEC
      SBC _C
      STA _YMAC
      JSR PLOT
; -----------------------------
; PLOT X-B,Y-C
; -----------------------------
      LDA _X1
      SEC
      SBC _B
      STA _XLO
      LDA _X2
      SBC #$0
      STA _XHI
      LDA _YMAC
      JSR PLOT
; -----------------------------
; PLOT X-B,Y+C
; -----------------------------
      LDA _YVIC
      JSR PLOT
; -----------------------------
      INC _C
      LDA _A
      SEC
      SBC _C
      SBC _C
      BPL :+
      DEC _B
      CLC
      ADC _B
      ADC _B
:     STA _A
      LDA _B
      CMP _C
      BMI exit
      jmp LOOP
exit:
      plp
      rts
PLOT:
      tay   ; y low

      vdp_sreg 36, v_reg17 ; start at r#36

      lda _XLO
      sta a_vregi             ; vdp #r36
      lda _XHI
      vdp_wait_s 4
      sta a_vregi             ; vdp #r37

      tya
      vdp_wait_s 2
      sta a_vregi             ; vdp #r38
      ; TODO FIXME - adjust y according to current gfx mode
      lda #ADDRESS_GFX7_SCREEN>>16
      sta a_vregi             ; vdp #r39

      vdp_sreg 44, v_reg17 ; start at r#44

      ldy #circle_t::color
      lda (__volatile_ptr),y
      sta a_vregi             ; vdp r#44
      vdp_wait_s
      stz a_vregi             ; vdp r#45

      vdp_wait_s 2
      lda #v_cmd_pset
      sta a_vregi             ; vdp r#46

      rts
.bss

_X1: .res 1
_X2: .res 1
_XLO: .res 1
_XHI: .res 1
_Y: .res 1
_A: .res 1
_B: .res 1
_C: .res 1
_YMAC: .res 1
_YMAB: .res 1
_YVIC: .res 1
_YVIB: .res 1
