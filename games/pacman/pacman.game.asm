      .setcpu "6502"
      
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
;      jsr gfx_hires_off
      cli

game_reset:
      lda #STATE_INIT
      sta game_state+GameState::state
@waitkey:
      jsr io_getkey
      bcc :+
      sta keyboard_input
:
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
      bpl	game_isr_exit
      
      bgcolor Color_Gray
      
      jsr game_init
      jsr game_ready
      jsr game_ready_wait
      jsr game_playing
      jsr game_level_cleared
      jsr game_game_over

      bgcolor Color_Cyan
      inc game_state+GameState::frames
      jsr gfx_update

game_isr_exit:

.ifdef __DEBUG
      bgcolor Color_Bg
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
      ;   (input direction != current direction)?
      ;   y - input direction inverse current direction?
      ;       y - set current direction = inverse input direction
      ;       n - can move to input direction?
      ;           y - pre-turn? (+4px)
      ;                 y - set turn direction = current direction
      ;                   - set turn bit on
      ;             - post-turn?  (-3px)
      ;                 y - set turn direction = inverse current direction (eor)
      ;                     set turn bit on
      ;             - set current direction = input direction
      ;             - change pacman shape
      ;         - set next direction = input direction
      ;
      ; block reached? (center)
      ;   y - is turn?
      ;         y - reset turn bit
      ;           - reset turn direction
      ;     - can move to current direction?
      ;         n - change pacman shape to next direction
      ;             reset move bit
      ;
      ; soft move current direction
      ; turn bit on?
      ;   y - soft move to turn direction
      

actors_move:
      ldx #0;actor_pacman
      jsr actor_update_charpos
      jsr pacman_input
      jsr actor_move
      
      ldx #ACTOR_BLINKY
      jsr ghost_move
      ldx #ACTOR_INKY
      jsr ghost_move
      ldx #ACTOR_PINKY
      jsr ghost_move
      ldx #ACTOR_CLYDE
      jsr ghost_move
      rts
      
ghost_move:
      jsr actor_update_charpos
      jmp actor_move_dir
      
      ; .A new direction
pacman_cornering:
      pha
      lda actors+actor::move,x
      and #$01  ;bit 0 set , either +x or +y, down or left
      beq @l1
      lda #$07
@l1:
      eor #$07
      sta game_tmp2
      pla
      
l_test:
      ldy actors+actor::sprite,x
      
      and #ACT_MOVE_UP_OR_DOWN
      bne l_up_or_down
l_left_or_right:
      lda sprite_tab_attr+SpriteTab::xpos,y
      jmp l_compare
l_up_or_down:
      lda sprite_tab_attr+SpriteTab::ypos,y
l_compare:
      eor game_tmp2
      and #$07
      cmp #$04    ; 100 - center pos, <100 pre-turn, >100 post-turn
      rts
actor_center:
      pha
      lda #0
      sta game_tmp2
      pla
      eor #ACT_MOVE_UP_OR_DOWN
      jmp l_test
      
actor_move:
      lda actors+actor::turn,x  ; turning?
      bpl actor_move_dir
      lda actors+actor::turn,x
      jsr actor_center
      bne @actor_turn_soft
      lda actors+actor::turn,x
      and #<~ACT_TURN
      sta actors+actor::turn,x
@actor_turn_soft:
      lda actors+actor::turn,x
      jsr actor_move_sprite
      
actor_move_dir:
      lda actors+actor::move,x
      bpl @rts
      txa
      pha
      jsr actor_strategy
      pla
      tax
@rts: rts

actor_move_soft:
      jsr pacman_shape_move
      
      lda actors+actor::move,x
actor_move_sprite:
      bpl @rts
      and #ACT_DIR
      asl
      tay
      pha
      lda _vectors+0, y
      ldy actors+actor::sprite, x
      clc
      adc sprite_tab_attr+SpriteTab::xpos,y
      sta sprite_tab_attr+SpriteTab::xpos,y
      sta sprite_tab_attr+4+SpriteTab::xpos,y
      pla
      tay
      lda _vectors+1, y
      sta game_tmp
      ldy actors+actor::sprite, x
@y_add:
      clc
      adc sprite_tab_attr+SpriteTab::ypos,y
      cmp gfx_Sprite_Off
      bne @y_sta
      lda game_tmp
      eor #$10
      jmp @y_add
@y_sta:
      sta sprite_tab_attr+SpriteTab::ypos,y
      sta sprite_tab_attr+4+SpriteTab::ypos,y
@rts: rts
      
pacman_shape_move:
      lda game_state+GameState::frames
      lsr
      and #$03
      sta game_tmp
      lda actors+actor::move,x
      and #ACT_DIR
      asl
      asl
      clc
      adc game_tmp
pacman_update_shape:
      tay
      lda pacman_shapes,y
      ldy actors+actor::sprite,x
      sta sprite_tab_attr+SpriteTab::shape,y
      rts
      
actor_shape_move:
      lda game_state+GameState::frames
      lsr
      lsr
      lsr
      and #$01
actor_shape_move_direct:
      sta game_tmp
      lda actors+actor::move,x
      and #ACT_DIR
      asl
      asl
      clc
      adc game_tmp
      tay
      pha
      lda ghost_shapes,y
      ldy actors+actor::sprite,x
      sta sprite_tab_attr+SpriteTab::shape,y
      pla
      tay
      lda ghost_shapes+2,y
      ldy actors+actor::sprite,x
      sta sprite_tab_attr+4+SpriteTab::shape,y
      rts

pacman_move:
      tya
      tax
      jsr actor_center
      bne @actor_move_soft      ; center reached?

      jsr pacman_collect

      lda actors+actor::move,x
      and #ACT_DIR
      jsr actor_can_move_to_direction
      bcc @actor_move_soft  ; C=0, can move to
      
      lda actors+actor::move,x  ;otherwise stop move
      and #<~ACT_MOVE
      sta actors+actor::move,x
      and #ACT_NEXT_DIR         ;set shape of next direction
      jmp pacman_update_shape
@actor_move_soft:
      jmp actor_move_soft
      
pacman_collect:
      lda actors+actor::xpos,x
      ldy actors+actor::ypos,x
      jsr calc_maze_ptr_ay
      ldy #0
      lda (p_maze),y
      cmp #Char_Food
      bne :+
      lda #Points_Food
      jmp erase_and_score
:     cmp #Char_Superfood
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

      ; in:   .A - direction
      ; out:  .C=0 can move, C=1 can not move to direction
actor_can_move_to_direction:
      jsr actor_update_charpos_direction  ; update dir char pos
      jsr calc_maze_ptr_direction         ; calc ptr to next char at input direction
      ldy #0
      lda (p_maze),y
      cmp #Char_Bg
      rts
      
pacman_input:
      jsr get_input
      bcc @rts                           ; key/joy input ?
      sta input_direction
      jsr actor_can_move_to_direction     ; C=0 can move
      bcs @set_input_dir_to_next_dir

;      lda actors+actor::turn,x
 ;     bmi @rts

      ;current dir == input dir ?
      lda actors+actor::move,x
      and #ACT_DIR
      cmp input_direction
      beq @set_input_dir_to_next_dir    ;nothing...
      ;current dir == inverse input dir ?
      eor #ACT_MOVE_INVERSE
      cmp input_direction
      beq @set_input_dir_to_current_dir

      lda actors+actor::ypos            ;is tunnel ?
      beq @rts                          ;ypos=0
      cmp #26                           ;... or >=26
      bcs @rts                          ;ignore input
      
      lda input_direction
      jsr pacman_cornering
      beq @set_input_dir_to_current_dir   ; Z=1 center position, no pre-/post-turn
      lda #0
      bcc @l_turn                         ; C=0 pre-turn
      lda #ACT_MOVE_INVERSE               ; C=1 post-turn
@l_turn:
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
@rts:
      rts

actor_update_charpos_direction:
      asl
      tay
      lda actors+actor::xpos,x
      clc
      adc _vectors+0,y
      sta actors+actor::xpos_dir,x
      
      lda actors+actor::ypos,x
      clc
      adc _vectors+1,y
      sta actors+actor::ypos_dir,x
      rts
      
actor_update_charpos: ;offset x=+4,y=+4  => x,y 2,1 => 4+2*8, 4+1*8
      ldy actors+actor::sprite,x
      lda sprite_tab_attr+SpriteTab::xpos,y
      clc
      adc gfx_Sprite_Adjust_X  ; x adjust
      lsr
      lsr
      lsr
      sta actors+actor::xpos,x
      lda sprite_tab_attr+SpriteTab::ypos,y
      clc
      adc gfx_Sprite_Adjust_Y  ; y adjust
      lsr 
      lsr
      lsr
      sta actors+actor::ypos,x
      rts
      
      ; C=0 if any valid key or joystick input, A=ACT_xxx
get_input:
      lda keyboard_input
      jmp io_player_direction

debug:
      pha
      txa
      pha
      lda #11
      sta sys_crs_x
      lda #0
      sta sys_crs_y
      lda Color_Text
      sta text_color
      lda input_direction
      jsr out_hex_digits
      lda actors+actor::move
      jsr out_hex_digits
      lda actors+actor::turn
      jsr out_hex_digits
      lda actors+actor::xpos
      jsr out_hex_digits
      lda actors+actor::ypos
      jsr out_hex_digits
      lda actors+actor::xpos_dir
      jsr out_hex_digits
      lda actors+actor::ypos_dir
      jsr out_hex_digits
      lda sprite_tab_attr+SpriteTab::xpos
      jsr out_hex_digits
      lda sprite_tab_attr+SpriteTab::ypos
      jsr out_hex_digits
      lda keyboard_input
      jsr out_hex_digits
@ex:
      pla
      tax
      pla
      rts

calc_maze_ptr_direction:
      lda actors+actor::xpos_dir,x
      ldy actors+actor::ypos_dir,x
calc_maze_ptr_ay:
      sta sys_crs_x
      sty sys_crs_y
@calc_maze_ptr:
      lda sys_crs_y;actors+actor::ypos, x; ;.Y * 32
      asl
      asl
      asl
      asl
      asl
      ora sys_crs_x;actors+actor::xpos, x
      ;clc
;      adc #<__RAM_LAST__
      sta p_maze+0
      lda sys_crs_y;actors+actor::ypos, x ; .Y * 32
      lsr ; div 8 -> page offset 0-2
      lsr
      lsr
      clc
      adc #>game_maze
      sta p_maze+1
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
      jsr animate_food
      jsr draw_scores
      
      lda actors+actor::dots    ; all dots collected ?
      bne @rts

      lda #Sprite_Pattern_Pacman
      sta sprite_tab_attr+SPRITE_NR_PACMAN+SpriteTab::shape
      lda gfx_Sprite_Off
      sta sprite_tab_attr+SPRITE_NR_GHOST+SpriteTab::ypos
      
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
@l:   lda game_state+GameState::score,y
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
      

animate_food:
      lda Color_Food
      sta text_color
      lda game_state+GameState::frames
      and #$07
      bne @rts
      ldx #0
@l1:  lda superfood,x
      inx
      ldy superfood,x
      jsr calc_maze_ptr_ay
      ldy #0
      lda (p_maze),y
      cmp #Char_Blank ; eaten?
      beq @next
      eor #$03
      sta (p_maze),y
      jsr gfx_charout
@next:
      inx
      cpx #superfood_end-superfood
      bne @l1
@rts:
      rts
      
      
animate_ghosts:
      ldx #ACTOR_BLINKY
      jsr actor_shape_move
      ldx #2*.sizeof(actor)
      jsr actor_shape_move
      ldx #3*.sizeof(actor)
      jsr actor_shape_move
      ldx #4*.sizeof(actor)
      jsr actor_shape_move
      rts
      
.macro actor_colors _nr, _color
      .local _nr,_color
      ;color tab
      vdp_vram_w (sprite_color+_nr*16)
      lda #(_color)
      jsr sprite_tab_color
.endmacro

game_init:
      lda game_state+GameState::state
      cmp #STATE_INIT
      beq @init
      rts
@init:
      lda #0
      sta game_state+GameState::frames
      
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
:     lda maze+$300,y
      sta game_maze+$300,y
      lda #Char_Blank
      sta game_maze+$300+1*32,y
      iny
      cpy #2*32
      bne :-
      
      lda #MAX_DOTS
      sta actors+actor::dots
    
      lda #0
      sta game_state+GameState::score+0
      sta game_state+GameState::score+1
      sta game_state+GameState::score+2
      sta game_state+GameState::score+3
      lda #STATE_READY
      sta game_state+GameState::state
      
      jmp gfx_display_maze
      
game_init_sprites:
      ldy #0
@sprites:
      tya
      pha
      asl
      asl
      tay
      asl
      tax
      lda sprite_init+0,y
      sta sprite_tab_attr+0+SpriteTab::xpos,x
      sta sprite_tab_attr+4+SpriteTab::xpos,x
      lda sprite_init+1,y
      sta sprite_tab_attr+0+SpriteTab::ypos,x
      sta sprite_tab_attr+4+SpriteTab::ypos,x
      lda #0
      sta sprite_tab_attr+0+SpriteTab::shape,x
      sta sprite_tab_attr+4+SpriteTab::shape,x
      lda sprite_init+2,y
      sta actors+actor::move,x
      txa
      sta actors+actor::sprite,x  ; x is sprite number
      ; TODO FIXME ugly code...
      cpx #SPRITE_NR_PACMAN
      bne @ghost
      lda #Sprite_Pattern_Pacman
      sta sprite_tab_attr+SpriteTab::shape,x
      jmp @next
@ghost:
      lda #0
      jsr actor_shape_move_direct
@next:
      pla
      tay
      iny
      cpy #5
      bne @sprites
      
      lda #0
      sta sprite_tab_attr+1*4+SpriteTab::xpos
      sta sprite_tab_attr+1*4+SpriteTab::ypos
      sta sprite_tab_attr+1*4+SpriteTab::shape
      rts
 
sprite_init: ;x,y,init direction,color
      .byte 188,96,   ACT_MOVE|ACT_LEFT<<2 | ACT_LEFT, ACTOR_PACMAN ;offset y=+4,y=+4  ; pacman
      .byte 92,95,    ACT_MOVE|ACT_LEFT, ACTOR_BLINKY
;      .byte 116,111,  ACT_MOVE|ACT_UP,   ACTOR_INKY
       .byte 116,108,  ACT_MOVE|ACT_UP,   ACTOR_INKY
;      .byte 116,95,   ACT_DOWN, ACTOR_BLINKY
      .byte 116,92,   ACT_MOVE|ACT_DOWN, ACTOR_PINKY
;      .byte 116,79,   ACT_UP,   ACTOR_CLYDE
      .byte 116,76,   ACT_MOVE|ACT_UP,   ACTOR_CLYDE
sprite_init_end:

ai_ghost:
      tya
      tax
      jsr actor_center
      bne @soft      ; center reached?

      lda actors+actor::move,x
      and #ACT_DIR
      jsr actor_can_move_to_direction
      bcc @soft  ; C=0, can move to
      
      lda actors+actor::move,x
      eor #ACT_DIR ;? inverse
:     sta game_tmp
      jsr actor_can_move_to_direction
      lda game_tmp
      eor #$01     ; ?left right?
      bcs :-
      lda actors+actor::move,x  ;otherwise stop move
      and #<~ACT_DIR
      ora game_tmp
      sta actors+actor::move,x
      rts
@soft:
      jmp actor_move_soft

actor_strategy:
      cpx #0
      bne @ghost
      jmp pacman_move
@ghost:
      rts ; TODO FIXME
;      jmp ai_ghost

_save_irq:  .res 2

.data
maze:
  .include "pacman.maze.inc"

input_direction:  .res 1,0
keyboard_input:   .res 1,0

points:           .res 4, 0

superfood:
    .byte 4,1;,Char_Superfood
    .byte 24,1;,Char_Superfood
    .byte 4,24;,Char_Superfood
    .byte 24,24;,Char_Superfood
superfood_end:

_vectors:   ; X, Y adjust
_vec_right:         ;00
      .byte 0,$ff   ; +0 X, -1 Y, screen is rotated 90 degree clockwise ;)
_vec_left:          ;01
      .byte 0, 1
_vec_up:            ;10
      .byte $ff,0
_vec_down:          ;11
      .byte 1, 0

pacman_shapes:
      .byte $10*4+4,$10*4,$18*4,$10*4 ;r  00
      .byte $12*4+4,$12*4,$18*4,$12*4 ;l  01
      .byte $14*4+4,$14*4,$18*4,$14*4 ;u  10 
      .byte $16*4+4,$16*4,$18*4,$16*4 ;d  11

ghost_shapes:
      .byte $00*4,$00*4+4,$08*4,$08*4 ;r  00
      .byte $02*4,$02*4+4,$09*4,$09*4 ;l  01
      .byte $04*4,$04*4+4,$0a*4,$0a*4 ;u  10 
      .byte $06*4,$06*4+4,$0b*4,$0b*4 ;d  11

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

      .export sprite_tab_attr
      .export game_maze
      .import __BSS_RUN__,__BSS_SIZE__

.bss
actors: .res (5*.sizeof(actor))
sprite_tab_attr:  .res 5*4*2
sprite_tab_attr_end:
game_maze=((__BSS_RUN__+__BSS_SIZE__) & $ff00)+$100
