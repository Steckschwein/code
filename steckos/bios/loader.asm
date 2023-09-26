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

.import bios_start ; bios.cfg

.zeropage
p_src:		.res 2
p_tgt:		.res 2

appstart $1000
      ; enable RAM
      lda #$02
      sta ctrl_port+2
      lda #$03
      sta ctrl_port+3

      sei

      ldx #$01
      stx ctrl_port+1

      SetVector biosdata, p_src
      SetVector bios_start, p_tgt
      ldy #0
loop:
      lda (p_src),y
      sta (p_tgt),y
      iny
      bne loop
      inc p_src+1
      inc p_tgt+1
      bne loop

      ;reset
      jmp ($fffc)

.data
biosdata:
.incbin "bios.bin"