;
; MLA
; Ullrich von Bassewitz, 06.08.1998
;
; unsigned char kbhit (void);
;

    .include "asminc/zeropage.inc"

    .export			_kbhit
		  
.proc	_kbhit

        ldx #0				  ; High byte of return is always zero
        lda key_char
        rts
.endproc
