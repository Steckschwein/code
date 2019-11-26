		.include "asmunit.inc" 	; unit test api

		.import crc7				; uut

.macro testcase label, data, length, expect, expectCycles
		test label
		lda #<data
		ldy #>data
		ldx #length
		jsr crc7
		assertA expect
		assertCycles expectCycles
.endmacro

.code
		;testcase "crc7_d1", d1, 0, 0, 10
		testcase "crc7_d2", d2, 1, 0, 2200
		;testcase "crc7_d3", d3, 0, 2000
		testcase "crc7_d4", d4, 1,$32, 2200

		testcase "crc7_d5", d5, 1, $6d, 4500
		testcase "crc7_d6", d6, 1, $76, 4500
		testcase "crc7_d7", d7, 2, $10, 6000
		testcase "crc7_d8", d8, 4, $6c, 7000
		
		testcase "crc7_d9", d9, 12, 0, 10000

		brk

d1: .byte 0
d2: .byte $89
d3: .byte $91
d4: .byte $20
d5: .byte 'A'
d6: .byte 'B'
d7: .byte "AB"
d8: .byte $de, $ad, $be, $ef
d9: .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

