.include "steckos.inc"
.include "vdp.inc"


.import vdp_mode7_on
.import vdp_mode7_blank
.import gfx_plot
.import vdp_bgcolor
.import vdp_init_reg

;.autoimport

.export char_out=krn_chrout

.code
appstart $1000

	sei
	copypointer user_isr, save_isr
	SetVector isr, user_isr
	cli

	jsr gfxui_on

	keyin

	jsr gfxui_off

	sei
	copypointer save_isr, user_isr
	cli

	jmp (retvec)

gfxui_on:
	jsr krn_textui_disable			;disable textui

	lda #<vdp_init_bytes_gfx7
	ldy #>vdp_init_bytes_gfx7
	ldx #<(vdp_init_bytes_gfx7_end-vdp_init_bytes_gfx7)-1
	jsr vdp_init_reg

	;jsr vdp_mode7_on			   ;enable gfx7 mode
	;vdp_sreg v_reg9_ln | v_reg9_nt, v_reg9  ; 212px


	;ldy #%01100000
	;jsr vdp_mode7_blank


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

isr:
	bit	a_vreg
	bpl	isr_end
	;lda	#%00011100
 	;jsr	vdp_bgcolor

	;lda	#0
 	;jsr	vdp_bgcolor
isr_end:
	rts
.data
vdp_init_bytes_gfx7:
	.byte v_reg0_m5|v_reg0_m4|v_reg0_m3									; reg0 mode bits
	.byte v_reg1_display_on|v_reg1_spr_size |v_reg1_int 				; TODO FIXME verify v_reg1_16k t9929 specific, therefore 0
	.byte >(ADDRESS_GFX7_SCREEN>>3) | $1f	; => 00<A16>1 1111 - entw. bank 0 (offset $0000) or 1 (offset $10000)
	.byte $0
	.byte $0
	.byte >(ADDRESS_GFX7_SPRITE<<2); r#5
	.byte >(ADDRESS_GFX7_SPRITE_PATTERN<<1); R#6
	.byte %11100000 ; R#7 border color
	.byte v_reg8_VR	; VR - 64k VRAM  - R#8
	.byte v_reg9_nt | v_reg9_ln ; #R9, 212px , set bit to 1 for PAL
	.byte 0;  #R10
	.byte 0;  #R11
	.byte 0;  #R12
	.byte 0;  #R13
	.byte <.HIWORD(ADDRESS_GFX7_SCREEN<<2) ; #R14
vdp_init_bytes_gfx7_end:
sprite_attr:
sprite_attr_0:
	sprite_y: .byte 50
	sprite_x: .byte 50
	pattern:  .byte 0
	res: .byte 0
sprite_attr_end:

sprite_pattern:
sprite_0:
	.byte 255
	.byte 255
	.byte 255
	.byte 255
	.byte 255
	.byte 255
	.byte 255
	.byte 255
sprite_1:
	.byte $55
	.byte $55
	.byte $55
	.byte $55
	.byte $55
	.byte $55
	.byte $55
	.byte $55
sprite_pattern_end:

.bss 
save_isr: .res 2
