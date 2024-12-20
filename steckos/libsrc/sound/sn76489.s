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

.setcpu "6502"

.include "sn76489.inc"
.include "debug.inc"

.export sn76489_init
.export sn76489_setfreq
.export sn76489_setatn
.export sn76489_muteall

.importzp __volatile_tmp

.code

sn76489_init:
              rts


sn76489_muteall:
              LDY	#$03		; channels 0..3 to mute
              TYA
: 	          ;JSR	SOUND_MUTE	; mute current channel
		          DEY			; next channel
		          BPL	:-
		          RTS

; @in: A - Channel (0..2)
;	@in: X - Frequency Low Bits 7..0
;	@in: Y - Frequency High Bits 9..8
sn76489_setfreq:
              clc
              ROR	A		; and rotate channel number to bit 5 and 6
              ROR	A
              ROR	A
              ROR	A
              ORA	#$80		; set high bit
              STA	__volatile_tmp		; and store it in __volatile_tmp variable
              TXA			; load frequency low bits into A
              AND	#$0F		; we first want to send the lower 4 bits
              ORA	__volatile_tmp		; combined it with the channel number
              JSR	sn76489_write	; send complete first command byte to the sound chip
              TYA			; load frequency high bits into A
              STX	__volatile_tmp		; store frequency low bits to __volatile_tmp variable
              LDX	#$04		; we need four bits shifted
LOOP_NXT:     ASL	__volatile_tmp		; shift highest bit of low frequency to Carry flag
              ROL	A		; and shift it into the high frequency bits
              DEX			; decrement counter
              BNE	LOOP_NXT	; do we need more shifts?
sn76489_write:
              sta card_slot0
              rts

              rts
sn76489_setatn:
              rts
