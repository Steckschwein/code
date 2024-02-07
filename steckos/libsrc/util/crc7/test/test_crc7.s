		.include "asmunit.inc" 	; unit test api

		.import crc7				; uut

.macro testcase label, data, length, expect, expectCycles
		test label
		lda #<data
		ldy #>data
		ldx #length
    resetCycles
		jsr crc7
		assertA expect
		assertCycles expectCycles
.endmacro

.code
		testcase "crc7_d1", d1, 0, 0, 400
		testcase "crc7_d2", d2, 1, 0, 520
		testcase "crc7_d3", d3, 0, 0, 520
		testcase "crc7_d4", d4, 1, $32, 520

		testcase "crc7_d5", d5, 1, $6d, 520
		testcase "crc7_d6", d6, 1, $76, 600
		testcase "crc7_d7", d7, 2, $10, 800
		testcase "crc7_d8", d8, 4, $6c, 900

		testcase "crc7_d9", d9, 12, 0, 12000

		testcase "crc7_nvram", d10, 14, $2e, 12800

		test_end

d1: .byte 0
d2: .byte $89
d3: .byte $91
d4: .byte $20
d5: .byte 'A'
d6: .byte 'B'
d7: .byte "AB"
d8: .byte $de, $ad, $be, $ef
d9: .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
d10:.byte $42,"LOADER  BIN",0,1,3
