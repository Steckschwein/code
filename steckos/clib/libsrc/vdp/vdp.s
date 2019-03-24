  .include "kernel/kernel_jumptable.inc"
  
  .import pushax, steaxspidx, incsp1, incsp3, return0
  .importzp ptr1, tmp1, tmp2
  
  .import vdp_init_reg
  

;----------------------------------------------------------------------------
.code

;
; void __fastcall__ vdp_memcpy (unsigned int vramadress, unsigned char count, unsigned char *data); 
;
.export _vdp_memcpy
.proc _vdp_memcpy
      rts
.endproc

; void __fastcall__ vdp_init (unsigned char mode);
.export _vdp_init
.proc _vdp_init
      
      jmp vdp_init_reg
.endproc

.export _vdp_restore
.proc _vdp_restore
      jmp krn_textui_enable  
.endproc