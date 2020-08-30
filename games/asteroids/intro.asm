.setcpu "65C02"

.include "asteroids.inc"

.export intro_init

.code
intro_init:
			jsr gfxui_on
			jsr gfxui_blend_on
@wait_key:
			jsr krn_getkey
			bcc @wait_key
			jsr gfxui_blend_off
l1:		rts


row=$100
gfxui_blend_off:
	lda #Transparent<<4|Transparent ; transparent AND color results in not displaying any color at all
	bra l3
gfxui_blend_on:
	lda #$ff	; $ff AND color gives color itself
l3:
	sta tmp2	; the tmp2 AND color is applied
	SetVector  ((WRITE_ADDRESS<<8)+ADDRESS_GFX2_COLOR+0),			ptr1
	SetVector  ((WRITE_ADDRESS<<8)+ADDRESS_GFX2_COLOR+row+$f8),	ptr2; +1 row and $f8 end of line

	stz tmp0
	lda #8
	sta tmp1
	lda #$f8
	sta tmp3
	stz tmp4
	stz tmp5

@l:
	bit tmp5	 ;sync with isr
	bpl @l
	stz tmp5

	ldx	#12
@l2:	lda ptr1
	ldy ptr1+1
	vdp_sreg
 	ldy tmp0
@c:	lda color,y
	and tmp2
	sta a_vram
	iny
	cpy tmp1
	bne @c
	inc @c+2
	inc @c+2
	inc ptr1+1
	inc ptr1+1
	dex
	bne @l2

	sty tmp0	 ;new offset
	sty ptr1
	tya
	clc
	adc #08
	sta tmp1

	lda #((WRITE_ADDRESS)+>ADDRESS_GFX2_COLOR)
	sta ptr1+1
	lda #>color
	sta @c+2

	ldx	#12
@l3:
	lda ptr2
	ldy ptr2+1
	vdp_sreg
	ldy tmp3
@c2:	lda color+row,y
	and tmp2
	sta a_vram
	iny
	cpy tmp4
	bne @c2
	inc @c2+2
	inc @c2+2
	inc ptr2+1
	inc ptr2+1
	dex
	bne  @l3

	lda tmp3
	sta tmp4
	sec
	sbc #08
	sta tmp3
	sta ptr2

	lda #(WRITE_ADDRESS)+>(ADDRESS_GFX2_COLOR+row+$f8)
	sta ptr2+1
	lda #>(color+row)
	sta @c2+2
	lda tmp0
	beq @l4
	jmp @l
@l4:	rts

blend_isr:
			bit a_vreg
			bpl @0
			save
			lda	#Dark_Yellow
			jsr vdp_bgcolor


			lda #$80
			sta tmp5
			lda	#Black
			jsr vdp_bgcolor
			restore

@0:			rti

gfxui_on:
	 sei
	jsr	vdp_display_off			;display off

	jsr vdp_mode_sprites_off	;sprites off

	 lda #Black<<4|Black
	 jsr vdp_gfx2_blank

	vdp_vram_w ADDRESS_GFX2_PATTERN
	lda #<content
	ldy #>content	 ; only load the pattern data, leave colors black to blend them later
	ldx #$18	;6k bitmap - $1800
	jsr vdp_memcpy					;load the pic data

	 copypointer  $fffe, irqsafe
	lda #ROM_OFF				;switch rom off
	sta ctrl_port

	 SetVector  blend_isr, $fffe
	jsr vdp_gfx2_on				 ;enable gfx2 mode
	 cli
	 rts

gfxui_off:
	 sei
	 copypointer  irqsafe, $fffe
	 cli
	 rts

irqsafe: .res 2, 0
tmp0:	.res 1
tmp5:	.res 1
content:
.incbin "asteroids.tiap"
color:
.incbin "asteroids.tiac"
