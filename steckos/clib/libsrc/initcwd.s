;
; steckos _cwd
;
      .include "kernel/kernel_jumptable.inc"

      .importzp sreg, ptr1, ptr2

      .import	__cwd
      .importzp __cwd_buf_size

      .export	initcwd

      .macpack generic

initcwd:
		  lda	#<__cwd
		  ldy	#>__cwd
      ldx #__cwd_buf_size
      jmp krn_getcwd
