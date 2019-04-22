      .export game
      .export game_maze

      .include "pacman.inc"

      .import gfx_vram_xy
      .import gfx_blank_screen
      .import gfx_hires_off
      .import gfx_digit,gfx_digits
      .import gfx_hex_digits
      .import gfx_text
        
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
      bra @waitkey
      
      jsr krn_getkey
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
      
      bgcolor Color_Gray
      
      vdp_vram_w sprite_attr
      lda #<sprite_tab_attr
      ldy #>sprite_tab_attr
      ldx #4*2*5
      jsr vdp_memcpys

      dec game_state+GameState::frames
      lda game_state+GameState::frames
      and #07
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
      bne @exit
      lda sound_play_state
;      bne @detect_joystick
      draw_text _delete_message_1
      draw_text _delete_message_2
      lda #STATE_PLAYING
      sta game_state
@detect_joystick:
      jsr joystick_detect
      beq @exit
      sta joystick_port
@exit:
      rts
      
game_ready:
      lda game_state
      cmp #STATE_READY
      bne @exit
      draw_text _text_player_one
      draw_text _text_ready
      lda #STATE_READY_WAIT
      sta game_state
@exit:
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
      

input_direction: .res 1,0

actors_move:
      ldx #0;actor_pacman
      jsr actor_update_charpos
      jsr pacman_input
      jsr actor_move
      
      ;stz actors+actor::turn,x  ; stop turning
      ;stz actors+actor::move,x  ; TEST - single step
      
      rts
      
      ; .A direction
pacman_cornering:
      ldy actors+actor::sprite,x
      pha
      and #$01  ;bit 0 set , either +x or +y, down or left
      bne @l1
      lda #$06
@l1:
      eor #$06
      sta game_tmp2
      pla ;1010
      and #ACT_MOVE_UP_OR_DOWN
      bne @_up_or_down
      lda sprite_tab_attr+SPRITE_Y,y
      bra @l_cmp
@_up_or_down:
      lda sprite_tab_attr+SPRITE_X,y
@l_cmp:
;      eor game_tmp2 ; 1100 eor 000 1011
      and #$07
      cmp #$04    ; 100 - center pos, <100 pre-turn, >100 post-turn
@exit:
      rts

actor_move:
      lda actors+actor::move,x
      jsr pacman_cornering
      bne @actor_move_soft      ; center reached?
      
      jsr pacman_feed
      
;      stz actors+actor::turn,x
      
      lda actors+actor::move,x
      and #ACT_DIR
      jsr actor_can_move_to_direction
      bcc @actor_move_soft  ; C=0, can move to
      
      lda actors+actor::move,x  ;otherwise stop move
      and #<~ACT_MOVE
      sta actors+actor::move,x
      lsr ;set shape of next direction
      lsr
;      jsr pacman_update_shape
      
@actor_move_soft:
      lda actors+actor::move,x
      jsr @actor_move_sprite
@actor_turn_soft:
      lda actors+actor::turn,x
      jsr @actor_move_sprite

@actor_move_sprite:
      bpl @exit
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
      ldy actors+actor::sprite, x
      clc
      adc sprite_tab_attr+SPRITE_Y,y
      sta sprite_tab_attr+SPRITE_Y,y
@exit:
      rts

@actor_shape:
      lda game_state+GameState::frames
      and #$03
      bne @exit
      ldy actors+actor::sprite,x
      lda sprite_tab_attr+SPRITE_N,y
      eor #$04
      sta sprite_tab_attr+SPRITE_N,y
      rts
      
pacman_update_shape:
      and #ACT_DIR
      asl
      tay
      lda pacman_shapes,y
      ldy actors+actor::sprite,x
      sta sprite_tab_attr+SPRITE_N,y
      rts
      
pacman_feed:
      ;TODO
      lda #$10
      sta points+3  ;10pts
      jsr add_score

     rts
;
;###-####
;####-###
;#####-##
;######-#
;###C###-
;######-#
;#####-##
;####-###
;

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
      bcc @exit                           ; key/joy input ?
      sta input_direction
      jsr actor_can_move_to_direction     ; C=0 can move
      bcs @set_input_dir_to_next_dir
      
      ;current dir == input dir ?
      lda actors+actor::move,x
      cmp input_direction
      beq @set_input_dir_to_current_dir    ;nothing...
      ;current dir == inverse input dir ?
      and #ACT_DIR
      eor #ACT_MOVE_INVERSE
      cmp input_direction
      beq @set_input_dir_to_current_dir
      
      bra @set_input_dir_to_current_dir
      lda input_direction
;      jsr pacman_cornering
;      beq @set_input_dir_to_current_dir       ; center position, no pre-/post-turn
      lda #0
      bcc @l_turn           ; pre-turn?
      lda #ACT_MOVE_INVERSE
@l_turn:
      eor actors+actor::move,x
      and #ACT_DIR
      ora #ACT_TURN
      sta actors+actor::turn,x
      
;@reset_turn:
;      stz actors+actor::turn,x
@set_input_dir_to_current_dir:
      lda #ACT_MOVE
      ora input_direction
      sta actors+actor::move,x
;      jsr pacman_update_shape
      
@set_input_dir_to_next_dir: ; bit 3-2
      lda input_direction
      asl
      asl
      sta game_tmp
      lda actors+actor::move,x
      and #<~ACT_NEXT_DIR
      ora game_tmp
      sta actors+actor::move,x
@exit:
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
      jsr krn_getkey
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
      beq @exit; nothing pressed
      sec
      bit #JOY_RIGHT
      beq @r
      bit #JOY_LEFT
      beq @l
      bit #JOY_DOWN
      beq @d
      bit #JOY_UP
      beq @u
@exit:
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
      
      lda game_tmp2
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
      inx ; TODO FIXME maybe little too hacky
      jsr calc_maze_ptr
      dex
      rts
      
calc_maze_ptr:
      lda actors+actor::ypos, x; ;.Y * 32
      asl
      asl
      asl
      asl
      asl
      ora actors+actor::xpos, x
      clc
      adc #<game_maze
      sta p_maze+0
      lda actors+actor::ypos, x ; .Y * 32
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
      beq @exit
      draw_text _delete_message_1
      draw_text _delete_message_2
@exit:
      rts

game_playing:
      lda game_state
      cmp #STATE_PLAYING
      bne @exit

      jsr game_demo
      
      jsr actors_move
      jsr draw_score
      
@exit:
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
      lda #0
      sta crs_x
      lda #20
      sta crs_y
      lda game_state+GameState::score+0
      jsr gfx_digit
      lda game_state+GameState::score+1
      jsr gfx_digits
      lda game_state+GameState::score+2
      jsr gfx_digits
      lda game_state+GameState::score+3
      jsr gfx_digits
      rts
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
      lda food
      eor #1<<3|1<<0
      ora #1<<2|1<<1
      sta food
      tax
      vdp_vram_w (ADDRESS_GFX3_SCREEN+4+1*32)
      stx a_vram
      vdp_vram_w (ADDRESS_GFX3_SCREEN+24+1*32)
      stx a_vram
      vdp_vram_w (ADDRESS_GFX3_SCREEN+4+24*32)
      stx a_vram
      vdp_vram_w (ADDRESS_GFX3_SCREEN+24+24*32)
      stx a_vram
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
      jsr display_maze
      
      actor 0, 80, 48, Color_Yellow ;pacman
      
      actor 1, 80, 48,  Color_Blinky  ;blinky
      actor 2, 120, 80, Color_Pinky  ;pinky
      actor 3, 140, 110, Color_Inky ;inky
      actor 4, 160, 160, Color_Clyde ;clyde
      
      ldx #3
      lda #Char_Superfood
:     sta food,x
      dex
      bpl :-
      
      lda #ACT_MOVE|ACT_RIGHT
      sta actors+actor::move
      
      lda #STATE_READY
      sta game_state
      
      rts
      
display_maze:
      vdp_vram_w ADDRESS_GFX3_SCREEN
      lda #<game_maze
      ldy #>game_maze
      ldx #4
      jsr vdp_memcpy
      
      rts

sprite_tab_attr:
;      .byte 96, 188,   $18*4, 0
;      .byte 4, 12+28*8,     $10*4, 0 ;offset y=+4,y=+4
      .byte 4+1*8, 4+1*8,     $18*4, 0 ;offset y=+4,y=+4

      .byte $d9, $d9, 0, 0    ; blank
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

joystick_port:
      .byte JOY_PORT1
      

points:
    .res 4, 0
      
food:
    .tag actor
    .tag actor
    .tag actor
    .tag actor
    
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
    
    
_cornering:
      .byte $07 ; r
      .byte $00 ; l
      .byte $07 ; u
      .byte $00 ; d
      
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
      .byte $11*4,$10*4 ;r  000
      .byte $13*4,$12*4 ;l  010
      .byte $15*4,$14*4 ;u  100 
      .byte $17*4,$16*4 ;d  110

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
