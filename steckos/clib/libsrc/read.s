;
;
;
; int __fastcall__ read(int fd,void *buf,int count)

		.include "fcntl.inc"
		.include "errno.inc"
		.include "kernel/kernel_jumptable.inc"
		.include "asminc/zeropage.inc"

		.import __rwsetup,__do_oserror,__inviocb,__oserror, popax, popptr1

		.importzp tmp1,tmp2,tmp3,ptr1,ptr2,ptr3

		.export _read

;--------------------------------------------------------------------------
; _read
.code

.proc	_read
		sta	  ptr3
	  	stx	  ptr3+1			 ; save given count as result
		eor	  #$FF			; the count argument
		sta	  ptr2
		txa
		eor	  #$FF
		sta	  ptr2+1			 ; Remember -count-1

		jsr	  popptr1			  ; get pointer to buf

		jsr	  popax			; the fd handle
		cpx	  #0				; high byte must be 0
		bne	  invalidfd

		tax						; fd to x
; read bytes loop

@r0:	inc		ptr2 			; count bytes read ?
		bne		@r1
		inc		ptr2+1
		beq		@exit
@r1:
		jsr krn_fread_byte
		bcs @eof

		sta (ptr1)
		inc ptr1
		bne @r0
		inc ptr1+1
		bra @r0

;	  	jmp __directerrno	; Sets _errno, clears _oserror, returns -1


; set _oserror and return the number of bytes read
@eof:
	  	sta  __oserror
@exit:
		; FIXME - eof reached before char count is reached we give wrong result since count (ptr3) is static
	  	lda ptr3
	  	ldx ptr3+1
	  	rts

; Error entry: Device not present

devnotpresent:
		  lda	  #ENODEV
		  jmp	  __directerrno	; Sets _errno, clears _oserror, returns -1

; Error entry: The given file descriptor is not valid or not open

invalidfd:
		  lda	  #EBADF
		  jmp	  __directerrno	; Sets _errno, clears _oserror, returns -1

.endproc
