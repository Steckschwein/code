.include "steckos.inc"
.include "vdp.inc"


.import vdp_mode7_on
.import vdp_mode7_blank
.import gfx_plot
.import vdp_bgcolor
.import vdp_init_reg

.autoimport

.export char_out=krn_chrout

.code
appstart $1000

	sei
	copypointer user_isr, save_isr
	SetVector isr, user_isr
	cli

	jsr gfxui_on

	vdp_vram_w ADDRESS_GFX7_SPRITE
    lda #<sprite_attr
    ldy #>sprite_attr
    ldx #sprite_attr_end - sprite_attr
    jsr vdp_memcpys

	vdp_vram_w ADDRESS_GFX7_SPRITE_PATTERN
    lda #<sprite_pattern
    ldy #>sprite_pattern
    ldx #sprite_pattern_end - sprite_pattern
    jsr vdp_memcpys

	vdp_vram_w ADDRESS_GFX7_SPRITE_COLOR
    lda #<sprite_color
    ldy #>sprite_color
    ldx #2
    jsr vdp_memcpys


	vdp_sreg v_reg8 | v_reg8_VR 


	keyin

	jsr gfxui_off

	sei
	copypointer save_isr, user_isr
	cli

	jmp (retvec)

gfxui_on:
	jsr krn_textui_disable			;disable textui

	jsr vdp_mode7_on			   ;enable gfx7 mode
	vdp_sreg v_reg9_ln | v_reg9_nt, v_reg9  ; 212px


	ldy #$ff
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

isr:
	bit	a_vreg
	bpl	isr_end
	lda	#%00011100
 	jsr	vdp_bgcolor

	lda	#0
 	jsr	vdp_bgcolor
isr_end:
	rts


.data
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
	.byte $0
	.byte $0
	.byte $0
	.byte $0
	.byte $0
	.byte $0
	.byte $0
	.byte $0
sprite_2:
	.byte $0
	.byte $0
	.byte $0
	.byte $0
	.byte $0
	.byte $0
	.byte $0
	.byte $0
sprite_3:
	.byte 255
	.byte 255
	.byte 255
	.byte 255
	.byte 255
	.byte 255
	.byte 255
	.byte 255
sprite_pattern_end:

sprite_color:
	.byte %11100000
	.byte %00011100
sprite_color_end:

.bss 
save_isr: .res 2
