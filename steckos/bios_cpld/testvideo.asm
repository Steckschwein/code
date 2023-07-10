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
.autoimport

.export char_out=uart_tx

.zeropage
      _ix: .res 1

appstart $1000

uart_cpb = $0200

.code
      sys_delay_ms 1000

      jsr primm
      .byte KEY_LF,"steckschwein 2.0 video test", KEY_LF,0

@start:
      sei

      stz _ix
:
			jsr vdp_text_on

      lda _ix
      jsr vdp_bgcolor
      jsr hexout_s
      dec _ix
      bne :-
      bra @start

      cli

      jsr primm
      .byte KEY_LF,KEY_LF,"OK",KEY_LF,0
      bra @start

