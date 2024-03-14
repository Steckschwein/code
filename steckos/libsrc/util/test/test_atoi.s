.include "asmunit.inc" 	; unit test api

.import atoi		; uut

.code

	test "atoi"

	lda	#'0'
	jsr	atoi

	assertA $00		; assert A is not destroyed


	lda	#'f'
	jsr	atoi

	assertA $0F		; assert A is not destroyed

	brk
