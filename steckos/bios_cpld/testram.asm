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

.include "common.inc"
.include "system.inc"
.include "appstart.inc"
.include "uart.inc"
.include "keyboard.inc"

.import primm
.import hexout
.import hexout_s

.export char_out=uart_tx

appstart $1000

uart_cpb = $0200
bank_addr = $4000 ; 2nd 16k window is used for testing, we start with RAM address $00000
bank_reg=ctrl_port+1

.code
      sys_delay_ms 1000

      jsr primm
      .byte KEY_LF,"steckschwein 2.0 memory test", KEY_LF, 0
@loop:
      stz bank_reg
      ldx #0
@l0:
      lda pattern,x
      ldy #0            ; fill last page of the 16k ram segments with patterns
@l1:
      sta bank_addr+$0300,y
      sta bank_addr+$0600,y
      sta bank_addr+$0900,y
      sta bank_addr+$2000,y
      sta bank_addr+$2300,y
      sta bank_addr+$2a00,y
      sta bank_addr+$3300,y
      sta bank_addr+$3200,y
      sta bank_addr+$3f00,y

      iny
      bne @l1

      inc bank_reg
      inx
      cpx #(pattern_e-pattern)
      bne @l0

      ; test
      stz bank_reg
      ldx #0
@l2:
      lda #KEY_CR
      jsr uart_tx
      jsr reg_dump

      lda pattern,x
      jsr dump_cpu
      ldy #0
@l3:
      cmp bank_addr+$0300,y
      bne exit_error
      cmp bank_addr+$0600,y
      bne exit_error
      cmp bank_addr+$0900,y
      bne exit_error
      cmp bank_addr+$2000,y
      bne exit_error
      cmp bank_addr+$2300,y
      bne exit_error
      cmp bank_addr+$2a00,y
      bne exit_error
      cmp bank_addr+$3300,y
      bne exit_error
      cmp bank_addr+$3200,y
      bne exit_error
      cmp bank_addr+$3f00,y
      bne exit_error
      iny
      bne @l3

      inc bank_reg
      inx
      cpx #(pattern_e-pattern)
      bne @l2

      jsr primm
      .byte KEY_LF,"success - FTW! ;)",KEY_LF,0

:      bra :-
      jmp @loop

exit_error:
      phy
      phy
      pha
      jsr primm
      .byte KEY_LF, "Error - expect pattern ",0
      pla
      jsr hexout_s
      jsr primm
      .byte " was ",0
      ply
      lda bank_addr,y
      jsr hexout_s
      jsr primm
      .byte " offset ",0
      pla
      jsr hexout_s
      rts

dump_cpu:
      rts
      pha
      lda #' '
      jsr uart_tx
      jsr hexout_s
      txa
      jsr hexout_s
      tya
      jsr hexout_s
      lda #KEY_LF
      jsr uart_tx
      pla
      rts

reg_dump:
      phx
      phy
      jsr primm
      .asciiz " R0:"
      lda ctrl_port+0
      jsr hexout_s

      jsr primm
      .asciiz " R1:"
      jsr uart_tx
      lda ctrl_port+1
      jsr hexout_s

      jsr primm
      .asciiz " R2:"
      lda ctrl_port+2
      jsr hexout_s

      jsr primm
      .asciiz " R3:"
      lda ctrl_port+3
      jsr hexout_s
      ply
      plx
      rts

uart_tx:
      pha
      lda #lsr_THRE
@l0:
      bit uart_cpb+uart_lsr
      beq @l0

      pla
      sta uart_cpb+uart_rxtx
      rts

.data
pattern:
      .byte $f0,$0f,$96,$69,$a9,$9a,$10,$01
      .byte $3c,$c3,$61,$16,$e7,$7e,$81,$18
      .byte $24,$42,$ff,$00,$a7,$7a,$31,$13
      .byte $41,$14,$51,$15,$f3,$3f,$8a,$a8
pattern_e:
