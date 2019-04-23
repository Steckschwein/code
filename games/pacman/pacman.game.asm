      .export game
      .export game_maze

      .include "pacman.inc"

      .import gfx_vram_xy
      .import gfx_vram_ay
      .import gfx_blank_screen
      .import gfx_hires_off
      .import gfx_digit,gfx_digits
      .import gfx_hex_digits
      .import gfx_text
      .import gfx_charout
        
      .import sound_init
      .import sound_init_game_start
      .import sound_play
      .import sound_play_state
      
      .import game_state
      
game:
      sei
      jsr gfx_hires_off
      
      set_irq game_isr, _save_irq
      
      jsr game_init
      jsr sound_init_game_start
      cli

@waitkey:
      lda keyboard_input
      cmp #KEY_ESCAPE
      bne @waitkey
      
      jsr sound_init
      
      sei
      restore_irq _save_irq
      cli
      rts

game_welldone:
      ; just update palette color
      rts
      
color_welldone:
.res  Color_Gray
  
      
game_isr:
      save
      bit	a_vreg
      bpl	game_isr_exit
      
      bgcolor Color_Inky
      
      vdp_vram_w sprite_attr
      lda #<sprite_tab_attr
      ldy #>sprite_tab_attr
      ldx #4*2*5
      jsr vdp_memcpys

      dec game_state+GameState::frames
      lda game_state+GameState::frames
      and #$07
      bne :+
      jsr animate_ghosts
      jsr animate_food
:     
      bgcolor Color_Cyan
      jsr sound_play
      
      bgcolor Color_Yellow
      jsr game_ready
      jsr game_ready_wait
      jsr game_playing
      jsr game_gameover

game_isr_exit:

.if DEBUG
      bgcolor Color_Bg
      jsr debug
.endif

      restore
      rti

game_ready_wait:
      lda game_state
      cmp #STATE_READY_WAIT
      bne @rts
      lda sound_play_state
;      bne @detect_joystick
      draw_text _delete_message_1
      draw_text _delete_message_2
      lda #STATE_PLAYING
      sta game_state
@detect_joystick:
      jsr joystick_detect
      beq @rts
      sta joystick_port
@rts:
      rts
      
game_ready:
      lda game_state
      cmp #STATE_READY
      bne @rts
      draw_text _text_player_one
      draw_text _text_ready
      lda #STATE_READY_WAIT
      sta game_state
@rts:
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
      

keyboard_read:
      jsr krn_getkey
      sta keyboard_input
      rts

actors_move:
      ldx #0;actor_pacman
      jsr pacman_input
      jsr actor_update_charpos
      jsr actor_move
      rts
      
      ; .A direction
pacman_cornering:
      ldy actors+actor::sprite,x
      pha
      lda actors+actor::move,x
      and #$01  ;bit 0 set , either +x or +y, down or left
      beq @l1
      lda #$07
@l1:
      eor #$07
      sta game_tmp2
      pla
      
      and #ACT_MOVE_UP_OR_DOWN
      bne l_up_or_down
l_left_or_right:
      lda sprite_tab_attr+SPRITE_X,y
      bra l_compare
l_up_or_down:
      lda sprite_tab_attr+SPRITE_Y,y
l_compare:
      eor game_tmp2
      and #$07
      cmp #$04    ; 100 - center pos, <100 pre-turn, >100 post-turn
      rts
pacman_center:
      stz game_tmp2
      and #ACT_MOVE_UP_OR_DOWN
      bne l_left_or_right
      bra l_up_or_down
      
actor_move:
      lda actors+actor::turn,x  ; turning?
      bpl @actor_move_dir
      
      jsr pacman_center
      bne @actor_turn_soft
      stz actors+actor::turn,x
@actor_turn_soft:
      lda actors+actor::turn,x
      jsr @actor_move_sprite
      
@actor_move_dir:
      lda actors+actor::move,x
      jsr pacman_center
      bne @actor_move_soft      ; center reached?
      
      jsr pacman_collect

      lda actors+actor::move,x
      and #ACT_DIR
      jsr actor_can_move_to_direction
      bcc @actor_move_soft  ; C=0, can move to
      
      lda actors+actor::move,x  ;otherwise stop move
      and #<~ACT_MOVE
      sta actors+actor::move,x

      and #ACT_NEXT_DIR       ;set shape of next direction
      jmp pacman_update_shape
      
@actor_move_soft:
      jsr actor_shape

      lda actors+actor::move,x
@actor_move_sprite:
      bpl @rts
      and #ACT_DIR
      asl
      tay
      phy
      lda _vectors+0, y
      ldy actors+actor::sprite, x
      clc
      adc sprite_tab_attr+SPRITE_X,y
      sta sprite_tab_attr+SPRITE_X,y
      ply
      lda _vectors+1, y
      sta game_tmp
      ldy actors+actor::sprite, x
@y_add:
      clc
      adc sprite_tab_attr+SPRITE_Y,y
      cmp #SPRITE_OFF+$08; 212 line mode
      bne :+
      lda game_tmp
      eor #$10
      bra @y_add
:
      sta sprite_tab_attr+SPRITE_Y,y
@rts:
      rts
      
actor_shape:
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
      sta sprite_tab_attr+SPRITE_N,y
      rts

pacman_collect:
      lda actors+actor::xpos,x
      ldy actors+actor::ypos,x
      jsr calc_maze_ptr_ay
      lda (p_maze)
      cmp #Char_Food
      bne :+
      lda #Points_Food
      jmp erase_and_score
:     cmp #Char_Superfood
      beq @collect_superfood
      eor #%00000011
      cmp #Char_Superfood
      bne @rts
@collect_superfood:
      lda #Points_Superfood
      jmp erase_and_score
      
@rts:
      rts

erase_and_score:
      pha
      lda actors+actor::xpos,x
      sta crs_x
      lda actors+actor::ypos,x
      sta crs_y
      jsr gfx_vram_xy
      lda #Char_Blank
      sta a_vram
      sta (p_maze)
      
      pla
      sta points+3  ;10pts
      jmp add_scores

      ; in:   .A - direction
      ; out:  .C=0 can move, C=1 can not move to direction
actor_can_move_to_direction:
      jsr actor_update_charpos_direction  ; update dir char pos
      jsr calc_maze_ptr_direction         ; calc ptr to next char at input direction
      lda (p_maze)
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
      beq @set_input_dir_to_current_dir       ; center position, no pre-/post-turn
      lda #0
      bcc @l_turn           ; C=0 pre-turn?
      lda #ACT_MOVE_INVERSE ; C=1 post-turn
@l_turn:
      eor actors+actor::move,x  ; current direction
      and #ACT_DIR
      ora #ACT_TURN
      sta actors+actor::turn,x
      
@set_input_dir_to_current_dir:
      lda input_direction
      ora #ACT_MOVE
      sta actors+actor::move,x
 ;     jsr pacman_update_shape
      
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
      lda sprite_tab_attr+SPRITE_X,y
      clc
      adc #SPRITE_ADJUST  ; x adjust
      lsr
      lsr
      lsr
      sta actors+actor::xpos,x
      
      lda sprite_tab_attr+SPRITE_Y,y
      clc
      adc #SPRITE_ADJUST  ; y adjust
      lsr 
      lsr
      lsr
      sta actors+actor::ypos,x
      
      rts
      
      
      ; C=0 if any valid key or joystick input, A=ACT_xxx
get_input:
      jsr keyboard_read
      bcc @joystick
      cmp #KEY_CRSR_RIGHT
      beq @r
      cmp #KEY_CRSR_LEFT
      beq @l
      cmp #KEY_CRSR_DOWN
      beq @d
      cmp #KEY_CRSR_UP
      bne @joystick
@u:   lda #ACT_UP
      rts
@r:   lda #ACT_RIGHT
      rts
@l:   lda #ACT_LEFT
      rts
@d:   lda #ACT_DOWN
      rts
@joystick:
      lda joystick_port
      jsr joystick_read
      and #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP)
      cmp #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP)
      beq @rts; nothing pressed
      sec
      bit #JOY_RIGHT
      beq @r
      bit #JOY_LEFT
      beq @l
      bit #JOY_DOWN
      beq @d
      bit #JOY_UP
      beq @u
@rts:
      clc
      rts
      

debug:
      pha
      phx
      lda #11
      sta crs_x
      lda #0
      sta crs_y
      jsr gfx_vram_xy
      
      lda input_direction
      jsr gfx_hex_digits
      lda actors+actor::move
      jsr gfx_hex_digits
      lda actors+actor::turn
      jsr gfx_hex_digits
      lda actors+actor::xpos
      jsr gfx_hex_digits
      lda actors+actor::ypos
      jsr gfx_hex_digits
      lda actors+actor::xpos_dir
      jsr gfx_hex_digits
      lda actors+actor::ypos_dir
      jsr gfx_hex_digits
      lda (p_maze)
      jsr gfx_hex_digits
      lda sprite_tab_attr+SPRITE_X
      jsr gfx_hex_digits
      lda sprite_tab_attr+SPRITE_Y
      jsr gfx_hex_digits
      
      plx
      pla
      rts

calc_maze_ptr_direction:
      lda actors+actor::xpos_dir,x
      ldy actors+actor::ypos_dir,x
calc_maze_ptr_ay:
      sta crs_x
      sty crs_y
@calc_maze_ptr:
      lda crs_y;actors+actor::ypos, x; ;.Y * 32
      asl
      asl
      asl
      asl
      asl
      ora crs_x;actors+actor::xpos, x
      clc
      adc #<game_maze
      sta p_maze+0
      lda crs_y;actors+actor::ypos, x ; .Y * 32
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
      bit #$07
      bne @l1
      draw_text _text_pacman
      draw_text _text_demo
      rts
@l1:  bit #$08
      beq @rts
      draw_text _delete_message_1
      draw_text _delete_message_2
@rts:
      rts

game_playing:
      lda game_state
      cmp #STATE_PLAYING
      bne @rts

      ;jsr game_demo
      
      jsr actors_move
      jsr draw_scores
@rts:
      rts

add_scores:
      jsr add_score
      ldy #0
@cmp:
      lda game_state+GameState::highscore,y
      cmp game_state+GameState::score,y
      bcc @copy
      iny
      cpy #4
      bne @cmp
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

draw_score:
      sta crs_x
      sty crs_y
      ldy #0
@skip_zeros:
      lda (p_game),y
      beq @skip ;00 ?
      bit #$f0  ;0? ?
      bne @digits
      dec crs_y ;output the 0-9 only
      jsr gfx_digit
      bra @digits_inc
@skip:
      dec crs_y ;skip digits
      dec crs_y
      iny
      cpy #04
      bne @skip_zeros
      rts
@digits:
      lda (p_game),y
      jsr gfx_digits
@digits_inc:
      iny
      cpy #04
      bne @digits
      rts
      
      
draw_scores:
      SetVector (game_state+GameState::score), p_game
      lda #0
      ldy #21
      jsr draw_score
      SetVector (game_state+GameState::highscore), p_game
      lda #0
      ldy #8
      jmp draw_score
      
game_gameover:

      rts

move_ghosts:
      inc sprite_tab_attr+SPRITE_X+2*4
      inc sprite_tab_attr+SPRITE_X+3*4
      inc sprite_tab_attr+SPRITE_X+2*4
      inc sprite_tab_attr+SPRITE_X+3*4

      inc sprite_tab_attr+SPRITE_X+4*4
      inc sprite_tab_attr+SPRITE_X+5*4

      dec sprite_tab_attr+SPRITE_X+6*4
      dec sprite_tab_attr+SPRITE_X+7*4
      dec sprite_tab_attr+SPRITE_X+6*4
      dec sprite_tab_attr+SPRITE_X+7*4
      
      dec sprite_tab_attr+SPRITE_X+8*4
      dec sprite_tab_attr+SPRITE_X+9*4

      inc sprite_tab_attr+SPRITE_Y+0*4
      inc sprite_tab_attr+SPRITE_Y+1*4
      rts
      
      
animate_food:
      lda game_state+GameState::frames
      and #$07
      bne @rts
      ldx #0
@l1:  lda superfood,x
      inx
      ldy superfood,x
      jsr calc_maze_ptr_ay
      lda (p_maze)
      cmp #Char_Blank
      beq @next
      eor #$03
      sta (p_maze)
      jsr gfx_charout
@next:
      inx
      cpx #superfood_end-superfood
      bne @l1
@rts:
      rts
      
      
animate_ghosts:
      ;test
      lda sprite_tab_attr+SPRITE_N+0*4
      eor #04
;      sta sprite_tab_attr+SPRITE_N+0*4
      
      lda sprite_tab_attr+SPRITE_N+8*4
      eor #04
      sta sprite_tab_attr+SPRITE_N+8*4
      lda sprite_tab_attr+SPRITE_N+2*4
      eor #04
      sta sprite_tab_attr+SPRITE_N+2*4
      lda sprite_tab_attr+SPRITE_N+4*4
      eor #04
      sta sprite_tab_attr+SPRITE_N+4*4
      lda sprite_tab_attr+SPRITE_N+6*4
      eor #04
      sta sprite_tab_attr+SPRITE_N+6*4
      rts
      
.macro actor _nr, _x, _y, _color
      .local _nr,_x,_y,_color
      vdp_vram_w (sprite_attr+_nr*2*4)
      ldx #_x
      ldy #_y
      jsr sprite_tab_attrs
      ;color tab
      vdp_vram_w (sprite_color+_nr*2*16)
      lda #_color
      jsr sprite_tab_color
      lda #$40 | $0e  ; CC | 2nd color
      jsr sprite_tab_color
.endmacro

game_init:
      vdp_vram_w (ADDRESS_GFX3_SCREEN)
      lda #<game_maze
      ldy #>game_maze
      ldx #4
      jsr vdp_memcpy
      vdp_vram_w (ADDRESS_GFX3_SCREEN+4*$100-$20)  ;blank the last line in the "scren page", it's displayed on top of the screen due to display adjust
      lda #Char_Blank
      ldx #$20
      jsr vdp_fills
      
      
      actor 0, 80, 48, Color_Yellow ;pacman
      
      actor 1, 80, 48,  Color_Blinky  ;blinky
      actor 2, 120, 80, Color_Pinky   ;pinky
      actor 3, 140, 110, Color_Inky   ;inky
      actor 4, 160, 160, Color_Clyde  ;clyde
      
      lda #ACT_MOVE|ACT_LEFT<<2 | ACT_LEFT ; move left, next dir left
      sta actors+actor::move
      lda #231
      sta actors+actor::dots
      
      lda #STATE_READY
      sta game_state
      rts

sprite_tab_attr:
      .byte 96, 188,  $18*4, 0 ;offset y=+4,y=+4

      .byte $d0, $d9, 0, 0    ; blank
      .byte 95, 92,   2*4, 0  ; 2,3/9x4 left, 0,1/8x4 right, 4/$ax4 up, 6/$bx4 down, 
      .byte 95, 92,   9*4, 0
      .byte 95, 116,  6*4, 0
      .byte 95, 116,  $b*4, 0
      .byte 111, 116, 4*4, 0
      .byte 111, 116, $a*4, 0
      .byte 79, 116,  4*4, 0
      .byte 79, 116,  $a*4, 0
      
      
_sprite_tab_attr:
      vdp_wait_l
      sty a_vram
      vdp_wait_l
      stx a_vram
      vdp_wait_l
      sta a_vram
      vdp_wait_l
      stz a_vram
      rts
      
sprite_tab_attrs:
      lda #0
      jsr _sprite_tab_attr
      lda #8*4
      jmp _sprite_tab_attr
      
sprite_tab_color:
      ldx #16     ;16 colors per line
@l1:  vdp_wait_l
      sta a_vram
      dex
      bne @l1
      rts

_save_irq:  .res 2
  
.data
.align 256
game_maze:
      .include "pacman.maze.inc"

joystick_port:    .byte JOY_PORT1
input_direction:  .res 1,0
keyboard_input:   .res 1,0
      
points:           .res 4, 0

superfood:
    .byte 4,1;,Char_Superfood
    .byte 24,1;,Char_Superfood
    .byte 4,24;,Char_Superfood
    .byte 24,24;,Char_Superfood
superfood_end:

actors:
actor_pacman:
    ;.tag actor
    .byte 0   ;xpos
    .byte 0   ;xpos_dir
    .byte 0   ;ypos
    .byte 0   ;ypos_dir
    .byte 0   ;move
    .byte 0   ;turn
    .byte 0   ;sprite
    .byte 0   ;dots
    
actor_ghosts:
actor_blinky:
    ;.tag actor
    .byte 12  ;ypos
    .byte 12  ;xpos
    .byte 0   ;state
    .byte 0
actor_inky:
;    .tag actor
    .byte 12  ;ypos
    .byte 12  ;xpos
    .byte 0   ;state
    .byte 0
actor_pinky:
;    .tag actor
    .byte 12  ;ypos
    .byte 12  ;xpos
    .byte 0   ;state
    .byte 0
actor_clyde:
;    .tag actor
    .byte 12  ;ypos
    .byte 12  ;xpos
    .byte 0   ;state
    .byte 0
    
    
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
      .byte $10*4+4,$10*4,$18*4,$10*4 ;r  000
      .byte $12*4+4,$12*4,$18*4,$12*4 ;l  010
      .byte $14*4+4,$14*4,$18*4,$14*4 ;u  100 
      .byte $16*4+4,$16*4,$18*4,$16*4 ;d  110

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
