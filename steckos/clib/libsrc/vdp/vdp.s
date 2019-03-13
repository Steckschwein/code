;
; void __fastcall__ vdp_memcpy (unsigned int vramadress, unsigned char count, unsigned char *data); 
;

        .import pushax, steaxspidx, incsp1, incsp3, return0
        .importzp ptr1, tmp1, tmp2

;----------------------------------------------------------------------------
.code

.proc _vdp_memcpy
        rts
.endproc