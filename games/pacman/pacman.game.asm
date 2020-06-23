		.p02

		.export game

		.include "pacman.inc"

		.import gfx_vram_xy
		.import gfx_vram_ay
		.import gfx_blank_screen
		.import gfx_hires_off
		.import gfx_charout
		.import gfx_rotate_pal
		.import gfx_update
		.import gfx_display_maze
		.import gfx_pause
		.import gfx_Sprite_Adjust_X,gfx_Sprite_Adjust_Y
		.import gfx_Sprite_Off

		.import out_digit,out_digits
		.import out_hex_digits
		.import out_text

		.import sound_init
		.import sound_init_game_start
		.import sound_play
		.import sound_play_state

		.import io_joystick_read
		.import io_getkey
		.import io_player_direction
		.import io_detect_joystick
		.import io_irq

		.import ai_blinky
		.import ai_inky
		.import ai_pinky
		.import ai_clyde

		.import game_state

game:
		sei
		setIRQ game_isr, _save_irq
;		jsr gfx_hires_off
		cli

game_reset:
		lda #STATE_INIT
		sta game_state+GameState::state

@waitkey:
		jsr io_getkey
		bcc @waitkey
		sta keyboard_input
		cmp #'r'
		beq game_reset
		cmp #'p'
		bne @exit
		lda game_state+GameState::state
		eor #STATE_PAUSE
		sta game_state+GameState::state
		and #STATE_PAUSE
		jsr gfx_pause
@exit:
		cmp #KEY_EXIT
		bne @waitkey

		lda #STATE_EXIT
		sta game_state+GameState::state

		jsr sound_init

		restoreIRQ _save_irq
		rts

game_isr:
		push_axy
		jsr io_irq
		bpl game_isr_exit

		bgcolor Color_Gray

		jsr game_init
		jsr game_ready
		jsr game_ready_wait
		jsr game_playing
		jsr game_level_cleared
		;jsr game_next_level
		jsr game_game_over

		bgcolor Color_Cyan
		inc game_state+GameState::frames
		jsr gfx_update
game_isr_exit:

.ifdef __DEBUG
		jsr debug
.endif
		pop_axy
		rti

game_ready:
		lda game_state+GameState::state
		cmp #STATE_READY
		bne @rts
		draw_text _text_player_one
		draw_text _text_ready
.ifndef __NO_SOUND
		jsr sound_play
		lda game_state+GameState::frames
		and #$7f
		bne @detect_joystick
.endif
		draw_text _delete_message_1
		jsr game_init_sprites
		lda #STATE_READY_WAIT
		sta game_state+GameState::state
@detect_joystick:
		jsr io_detect_joystick
@rts: rts

game_ready_wait:
		lda game_state+GameState::state
		cmp #STATE_READY_WAIT
		bne @rts
.ifndef __NO_SOUND
		jsr sound_play
		lda sound_play_state
		bne @rts
.endif
		draw_text _delete_message_2
		lda #STATE_PLAYING
		sta game_state+GameState::state
@rts: rts

game_game_over:
		rts


		; key/joy input ?
		;	(input direction != current direction)?
		;	y - input direction inverse current direction?
		;		 y - set current direction = inverse input direction
		;		 n - can move to input direction?
		;			  y - pre-turn? (+4px)
		;					  y - set turn direction = current direction
		;						 - set turn bit on
		;				 - post-turn?  (-3px)
		;					  y - set turn direction = inverse current direction (eor)
		;							set turn bit on
		;				 - set current direction = input direction
		;				 - change pacman shape
		;			- set next direction = input direction
		;
		; block reached? (center)
		;	y - is turn?
		;			y - reset turn bit
		;			  - reset turn direction
		;	  - can move to current direction?
		;			n - change pacman shape to next direction
		;				 reset move bit
		;
		; soft move current direction
		; turn bit on?
		;	y - soft move to turn direction


actors_move:
		ldx #ACTOR_PACMAN
		jsr actor_update_charpos
		jsr pacman_input
		jsr actor_move

		ldx #ACTOR_BLINKY
;		jsr ghost_move
		ldx #ACTOR_INKY
;		jsr ghost_move
		ldx #ACTOR_PINKY
;		jsr ghost_move
		ldx #ACTOR_CLYDE
;		jsr ghost_move
		rts

ghost_move:
		jsr actor_update_charpos
		jmp actor_move_dir

		; .A new direction
pacman_cornering:
		pha
		lda actors+actor::move,x
		and #$01  ;bit 0 set, either +x or +y, down or left
		beq @l1
		lda #$07	 ;
@l1:
		eor #$07
		sta game_tmp2 ;
		pla
l_test:
		ldy actors+actor::sprite,x
		and #ACT_MOVE_UP_OR_DOWN		; new direction is a turn
		bne l_up_or_down					; so we have to test with the current direction (orthogonal)

l_left_or_right:
		lda actors+actor::sp_x,x
		jmp l_compare

l_up_or_down:
		lda actors+actor::sp_y,x

l_compare:
		eor game_tmp2
		and #$07
		cmp #$04	 ; 0100 - center pos, <0100 pre-turn, >0100 post-turn
		rts

; 		A - bit 0-1 the direction
actor_center:
		pha
		lda #0
		sta game_tmp2
		pla
		eor #ACT_MOVE_UP_OR_DOWN
		jmp l_test

actor_move:
		lda actors+actor::turn,x
		bpl actor_move_dir			; turning?
		jsr actor_center
		bne @actor_turn_soft			;
		lda actors+actor::turn,x	;
		and #<~ACT_TURN
		sta actors+actor::turn,x
@actor_turn_soft:
		lda actors+actor::turn,x
		jsr actor_move_sprite

actor_move_dir:
		lda actors+actor::move,x
		bpl :+
		jsr actor_strategy
:		jmp pacman_collect

pacman_move:
		jsr actor_center			; center reached?
		bne actor_move_soft		; no, move soft

		lda actors+actor::move,x
		and #ACT_DIR
		jsr actor_can_move_to_direction
		bcc actor_move_soft  ; C=0 - can move to

		lda actors+actor::move,x  ;otherwise stop move
		and #<~ACT_MOVE
		sta actors+actor::move,x
		and #ACT_NEXT_DIR			;set shape of next direction
		sta actors+actor::shape,x
		rts

actor_move_soft:
		jsr pacman_shape_move
		lda actors+actor::move,x
actor_move_sprite:
		bpl @rts
		and #ACT_DIR
		asl
		tay
		pha
		lda _vectors+0,y
		;stp
		ldy actors+actor::sprite,x
		clc
		adc actors+actor::sp_x,x
		sta actors+actor::sp_x,x
;		sta sprite_tab_attr+4+SpriteTab::xpos,y
		pla
		tay
		lda _vectors+1,y
		sta game_tmp
		ldy actors+actor::sprite,x
@y_add:	; skip the sprite off position
		clc
		adc actors+actor::sp_y,x
		cmp gfx_Sprite_Off
		bne @y_sta
		lda game_tmp
		eor #$10
		jmp @y_add
@y_sta:
		sta actors+actor::sp_y,x
;		sta sprite_tab_attr+4+SpriteTab::ypos,y
@rts: rts

pacman_shape_move:
		lda game_state+GameState::frames
		lsr
		and #$03
		jmp actor_update_shape

actor_shape_move:
		lda game_state+GameState::frames
		lsr
		lsr
		lsr
		and #$01
		ora #$10		;sprite shape table offset
actor_update_shape:
		sta game_tmp
		lda actors+actor::move,x
		and #ACT_DIR
		asl
		asl
		clc
		adc game_tmp
		sta actors+actor::shape,x
		rts

pacman_collect:
		lda actors+actor::xpos,x
		ldy actors+actor::ypos,x
		jsr lda_maze_ptr_ay
		cmp #Char_Food
		bne :+
		lda #Points_Food
		jmp erase_and_score
:	  	cmp #Char_Superfood
		beq @collect_superfood
		cmp #Char_Superfood-1
		bne @rts
@collect_superfood:
		lda #Points_Superfood
		jmp erase_and_score
@rts: rts

erase_and_score:
		dec actors+actor::dots,x
		pha
		lda actors+actor::xpos,x
		sta sys_crs_x
		lda actors+actor::ypos,x
		sta sys_crs_y
		lda #Char_Blank
		ldy #0
		sta (p_maze),y
		jsr gfx_charout

		pla
		sta points+3  ; high to low
		jmp add_scores

		; in:	.A - direction
		; out:  .C=0 can move, C=1 can not move to direction
actor_can_move_to_direction:
		jsr lday_actor_charpos_direction  	; update dir char pos
		jsr lda_maze_ptr_ay						; calc ptr to next char at input direction
		cmp #Char_Bg								; C=1 if char >= Char_Bg
		rts

pacman_input:
		jsr get_input
		bcc @rts										; key/joy input ?
		sta input_direction
		jsr actor_can_move_to_direction	  	; C=0 can move
		bcs @set_input_dir_to_next_dir		; no - only set next dir

		lda actors+actor::turn,x
 	  	bmi @rts	;exit if turn is active

		;current dir == input dir ?
		lda actors+actor::move,x
		and #ACT_DIR
		cmp input_direction					;same direction ?
		beq @set_input_dir_to_next_dir	;yes, do nothing...
		;current dir == inverse input dir ?
		eor #ACT_MOVE_INVERSE
		cmp input_direction
		beq @set_input_dir_to_current_dir

		lda actors+actor::ypos,x			;is tunnel ?
		beq @rts								  	;ypos=0
		cmp #26									;... or >=26
		bcs @rts								  	;ignore input

		lda input_direction
		jsr pacman_cornering
		beq @set_input_dir_to_current_dir	; Z=1 center position, no pre-/post-turn
		lda #0
		bcc @l_preturn							 	; C=0 pre-turn, C=1 post-turn

		lda #ACT_MOVE_INVERSE					;
@l_preturn:
		eor actors+actor::move,x  ; current direction
		and #ACT_DIR
		ora #ACT_TURN
		sta actors+actor::turn,x

@set_input_dir_to_current_dir:
		lda input_direction
		ora #ACT_MOVE
		sta actors+actor::move,x

@set_input_dir_to_next_dir: ; bit 3-2
		lda input_direction
		asl
		asl
		sta game_tmp
		lda actors+actor::move,x
		and #<~ACT_NEXT_DIR
		ora game_tmp
		sta actors+actor::move,x
@rts: rts

; in:	.A - direction
lday_actor_charpos_direction:
		asl
		tay
		lda actors+actor::xpos,x
		clc
		adc _vectors+0,y
		pha ; save x pos
		lda actors+actor::ypos,x
		clc
		adc _vectors+1,y
		tay
		pla
		rts

actor_update_charpos: ;offset x=+4,y=+4  => x,y 2,1 => 4+2*8, 4+1*8
		ldy actors+actor::sprite,x
		lda actors+actor::sp_x,x
		clc
		adc gfx_Sprite_Adjust_X  ; x adjust
		lsr
		lsr
		lsr
		sta actors+actor::xpos,x
		lda actors+actor::sp_y,x
		clc
		adc gfx_Sprite_Adjust_Y  ; y adjust
		lsr
		lsr
		lsr
		sta actors+actor::ypos,x
		rts

get_input:
		lda keyboard_input
		stz keyboard_input			; "consume" key pressed
		jmp io_player_direction		; C=0 if any valid key or joystick input, A=ACT_xxx

debug:
		bgcolor Color_Bg
		pha
		txa
		pha
		lda #11
		sta sys_crs_x
		lda #0
		sta sys_crs_y
		lda Color_Text
		sta text_color
		ldx #ACTOR_PACMAN
		lda actors+actor::xpos,x
		jsr out_hex_digits
		ldy actors+actor::sprite,x
		lda actors+actor::sp_x,x
		jsr out_hex_digits
		lda actors+actor::ypos,x
		jsr out_hex_digits
		lda actors+actor::sp_y,x
		jsr out_hex_digits
		lda input_direction
		jsr out_hex_digits
		lda actors+actor::move,x
		jsr out_hex_digits
		lda actors+actor::turn,x
		jsr out_hex_digits
		lda keyboard_input
		jsr out_hex_digits
@ex:
		pla
		tax
		pla
		rts

lda_maze_ptr_ay:
		sta game_tmp
		tya
		asl
		asl
		asl
		asl
		asl
		ora game_tmp
		;clc
		;adc #<game_maze
		sta p_maze+0

		tya
		lsr ; div 8 -> page offset 0-2
		lsr
		lsr
		clc
		adc #>game_maze
		sta p_maze+1
		ldy #0
		lda (p_maze),y
		rts

game_demo:
@demo_text:
		lda game_state+GameState::frames
		and #$07
		bne @l1
		draw_text _text_pacman
		draw_text _text_demo
		rts
@l1:  lda game_state+GameState::frames
		and #$08
		beq @rts
		draw_text _delete_message_1
		draw_text _delete_message_2
@rts:
		rts

game_playing:
		lda game_state+GameState::state
		cmp #STATE_PLAYING
		bne @rts
		;jsr game_demo
		jsr actors_move
		jsr animate_ghosts
		jsr animate_screen
		jsr draw_scores

		lda actors+actor::dots	 ; all dots collected ?
		bne @rts

		ldx #ACTOR_PACMAN
		lda #Sprite_Pattern_Pacman
		;sta sprite_tab_attr+SPRITE_NR_PACMAN+SpriteTab::shape
		sta actors+actor::shape,x
		; TODO sprite off screen gfx_xxx
		lda gfx_Sprite_Off
		; sta sprite_tab_attr+SPRITE_NR_GHOST+SpriteTab::ypos
		; jsr gfx_sprites_off

		lda #STATE_LEVEL_CLEARED
		sta game_state+GameState::state
		lda #0
		sta game_state+GameState::frames
@rts: rts

game_level_cleared:
		lda game_state+GameState::state
		cmp #STATE_LEVEL_CLEARED
		bne @rts

		lda game_state+GameState::frames
		cmp #$88
		bne @rotate
		lda #STATE_INIT
		sta game_state+GameState::state
		lda #0
@rotate:
		lsr
		lsr
		lsr
		and #$03
		tay
		jsr gfx_rotate_pal

@rts: rts

add_scores:
		jsr add_score
		ldy #0
@cmp:
		lda game_state+GameState::highscore,y
		cmp game_state+GameState::score,y
		bcc @copy ; highscore < score ?
		bne @rts
		iny
		cpy #4
		bne @cmp
@rts:
		rts
@copy:
		ldy #3
@l0:
		lda game_state+GameState::score,y
		sta game_state+GameState::highscore,y
		dey
		bpl @l0
		rts

add_score:
		sed
		clc
		ldy #3
@l:	lda game_state+GameState::score,y
		adc points,y
		sta game_state+GameState::score,y
		dey
		bpl @l
		cld
		rts


draw_scores:
		setPtr (game_state+GameState::score), p_game
		lda #0
		ldy #21
		jsr draw_score
		setPtr (game_state+GameState::highscore), p_game
		lda #0
		ldy #8
draw_score:
		sta sys_crs_x
		sty sys_crs_y
		lda Color_Text
		sta text_color
		ldy #0
@skip_zeros:
		lda (p_game),y
		beq @skip ;00 ?
		and #$f0  ;0? ?
		bne @digits
		dec sys_crs_y ;output the 0-9 only
		lda (p_game),y
		jsr out_digit
		jmp @digits_inc
@skip:
		dec sys_crs_y ;skip digits
		dec sys_crs_y
		iny
		cpy #04
		bne @skip_zeros
		rts
@digits:
		lda (p_game),y
		jsr out_digits
@digits_inc:
		iny
		cpy #04
		bne @digits
		rts


animate_screen:
		lda game_state+GameState::frames
		and #$10
		bne :+
		draw_text _text_1up_del
		jmp :++
:		draw_text _text_1up
:
		lda game_state+GameState::frames
		and #$07
		bne @rts
; food
		lda Color_Food
		sta text_color
		ldx #3
@l1:  lda superfood_x,x
		ldy superfood_y,x
		sta sys_crs_x
		sty sys_crs_y
		jsr lda_maze_ptr_ay
		cmp #Char_Blank ; eaten?
		beq @next
		eor #$08			 ; toggle Char_Superfood / Char_Superfood_Blank
		ldy #0
		sta (p_maze),y
		jsr gfx_charout
@next:
		dex
		bpl @l1
@rts:
		rts


animate_ghosts:
		ldx #ACTOR_BLINKY
		jsr actor_shape_move
		ldx #ACTOR_INKY
		jsr actor_shape_move
		ldx #ACTOR_PINKY
		jsr actor_shape_move
		ldx #ACTOR_CLYDE
		jsr actor_shape_move
		rts

game_init:
		lda game_state+GameState::state
		cmp #STATE_INIT
		beq @init
		rts
@init:
		lda #0
		sta game_state+GameState::frames
		sta points+0
		sta points+1
		sta points+2
		sta points+3
		sta game_state+GameState::score+0
		sta game_state+GameState::score+1
		sta game_state+GameState::score+2
		sta game_state+GameState::score+3

		jsr sound_init_game_start

		ldx #3
		ldy #0
:
		lda maze+$000,y
		sta game_maze+$000,y
		lda maze+$100,y
		sta game_maze+$100,y
		lda maze+$200,y
		sta game_maze+$200,y
		iny
		bne :-
:	  	lda maze+$300,y
		sta game_maze+$300,y
		lda #Char_Blank
		sta game_maze+$300+1*32,y
		iny
		cpy #2*32
		bne :-

		lda #MAX_DOTS
		sta actors+actor::dots

		lda #STATE_READY
		sta game_state+GameState::state

		jmp gfx_display_maze

actor_init: ;x,y,init direction,color
		; x, y, dir
		;		.byte 92,96,	ACT_MOVE|ACT_LEFT, 	0*2*.sizeof(SpriteTab) ; TODO impl. detail move to plattform specific
		;		.byte 116,112, ACT_MOVE|ACT_UP, 		1*2*.sizeof(SpriteTab)
		;		.byte 116,96,	ACT_MOVE|ACT_DOWN, 	2*2*.sizeof(SpriteTab)
		;		.byte 116,80,	ACT_MOVE|ACT_UP, 		3*2*.sizeof(SpriteTab)
		.byte 32,$9c,	ACT_MOVE|ACT_LEFT
		.byte 64,$9c, 	ACT_MOVE|ACT_UP
		.byte 96,$9c,	ACT_MOVE|ACT_DOWN
		.byte 122,$9c,	ACT_MOVE|ACT_UP
		.byte 188,96,	ACT_MOVE|ACT_LEFT<<2 | ACT_LEFT
actor_init_end:

game_init_sprites:
		ldy #0
		ldx #ACTOR_BLINKY
		jsr game_init_sprite

		ldy #3
		ldx #ACTOR_INKY
		jsr game_init_sprite

		ldy #6
		ldx #ACTOR_PINKY
		jsr game_init_sprite

		ldy #9
		ldx #ACTOR_CLYDE
		jsr game_init_sprite

		ldy #12
		ldx #ACTOR_PACMAN
		jsr game_init_sprite
		rts

game_init_sprite:
		lda actor_init+0,y
		sta actors+actor::sp_x,x
		lda actor_init+1,y
		sta actors+actor::sp_y,x
		lda actor_init+2,y
		sta actors+actor::move,x
;		lda #$10
;		jsr actor_update_shape
		rts

ai_ghost:
		tya
		tax
		jsr actor_center
		bne @soft		; center reached?

		lda actors+actor::move,x
		and #ACT_DIR
		jsr actor_can_move_to_direction
		bcc @soft  ; C=0, can move to

		lda actors+actor::move,x
		eor #ACT_DIR ;? inverse
:	  	sta game_tmp
		jsr actor_can_move_to_direction
		lda game_tmp
		eor #$01	  ; ?left right?
		bcs :-
		lda actors+actor::move,x  ;otherwise stop move
		and #<~ACT_DIR
		ora game_tmp
		sta actors+actor::move,x
		rts
@soft:
		jmp actor_move_soft

actor_strategy:
		cpx #ACTOR_PACMAN
		bne @ghost
		jsr pacman_move
		rts
@ghost:
		rts ; TODO FIXME
;		jmp ai_ghost

_save_irq:  .res 2

.data
maze:
  .include "pacman.maze.inc"

superfood_x:
	 .byte 4,24,4,24;
superfood_y:
	 .byte 1,1,24,24;

_vectors:	; X, Y adjust
_vec_right:			;00
		.byte 0,$ff	; +0 X, -1 Y, screen is rotated 90 degree clockwise ;)
_vec_left:			;01
		.byte 0, 1
_vec_up:				;10
		.byte $ff,0
_vec_down:			;11
		.byte 1, 0

_text_1up:
		.byte 0, 24, "1UP",0
_text_1up_del:
		.byte 0, 24, "   ",0
_text_pacman:
		.byte 12,15, "PACMAN",0
_text_demo:
		.byte 18,15, "DEMO!",0

_text_player_one:
		.byte 12,17, "PLAYER ONE",0
_text_ready:
		.byte 18,15, "READY!",0
_text_game_over:
		.byte 18,17, "GAME  OVER",0
_delete_message_1:
		.byte 12,17, "          ",0
_delete_message_2:
		.byte 18,17, "          ",0

		.export game_maze
		.export actors
		.import __BSS_RUN__,__BSS_SIZE__
.bss
points:			  	.res 4
input_direction:  .res 1
keyboard_input:	.res 1
actors: 				.res 5*.sizeof(actor)
game_maze=((__BSS_RUN__+__BSS_SIZE__) & $ff00)+$100	; put at the end which is __BSS_SIZE__ and align $100
