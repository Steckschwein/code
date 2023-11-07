.include "asmunit.inc" 	; unit test api

.import hextodec				; uut
.code

		test "hextodec"


		lda	#$ff
		jsr	hextodec

		assertY $32
		assertX $35
		assertA $35

		lda	#$0
		jsr	hextodec

		assertY $30
		assertX $30
		assertA $30

		lda #$aa 
		jsr	hextodec

		assertY $31
		assertX $37
		assertA $30

		lda #$55
		jsr	hextodec

		assertY $30
		assertX $38
		assertA $35


	brk
