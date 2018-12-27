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

.include "system.inc"
.include "ym3812.inc"

.import popa

.export init_opl2, opl2_delay_data, opl2_delay_register
.export _opl2_init=init_opl2
.export _opl2_write=opl2_write

;----------------------------------------------------------------------------------------------
; "init" opl2 by writing zeros into all registers
;----------------------------------------------------------------------------------------------
init_opl2:
    ldx #opl2_reg_ctrl
    lda #$80
    jsr opl2_reg_write
    lda opl_stat        ; have to read status register
    
    ldx #5              ; reg 5 until reg 245
    lda #0
@l:
    jsr opl2_reg_write
    inx
    cpx #$f5
    bne @l
    rts

;
; void __fastcall__ opl2_write(unsigned char val, unsigned char reg);
;
opl2_write:
    tax
    jsr popa
opl2_reg_write:
    .import hexout
;    jsr hexout
	stx opl_stat
    jsr opl2_delay_register
 ;   jsr hexout
	sta opl_data
    jmp opl2_delay_data

    
; jsr here: 6 cycles
; rts back: 6 cycles

opl2_delay_data: ; 23000ns - 3300ns => 8Mhz/125ns => 157cl => 12cl (jsr/rts) + 145cl (73 nop)
.repeat opl2_data_delay
	nop
.endrepeat
opl2_delay_register: ; 3300 ns => 8Mhz/125ns => 26cl => 12cl (jsr/rts) + 14cl (7 nop)
.repeat opl2_reg_delay
	nop
.endrepeat
	rts
