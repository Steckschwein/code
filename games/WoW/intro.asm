.include "wow.inc"

.export intro_main

.code
intro_main:
    jsr	krn_textui_disable			;disable textui

    jsr	gfxui_on

	lda #<INTROGFX
	ldx #>INTROGFX
	jsr ppm_load_image
	bcs error
    jsr	gfxui_blend_on
@l:
    keyin
    beq @l
    jsr	gfxui_blend_off
    bra exit

error:
    phx
    pha
    jsr	gfxui_off
	jsr	krn_textui_enable
    jsr primm
	.byte CODE_LF, "ppm error (",0
    pla
    jsr hexout
    pla
    jsr hexout
    jsr primm
    .byte ")!",0
exit:
    rts

blend_isr:
    bit a_vreg
    bpl @0
    save
    lda #$80
    sta tmp5
    lda	#Black
	jsr vdp_bgcolor
	restore
@0:
    rti

gfxui_blend_on:
gfxui_blend_off:
    rts

gfxui_on:
		jsr krn_textui_disable			;disable textui

		jsr vdp_mode7_on			   ;enable mode7 mode

;		vdp_sreg v_reg9_ln | v_reg9_nt, v_reg9  ; 212px

		lda #%00000000
		jsr vdp_mode7_blank

;		copypointer  $fffe, irqsafe
;		SetVector  blend_isr, $fffe

		rts

gfxui_off:
      sei
;      vdp_sreg 0, v_reg9
;      vdp_sreg v_reg25_wait, v_reg25
      ;copypointer  irqsafe, $fffe

      cli

      jsr	krn_textui_init
      rts

.data
INTROGFX: .asciiz "wowintro.ppm"
;INTROGFX: .asciiz "INTRO.GFX"

.bss
irqsafe: .res 2
tmp0:	.res 1
tmp5:	.res 1
