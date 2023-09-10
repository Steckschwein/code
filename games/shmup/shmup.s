.include "steckos.inc"
.include "vdp.inc"


.import vdp_mode7_on
.import vdp_mode7_blank
.import gfx_plot
.import vdp_wait_cmd

;.autoimport

.export char_out=krn_chrout

.code
appstart $1000


	jsr vdp_mode7_on
	; set vertical dot count to 212
	; V9938 Programmer's Guide Pg 18
	vdp_sreg  v_reg9_ln , v_reg9

	lda #%00000011
	jsr vdp_mode7_blank

loop:	jmp loop
