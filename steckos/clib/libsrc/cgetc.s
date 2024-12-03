;
;
; char cgetc (void);
;
		  .export _cgetc
		  .import _getch

		  .include "kernel/kernel_jumptable.inc"

_cgetc=_getch
