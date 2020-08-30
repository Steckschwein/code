.include "asteroids.inc"

.zeropage
ptr1:   .res 2
ptr2:   .res 2
ptr3:   .res 2
tmp1:   .res 1
tmp2:   .res 1
tmp3:   .res 1
tmp4:   .res 1

.code
.import intro_init

.import scoreboard_update
.import scoreboard_count
.import scoreboard_init

.include	"appstart.inc"
appstart $1000

main:
;			jsr intro_init
			sei
			jsr init_gfx
			lda #ROM_OFF				;switch rom off
			sta ctrl_port
			SetVector	game_isr, $fffe

			jsr init_game

			cli


@game_loop:
	lda game_status
			bit	#1
			beq	@game_loop
			lda #Cyan
			jsr vdp_bgcolor

			jsr animate_background
			jsr animate_asteroids
			jsr asteroids_script
			jsr animate_shot

			dec game_status
			lda #Black
			jsr vdp_bgcolor
			bra @game_loop

init_gfx:
			lda #<vdp_init_bytes_gfx
			ldy #>vdp_init_bytes_gfx
			ldx #<(vdp_init_bytes_gfx_end-vdp_init_bytes_gfx)-1
			jsr vdp_init_reg
			jsr init_screen
			jsr init_sprites
			lda #COLOR_STARS<<4|Black
			rts

init_sprites:
			lda #<ADDRESS_GFX3_SPRITE_PATTERN
			ldy #>ADDRESS_GFX3_SPRITE_PATTERN+WRITE_ADDRESS
			vdp_sreg
			SetVector	sprite_pattern, ptr1
			ldx #4
			ldy #0
@l0:		lda (ptr1),y
			vnops
			sta a_vram
			iny
			bne	@l0
			inc ptr1+1
			dex
			bne @l0
			jsr update_spritetab
			rts

init_game:
			ldx #0
:			stz sprite_tab,x
			inx
			cpx #(_game_memory_end-_game_memory)
			bne :-

			lda #SPEED_ASTEROID
			sta asteroids_speed

			stz asteroids_scriptptr
			jsr asteroids_script

			ldx #32*4
@l0:		lda sprite_init_tab,x
			sta sprite_tab,x
			dex
			bpl @l0

			jsr scoreboard_init

			rts


tmp0=$0
init_screen:
			jsr vdp_mode_sprites_off

			vdp_vram_w ADDRESS_GFX3_SCREEN
			lda #24
			sta tmp0
			lda #0
@l1:		tax
			ldy #25
@l0:		vdp_wait_l
			stx a_vram
			dey
			beq @blank
			inx
			cpx #stars_layer_size>>3	; div 8
			bne @l0
			ldx #0
			bra @l0
@blank:
			inc
			cmp #5
			bne @blank0
			lda #0
@blank0:
			ldx #7
			ldy #' '
@blank1:	vdp_wait_l
			sty a_vram
			dex
			bne @blank1
			dec tmp0
			bne @l1

			vdp_vram_w ADDRESS_GFX3_COLOR
			lda #Light_Yellow<<4|Transparent
			ldx #24
			jsr vdp_fill

			rts

game_isr:
			bit	a_vreg
			bpl	@game_isr_exit

			save

			lda #Dark_Yellow
			jsr vdp_bgcolor

			jsr	action_handler
			jsr	update_vram

			lda #1				;TODO FIXME
			jsr scoreboard_count

			inc game_status
			inc framecnt

			lda #Black
;			jsr vdp_bgcolor

			restore
@game_isr_exit:
			rti

update_vram:
			lda #<ADDRESS_GFX3_PATTERN
			ldy #(>ADDRESS_GFX3_PATTERN)+WRITE_ADDRESS
			vdp_sreg
			ldx #0
@l0:		lda stars_backbuffer,x
			inx
			vdp_wait_l 8
			sta a_vram
			cpx #stars_layer_size
			bne @l0
update_spritetab:
			vdp_wait_l
			lda #<ADDRESS_GFX3_SPRITE
			ldy #>ADDRESS_GFX3_SPRITE+WRITE_ADDRESS
			vdp_sreg
			ldx #0
@l0:		lda sprite_tab,x
			inx
			vdp_wait_l 8
			sta a_vram
			cpx #4*32
			bne @l0
update_scoreboard:
			jsr scoreboard_update

			rts


animate_background:
			ldx #stars_layer_size-1
@erase:	stz stars_backbuffer,x
			dex
			bpl @erase

			jsr stars_layer_draw
layer_1:
			ldx #stars_per_layer*0					;setup X with offset into stars tab
			lda #stars_per_layer*0+stars_per_layer	;setup A with end offset
			jsr stars_layer_move
layer_2:
			lda framecnt
			and #$03
			bne	layer_3
			ldx #stars_per_layer*1
			lda #stars_per_layer*1+stars_per_layer
			jsr stars_layer_move
layer_3:
			lda framecnt
			and #$07
			bne	@end
			ldx #stars_per_layer*2
			lda #stars_per_layer*2+stars_per_layer
			jmp stars_layer_move
@end:
			rts

stars_layer_draw:
			ldx #(stars_per_layer*stars_nr_layers)-1
@l0:
			ldy stars_y_tab,x		;y with star y - pos
			lda stars_mask,x		;bitmask of star
			ora stars_backbuffer,y	;set to y - pos+1 with mask
			sta stars_backbuffer,y

			dex 					;next star
			bpl	@l0
			rts

stars_layer_move:
			sta tmp0
@l0:		lda stars_y_tab,x		;y with star y - pos
			inc						;increment y pos
			cmp #stars_layer_size	;highest y?
			bne @l_ypos
			lda #0					;go on with top position
@l_ypos:	sta stars_y_tab,x		;y with star y - pos
			inx 					;next star
			cpx tmp0
			bne	@l0
			rts

setup_shot:
			lda sprite_tab+SPRITE_X+4*SPNR_SHIP
			sta sprite_tab+SPRITE_X+4*SPNR_SHOT
			lda #SHIP_Y-16
			sta sprite_tab+SPRITE_Y+4*SPNR_SHOT
			inc ship_status
			rts
animate_shot:
			lda ship_status
			and #SHIP_FIRE
			beq @as_e
			lda sprite_tab+SPRITE_Y+4*SPNR_SHOT
			cmp #SHIP_Y-16
			bcc @as_m0
			beq @as_m0
			cmp #SPRITE_OFF-1
			bcs @as_m
			dec ship_status
			lda #SPRITE_INVISIBLE
			bra @as_s
@as_m0:		sec
@as_m:		sbc #7
@as_s:		sta sprite_tab+SPRITE_Y+4*SPNR_SHOT
@as_e:		rts


asteroids_scripttab_speed:
			.byte 2,2,2,2,3, 2, 3,4,4,4,4,5,6,7,8,9,10,0
asteroids_scripttab_count:
			.byte 2,3,4,8,1,12, 3,1,2,3,4,5,6,7,8,9,10,0

asteroids_script:
			lda	framecnt
			bne	@e

			ldx asteroids_scriptptr
			lda asteroids_scripttab_count,x
			beq	@e
			sta asteroids_count
			lda asteroids_scripttab_speed,x
			sta asteroids_speed
			inx
			stx asteroids_scriptptr
@e:			rts

animate_asteroids:
			lda #0
@aes_0:		sta tmp1
			jsr animate_asteroid
			lda tmp1
			inc
			cmp asteroids_count
			bne @aes_0
			rts

animate_asteroid_tab_ptr:
	.byte 0,1,2,3,4,5,6,7,0,1,2,3
animate_asteroid_tab0:
	.byte 20, 28, 36, 44, 52, 60, 68, 76
animate_asteroid_tab1:
	.byte 24, 32, 40, 48, 56, 64, 72, 80
animate_asteroid:
			tay	;A - number of asteroid
			asl
			asl
			asl
			tax

			lda sprite_tab+SPRITE_Y+4*3,x
			cmp #SPRITE_OFF-1-1; off -1 is max y ($bf) where sprite is not visible anymore, and 2nd -1 is to be safe if speed is +1 to not run into $d0 which will disable all other sprites
			bcc @ah_m
			cmp #$df
			bcs @ah_m
			rts

			jsr rnd
			cmp #MAX_X
			bcc @ae_y
			sbc #$ff-MAX_X
@ae_y:		sta sprite_tab+SPRITE_X+4*3,x	;asteroid - double sprite
			sta sprite_tab+SPRITE_X+4*4,x
			lda #$df					;respawn behind top border
@ah_m:	clc
			adc asteroids_speed
@ae_s:		sta sprite_tab+SPRITE_Y+4*3,x
			sta sprite_tab+SPRITE_Y+4*4,x
			; shape
@ae_a:		lda framecnt
			bit #03
			bne @ah_e
			lda animate_asteroid_tab_ptr,y
			sty tmp0
			tay
			lda animate_asteroid_tab0,y
			sta sprite_tab+SPRITE_N+4*3,x
			lda animate_asteroid_tab1,y
			sta sprite_tab+SPRITE_N+4*4,x
			iny
			cpy #8		;8 shapes
			bne @ah_u
			ldy #0
@ah_u:
			tya
			ldy tmp0
			sta animate_asteroid_tab_ptr,y
@ah_e:
			rts

action_handler:
			jsr get_joy_status
			bit #JOY_LEFT
			bne	@ah_r
			lda sprite_tab+SPRITE_X+4*SPNR_SHIP
			beq @ah_f;left border, skip right just check fire
			dec sprite_tab+SPRITE_X+4*SPNR_SHIP
			dec sprite_tab+SPRITE_X+4*(SPNR_SHIP+1)
@ah_r:		lda via1porta
			bit	#JOY_RIGHT
			bne	@ah_f
			lda sprite_tab+SPRITE_X+4*SPNR_SHIP
			cmp #MAX_X
			beq @ah_f
			inc sprite_tab+SPRITE_X+4*SPNR_SHIP
			inc sprite_tab+SPRITE_X+4*(SPNR_SHIP+1)
@ah_f:		lda ship_status
			and #SHIP_FIRE
			bne @ah_e
			lda via1porta
			and #JOY_FIRE
			bne @ah_e
			jsr setup_shot
@ah_up:
			lda via1porta
			bit #JOY_UP
			bne @ah_e
			dec sprite_tab+SPRITE_Y+4*0
			dec sprite_tab+SPRITE_Y+4*1
@ah_e:
			rts

get_joy_status:
	lda	#JOY_PORT		;select joy port
	sta	via1porta
	lda	via1porta		;read port input
	rts

rnd:
	lda seed
	beq doEor
	asl
	beq noEor ;if the input was $80, skip the EOR
	bcc noEor
doEor:
	eor #$1d
noEor:
	sta seed
	rts

stars_y_tab:							; TODO use pseudo random ?!
	.byte 3,11,21,33	; layer
	.byte 3,11,21,33	; layer
	.byte 3,11,21,33	; layer
;	.byte 3,7,11,16,21,29,33,37	; layer 2
;	.byte 3,7,11,16,21,29,33,37	; layer 3

stars_mask:
	.byte $04,$08,$40,$01	;layer 1
	.byte $04,$80,$10,$20	;layer 2
	.byte $20,$04,$01,$80	;layer 3
	.byte $04,$80,$10,$20	;layer 4
	.byte $04,$80,$10,$20	;layer 5

stars_backbuffer:
	.res stars_layer_size, 0

sprite_init_tab:
	.byte SHIP_Y,		SHIP_X, 0, COLOR_SHIP
	.byte SHIP_Y, 		SHIP_X, 4, COLOR_SHIP2
	.byte SPRITE_INVISIBLE,	SHIP_X, 8, COLOR_SHOT
	.byte ROCK_Y,		100, 20, COLOR_ROCK
	.byte ROCK_Y,		100, 24, COLOR_ROCK2
	.byte ROCK_Y*6,	100, 20, COLOR_ROCK
	.byte ROCK_Y*6,	100, 24, COLOR_ROCK2

	.byte ROCK_Y*4,	100, 20, COLOR_ROCK
	.byte ROCK_Y*4,	100, 24, COLOR_ROCK2
	.byte ROCK_Y*10,	100, 20, COLOR_ROCK
	.byte ROCK_Y*10,	100, 24, COLOR_ROCK2

	.byte ROCK_Y*8,	100, 20, COLOR_ROCK
	.byte ROCK_Y*8,	100, 24, COLOR_ROCK2
	.byte ROCK_Y*2,	100, 20, COLOR_ROCK
	.byte ROCK_Y*2,	100, 24, COLOR_ROCK2

	.byte ROCK_Y*5,	100, 20, COLOR_ROCK
	.byte ROCK_Y*5,	100, 24, COLOR_ROCK2
	.byte ROCK_Y*11,	100, 20, COLOR_ROCK
	.byte ROCK_Y*11,	100, 24, COLOR_ROCK2

	.byte ROCK_Y*3,	100, 20, COLOR_ROCK
	.byte ROCK_Y*3,	100, 24, COLOR_ROCK2
	.byte ROCK_Y*9,	100, 20, COLOR_ROCK
	.byte ROCK_Y*9,	100, 24, COLOR_ROCK2

	.byte ROCK_Y*7,	100, 20, COLOR_ROCK
	.byte ROCK_Y*7,	100, 24, COLOR_ROCK2
	.byte ROCK_Y*12,	100, 20, COLOR_ROCK
	.byte ROCK_Y*12,	100, 24, COLOR_ROCK2
	.byte $d0

.data
vdp_init_bytes_gfx:
			.byte v_reg0_m3		;
			.byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
			.byte (ADDRESS_GFX2_SCREEN / $400)  ; name table - value * $400
			.byte	$ff	  ; color table setting for gfx mode 2 --> only Bit 7 is taken into account 0 => at vram $0000, 1 => at vram $2000, Bit 6-0 AND to character number
			.byte	$00	  ; pattern table - either at vram $0000 (Bit 2 = 0) or at vram $2000 (Bit 2=1), Bit 0,1 are AND to select the pattern array
			.byte	(ADDRESS_GFX2_SPRITE / $80)	; sprite attribute table - value * $80 --> offset in VRAM
			.byte	(ADDRESS_GFX2_SPRITE_PATTERN / $800)	; sprite pattern table - value * $800  --> offset in VRAM
			.byte	Black
	.ifdef V9958
			.byte v_reg8_VR	; VR - 64k VRAM TODO set per define
			.byte v_reg9_nt ; #R9, set bit 1 to 1 for PAL
	.endif
vdp_init_bytes_gfx_end:

sprite_pattern:
;.include "ship.res"
;.include "shot.res"
;.include "shot2.res"
;.include "shot3.res"
;.include "rock001.res"
;.include "rock002.res"
;.include "rock003.res"
;.include "rock004.res"
;.include "rock005.res"
;.include "rock006.res"
;.include "rock007.res"
;.include "rock008.res"
;.include "bonus_base.res"
;.include "bonus_shield.res"
;.include "bonus_shot.res"
;.include "bonus_speed.res"

.bss
_game_memory:
sprite_tab:
	.res  32*4
sprite_empty:
; the empty sprite
	.res 32
framecnt: 		.res 1
game_status:	.res 1
ship_status:	.res 1
asteroids_speed:		.res 2
asteroids_count:		.res 1
asteroids_scriptptr:	.res 1
_game_memory_end:

.segment "STARTUP"
