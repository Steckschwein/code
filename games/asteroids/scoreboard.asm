.setcpu "65C02"

;.code

.include "vdp.inc"

.export scoreboard_init
.export	scoreboard_count
.export scoreboard_update

score:
	.res 6,0

; the nop slide macro
m_vdp_nopslide

text_score_board:
	.asciiz	"Score:"

scoreboard_init:
			stz	score
			stz	score+1
			stz	score+2
			stz	score+3
			rts
			lda #<(ADDRESS_GFX3_SCREEN+22*32+25)
			ldy #>(ADDRESS_GFX3_SCREEN+22*32) | WRITE_ADDRESS
			vdp_sreg
			ldx	#0
@l0:		lda	text_score_board,x
			beq	@e
			vnops
			sta	a_vram
			inx
			bne	@l0
@e:			rts

scoreboard_update:
			lda #<(ADDRESS_GFX3_SCREEN+23*32+26)
			ldy #>(ADDRESS_GFX3_SCREEN+23*32+26) | WRITE_ADDRESS
			vdp_sreg
@l0:		lda score
			jsr digits_out
			lda score+1
			jsr digits_out
			lda score+2
			jsr digits_out

			rts

digits_out:
			pha
			lsr
			lsr
			lsr
			lsr
			ora	#'0'
			vnops
			sta a_vram
			pla
digit_out:
			and #$0f
			ora	#'0'
			vnops
			sta a_vram
			rts

scoreboard_count:
	sed
	clc
	adc	score+2
	sta score+2
	bcc	@e
	adc	score+1
	sta	score+1
	bcc	@e
	adc	score
	sta	score
@e:	cld
	rts
