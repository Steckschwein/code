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


	jsr gfxui_on

	keyin

	jsr gfxui_off

	jmp (retvec)

gfxui_on:
		jsr krn_textui_disable			;disable textui

		jsr vdp_mode7_on			   ;enable gfx7 mode
		vdp_sreg v_reg9_ln | v_reg9_nt, v_reg9  ; 212px

		ldy #0
		jsr vdp_mode7_blank

		rts

gfxui_off:
      sei

      pha
      phx
      vdp_sreg v_reg9_nt, v_reg9  ; 192px
      jsr krn_textui_init
      plx
      pla

      cli

      rts