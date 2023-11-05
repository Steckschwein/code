.include "asmunit.inc" 	; unit test api

.import strout		; uut
.zeropage
ptr1: .res 2
.exportzp ptr1
.code

	test "strout"

	lda	#<text 
	ldx #>text 
	ldy #42
	jsr	strout

	assertOut "Hello World!"	; assert outpuz
	;assertA #<text 
	;assertX #>text 
	assertY 42

	brk
.data 
text: .asciiz "Hello World!"