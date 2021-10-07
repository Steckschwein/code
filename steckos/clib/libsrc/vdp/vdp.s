
    .include "kernel/kernel_jumptable.inc"
    .include "asminc/vdp.inc"
    .include "asminc/debug.inc"

  .import pushax, steaxspidx, incsp1, incsp3, return0
  .importzp ptr1, tmp1, tmp2

  .import vdp_init_reg
  .import vdp_memcpy
  .import hexout
  .import popax
  .import popa
  .import _cputc
  .export char_out=_cputc
;----------------------------------------------------------------------------
.code

;
; void __fastcall__ vdp_memcpy (unsigned char *data, unsigned int vramaddress, unsigned char pages);
;
.export _vdp_memcpy
.proc _vdp_memcpy
        php
        sei
        ;dbg

		pha ;save page count

		jsr popa
		sta a_vreg
		jsr popa
		and #$3f
		ora #WRITE_ADDRESS
		sta a_vreg

		jsr popax
		phx
		ply

		plx ;restore page count
        jsr vdp_memcpy
        plp
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
