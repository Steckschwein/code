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
.include "debug.inc"

.export opl2_init, opl2_delay_data, opl2_delay_register
.export opl2_reg_write
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

		lda #0
		tax
@l:		jsr _opl2_reg_write
		inx
		bne @l

		ldx #opl2_reg_ctrl
		lda #$60	; disable timer 1 & 2 IRQ
		jsr _opl2_reg_write

		lda #$80	; reset irq
		jsr _opl2_reg_write

		ldx #1
		lda #(1<<5) 	; enable WS
		jsr _opl2_reg_write

		plp
		rts

opl2_reg_write:
		php
		sei
    jsr _opl2_reg_write
		plp
		rts

;	in:
;		 .X - opl2 register select
;		 .A - opl2 data
_opl2_reg_write:
		stx opl_sel
		jsr opl2_delay_register
		sta opl_data
opl2_delay_data:
.repeat opl2_delay_data_cnt
		nop
.endrepeat
opl2_delay_register:
.if(opl2_delay_register_cnt>0)
	.repeat opl2_delay_register_cnt
		nop
	.endrepeat
.endif
		rts
