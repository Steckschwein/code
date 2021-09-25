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

.include "asmunit.inc"

.import char_out

.zeropage
	zp_loc: .res 1

.code
.export test1
test1:
	test_name "asmunit assertA"
	lda #27
	assertA 27
	assertA $ef	; expect fail

.export test2
test2:
	test_name "asmunit assertX"
	ldx #$e9
	assertX $e9
	assertX $ab	; expect fail

.export test3
test3:
	test_name "asmunit assertY"
	ldy #$9e
	assertY $9e
	assertY $cd	; expect fail

.export test4
test4:
	test_name "asmunit assertC"
	clc
	assertC 0
	assertC 1	; expect fail

.export test5
test5:
	sec
	assertC 1
	assertC 0	; expect fail

.export test6
test6:
	test_name "asmunit assertZ"
	lda #0
	assertZ 1
	assertZ 0	; expect fail

.export test7
test7:
	lda #1
	assertZ 0
	assertZ 1	; expect fail

	test_name "asmunit assert8"
	assert8 $08, _number
	assert8 $12, _number

	test_name "asmunit assert16"
	assert16 $1608, _number
	assert16 $1234, _number

	test_name "asmunit assert32"
	assert32 $32241608, _number
	assert32 $12345678, _number

.export test8
test8:
	test_name "asmunit assertOut"
	lda #'x'
	jsr char_out
	assertOut "x"
	assertOut "X"

.export test9
test9:
	test_name "asmunit assertString"
	assertString "65c02", _string
	assertString "65C02", _string

.export test10
test10:
	test_name "asmunit fail"
	fail"raised a fail explicitly!"

.export test11
test11:
	test_name "asmunit assertCycles"
	resetCycles
	nop
	assertCycles 2	; pass

	resetCycles
	nop
	assertCycles 3	; pass

	resetCycles
	nop
	assertCycles 100	; pass

	resetCycles
	nop
	assertCycles 255	; pass

	resetCycles
	nop
	assertCycles 65536	; pass

	resetCycles
	nop
	assertCycles 1	; fail

.export test13
test13:
	test "assertCycles_to_few_cycles"

	resetCycles
	jsr foo
	assertCycles 13 ; fail

.export test14
	test14:
	test "assertCycles bbs"

	stz zp_loc
	resetCycles
	bbs7 zp_loc, :+
:	assertCycles 5

	brk

foo:
	nop
	rts
_string: .asciiz "65c02"
_number: .byte $08
			.byte $16
			.byte $24
			.byte $32

.segment "ASMUNIT"
