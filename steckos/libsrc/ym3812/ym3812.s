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

.include "ym3812.inc"

.export opl2_init, opl2_delay_data, opl2_delay_register, opl2_reg_write
.export _opl2_init=opl2_init

;----------------------------------------------------------------------------------------------
; "init" opl2 by writing zeros into most registers
;
; void __fastcall__ opl2_init(void);
;----------------------------------------------------------------------------------------------
.code
opl2_init:
		php
		sei

		ldx #8
		lda #0
@l:		jsr opl2_reg_write
		inx
		cpx #$f6					 ; until reg $f5
		bne @l

		ldx #1
		lda #(1<<5) 	; enable WS
		jsr opl2_reg_write

		ldx #4
		lda #$80		; reset irq
		jsr opl2_reg_write
		lda #$0		; disable timer 1 & 2 IRQ
		jsr opl2_reg_write

		plp
		rts

;
;	in:
;		 .X - opl2 register select
;		 .A - opl2 data
opl2_reg_write:
		stx opl_sel
		jsr opl2_delay_register
		sta opl_data
;		jsr opl2_delay_register
opl2_delay_data: ; 23000ns - 3300ns => 8Mhz/125ns => 157cl => 12cl (jsr/rts) + 145cl (73 nop)
.repeat opl2_delay_data_cnt
		nop
.endrepeat
opl2_delay_register: ; 3300 ns => 8Mhz/125ns => 26cl => 12cl (jsr/rts) + 14cl (7 nop)
.repeat opl2_delay_register_cnt
		nop	
.endrepeat
		rts
