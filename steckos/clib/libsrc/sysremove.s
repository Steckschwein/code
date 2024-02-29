;
; unsigned char __fastcall__ _sysremove (const char* name);
;

		  .export			__sysremove
		  .import			fnparse, scratch

      .include "kernel/kernel_jumptable.inc"

;--------------------------------------------------------------------------
; __sysremove:

.proc	__sysremove
      jsr krn_unlink
      bcs :+
      lda #0
      tax
  :   rts
.endproc


