;
; void clrscr (void);
;

		  .export _clrscr
		  
		  .include "kernel/kernel_jumptable.inc"

_clrscr:
	pha
	lda #27
	jsr krn_chrout

	lda #'['
	jsr krn_chrout

	lda #'2'
	jsr krn_chrout

	lda #'J'
	jsr krn_chrout

	pla
	rts	