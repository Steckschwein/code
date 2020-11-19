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

.macro sys_delay_us micros
		phx 
		phy
		ldx #>( ((micros * clockspeed) - (3+3+3+3)) / 256) 
		ldy #<( ((micros * clockspeed) - (3+3+3+3)) / 5) ; inner loop
:		dey
		bne :-
		dex
		bne :-
		ply
		plx	
.endmacro

.macro sys_delay_ms millis
	sys_delay_us millis * 1000
.endmacro

.endif
