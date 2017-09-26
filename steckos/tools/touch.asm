.include "common.inc"
.include "fcntl.inc"	; @see
.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"

.include "appstart.inc"
appstart $1000
    	lda paramptr
    	ldx paramptr+1
		ldy #O_CREAT
    	jsr krn_open
		bne @errmsg
		jsr krn_close
		
		jsr krn_primm
		.byte $0a," touch ok",$00
@exit:
		jmp (retvec)
		
@errmsg:
		;TODO FIXME maybe use oserror() from cc65 lib
		pha
		jsr krn_primm
		.asciiz "Error: "
		pla
		jsr krn_hexout
		jmp @exit