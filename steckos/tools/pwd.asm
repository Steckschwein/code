.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"

.autoimport

.export char_out=krn_chrout

appstart $1000

buffer_size=255

.code
		lda	#<buffer
		ldy #>buffer
		ldx	#buffer_size
		jsr krn_getcwd
		bcs	@l_err
		lda	#<buffer
		ldx #>buffer
		;TODO FIXME use a/x instead of zp location msgptr
		jsr strout

@l2:
    jmp (retvec)

@l_err:
		pha
		jsr primm
    .asciiz "i/o error "
		pla
		jsr hexout
		bra @l2

buffer:
	.res buffer_size