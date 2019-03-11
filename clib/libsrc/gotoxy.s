;
; void gotoxy (unsigned char x, unsigned char y);
;
        .export _gotoxy
        .import popa
        
        .include "asminc/zeropage.inc"
        .include "kernel_jumptable.inc"
		
_gotoxy:
        sta     crs_y
        jsr     popa    ; Get X 
        sta     crs_x   ; Set X
        jmp     krn_textui_update_crs_ptr