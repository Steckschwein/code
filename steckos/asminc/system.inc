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
IRQ_VDP       = 1<<7  ; irq from video chip
IRQ_VIA       = 1<<6  ; irq from VIA (6522)
IRQ_SND       = 1<<5  ; irq from sound card (ym3812)
IRQ_RTC       = 1<<4  ; irq from RTC
IRQ_UART      = 1<<3  ; irq from UART

IRQ_IO1       = 1<<1  ; i/o port 1 (card slot 1)
IRQ_IO0       = 1<<0  ; i/o port 0 (card slot 0)

;...

clockspeed  = 8  ; in Mhz

stack = $0100

ctrl_port   = $0230
slot0_ctrl = ctrl_port+0
slot1_ctrl = ctrl_port+1
slot2_ctrl = ctrl_port+2
slot3_ctrl = ctrl_port+3

slot0 = $0000
slot1 = $4000
slot2 = $8000
slot3 = $c000


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

.struct save_status
SLOT0   .byte
SLOT1   .byte
SLOT2   .byte
SLOT3   .byte
ACC     .byte
XREG    .byte
YREG    .byte
SP      .byte
STATUS  .byte
PC      .word
.endstruct


.endif
