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

.zeropage

appstart $1000

uart_cpb = $0250

.code

@loop:
      ldy #1
      ldx #$0
@0:   phx
      phy
      jsr reg_dump
      ply
      plx
      dex 
      bne @0
      dey
      bne @0
      
      lda #$1f
;      inc ctrl_port+0     
      lda #$88
      dec ctrl_port+1      
      lda #$14
;      inc ctrl_port+2
      
 ;     dec ctrl_port+3

      jsr reg_dump

      bra @loop

reg_dump:
      lda #KEY_CR
      jsr uart_tx

      jsr primm
      .asciiz " R0:"
      lda ctrl_port+0
      jsr hexout_s
;      jsr uart_tx

      jsr primm
      .asciiz " R1:"
      jsr uart_tx
      lda ctrl_port+1
      jsr hexout_s

      jsr primm
      .asciiz " R2:"
      lda ctrl_port+2
      jsr hexout_s
;      jsr uart_tx

      jsr primm
      .asciiz " R3:"
      lda ctrl_port+3
      jsr hexout_s
;      jsr uart_tx
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
