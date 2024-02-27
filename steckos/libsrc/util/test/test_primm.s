.include "asmunit.inc" 	; unit test api

.import primm 		; uut
.code
	test "primm"

	lda	#0 
	ldx #0 
	ldy #0
	jsr	primm 
    .asciiz "Hello World!"

	assertOut "Hello World!"	; assert outpuz
	assertA 0 
	assertX 0 
	assertY 1

	brk
