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

.include "steckos.inc"
.include "vdp.inc"

      .import vdp_bgcolor
      .importzp tmp1

.code

.proc	_main: near
        jsr	krn_textui_disable

        sei
        set_irq isr, save_irq
        vdp_sreg v_reg0_IE1, v_reg0
        cli
@loop:
        keyin
        bcc @loop
        
        sei
        vdp_sreg 0, v_reg15
        vdp_sreg 0, v_reg0
        restore_irq save_irq
        cli
        
        jsr	krn_textui_init
        bit a_vreg ; acknowledge any vdp interrupts before re-enabling interrupts
        jmp (retvec)
.endproc

isr:
  save
  vdp_sreg 0, v_reg15 ; status register 0
  vdp_wait_s
  bit a_vreg  ; v-blank?
  bpl @hblank 
  lda #Cyan
  jsr vdp_bgcolor
  lda #$40
  sta tmp1
  ldy #v_reg19
  vdp_sreg
  bra @black
@hblank:
  vdp_sreg 1, v_reg15 ; status register 1
  vdp_wait_s 4
  lda a_vreg  ; v-blank?
  and #1
  beq @exit
  lda tmp1
  jsr vdp_bgcolor
  inc tmp1
  lda tmp1
  ldy #v_reg19
  vdp_sreg
  bra @exit
@black:
  lda #Black
  jsr vdp_bgcolor
@exit:  
  restore
  rti

.data

.bss
save_irq: .res 2
