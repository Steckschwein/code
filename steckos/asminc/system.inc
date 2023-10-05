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
.setcpu "65c02"
.ifndef _SYSTEM_INC_
  _SYSTEM_INC_ = 1

; @see system.s
IRQ_VDP			= 1<<7		; irq from video chip
IRQ_SND			= 1<<6		; irq from sound card (ym3812)
IRQ_VIA			= 1<<5		; irq from VIA (6522)
IRQ_IO0			= 1<<4		; i/o port 0
;...

clockspeed  = 8	; in Mhz

ctrl_port	= $0230

bank0 = ctrl_port+0
bank1 = ctrl_port+1
bank2 = ctrl_port+2
bank3 = ctrl_port+3

CODE_LF  = $0a ; line feed

; address constants of RAM addresses which can be used as buffers or kind of
; !!! ATTENTION: if used together with fat read/write be aware that this buffers are used and may override your data
BUFFER_0 = $0400
BUFFER_1 = BUFFER_0 + $0100
BUFFER_2 = BUFFER_1 + $0100
BUFFER_3 = BUFFER_2 + $0100

SYS_VECTOR_NMI = $fffa
SYS_VECTOR_RESET = $fffc
SYS_VECTOR_IRQ = $fffe

.macro crlf
  lda #CODE_LF		;\n already does the carriage return
  jsr char_out
.endmacro

.macro sys_delay_ms millis
	sys_delay_us (millis * 1000)
.endmacro

.macro sys_delay_us micros
      .local @l1,@l2,@l3
      .assert (micros * clockspeed) >= 0, error, "micros to small!"
      .assert (>.HIWORD(micros * clockspeed)) = 0, error, "micros to large!"
      php
      pha
      phx
      phy
      lda #1+<.HIWORD(micros * clockspeed / 5)
@l1:  ldx #1+>(micros * clockspeed / 5)
@l2:  ldy #1+<(micros * clockspeed / 5) ; ~5cl inner loop
@l3:  dey
      bne @l3
      dex
      bne @l2
      dec
      bne @l1
      ply
      plx
      pla
      plp
.endmacro

.endif
