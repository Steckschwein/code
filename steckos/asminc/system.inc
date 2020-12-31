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

ROM_OFF = 1<<0
BANK_SEL0 = 1<<1
BANK_SEL1 = 1<<2
BANK0 = 0
BANK1 = BANK_SEL0
BANK2 = BANK_SEL1
BANK3 = BANK_SEL1 | BANK_SEL0

CODE_LF  = $0a ; line feed

SYS_VECTOR_NMI = $fffa
SYS_VECTOR_RESET = $fffc
SYS_VECTOR_IRQ = $fffe

.macro sys_delay_us micros
    .local @0,@1,@2
    .local cnt
        cnt=((micros * clockspeed) - (3+3+3+3+2)) / 6
    .assert cnt >= 0, error, "micros to small!"
    .assert (>.HIWORD(cnt)) = 0, error, "micros to large!"
    pha
    phx
    phy
    lda #1+<.HIWORD(cnt)
@0:	ldx #1+>(cnt)
@1: ldy #1+<(cnt) ; ~6cl inner loop
@2: dey
    nop
	bne @2
    dex
    bne @1
    dec a
    bne @0
    ply
    plx
    pla
.endmacro

.macro sys_delay_ms millis
	sys_delay_us (millis * 1000)
.endmacro

.endif
