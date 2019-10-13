;
; void clrscr (void);
;

		  .export _clrscr
		  
		  .include "kernel/kernel_jumptable.inc"

_clrscr=krn_textui_clrscr_ptr