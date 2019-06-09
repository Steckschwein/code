

.include "asmunit.inc" 	; unit test api

.import crc7				; uut

.macro testcase label, data, expect
      test label
      lda #<data
      ldy #>data
      jsr crc7
      assertA expect
.endmacro

.code
      testcase "crc7_d1", d1, 0
      testcase "crc7_d2", d2, 0
      ;testcase "crc7_d3", d3, 0
      testcase "crc7_d4", d4, $32

      testcase "crc7_d5", d5, $6d
      testcase "crc7_d6", d6, $76
      testcase "crc7_d7", d7, $10
      testcase "crc7_d8", d8, $6c

      brk

d1: .byte 0
d2: .byte 1, $89
d3: .byte 1, $91
d4: .byte 1, $20
d5: .byte 1, 'A'
d6: .byte 1, 'B'
d7: .byte 2, "AB"
d8: .byte 4, $de, $ad, $be, $ef
