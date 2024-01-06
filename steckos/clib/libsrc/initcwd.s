;
; steckos _cwd
;
      .include "kernel/kernel_jumptable.inc"

      .import	__cwd
      .import __cwd_buf_size

      .importzp sreg, ptr1, ptr2

      .export	initcwd

      .macpack generic

initcwd:
		  lda	#<__cwd
		  ldx	#>__cwd
      ldy #<__cwd_buf_size
      jmp krn_getcwd
