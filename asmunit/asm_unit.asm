_test_ok:
	lda #'.'
	jmp chrout
_test_failed:
	lda #'E'
	jmp chrout