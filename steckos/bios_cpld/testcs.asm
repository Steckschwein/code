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
.include "keyboard.inc"
.include "uart.inc"
.include "via.inc"
.include "vdp.inc"
.include "ym3812.inc"
.include "appstart.inc"

.import primm
.import hexout
.import hexout_s

.export char_out=uart_tx

.zeropage

appstart $1000

uart_cpb = $0250

.code

      jsr primm
      .byte KEY_LF, "CS Test",KEY_CR,0
@loop:
      lda #$0f
      sta uart1
      lda uart1

      lda #$f0
      sta a_vdp
      lda a_vdp

      lda #$e7
      sta opl_stat
      lda opl_stat

      lda #$c3
      sta via1
      lda via1

      jsr primm
      .byte "Running...",KEY_CR,0

      bra @loop

uart_tx:
      pha
      lda #lsr_THRE
@l0:
      bit uart_cpb+uart_lsr
      beq @l0

      pla
      sta uart_cpb+uart_rxtx
      rts
