      .export game
      .export game_maze

      .include "pacman.inc"

      .import gfx_vram_xy
      .import gfx_blank_screen
      .import gfx_hires_off
      .import gfx_digits
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

      bgcolor Color_Bg

      restore
      rti

game_ready_wait:
      lda game_state
      cmp #STATE_READY_WAIT
      bne @exit
      lda sound_play_state
      bne @exit
      
      draw_text _delete_message_1
      draw_text _delete_message_2
      
      
      lda #STATE_PLAYING
      sta game_state
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
      
ACT_MOVE    = 1<<7
ACT_DIRECTION=1<<1 | 1<<0
ACT_RIGHT   = 0
ACT_LEFT    = 1
ACT_UP      = 2
ACT_DOWN    = 3

move_actor:
      lda actors+actor::state, x
      bpl @exit
      and #ACT_DIRECTION
      asl
      sta game_tmp
      lda game_state+GameState::frames
      bit #$03
      bne @move_pos
      lda sprite_tab_attr+SPRITE_N,x
      eor #4
      sta sprite_tab_attr+SPRITE_N,x
      
@move_pos:
      jsr set_maze_ptr
      lda (p_game1)
      cmp #Char_Bg
      bcs @move_stop
      
      ldy game_tmp
      lda _vectors+0, y
      clc
      adc sprite_tab_attr+SPRITE_X,x
      sta sprite_tab_attr+SPRITE_X,x
      lda _vectors+1, y
      clc
      adc sprite_tab_attr+SPRITE_Y,x
      sta sprite_tab_attr+SPRITE_Y,x
      
      lda sprite_tab_attr+SPRITE_Y,x
      lsr
      lsr
      lsr
      sta actors+actor::ypos,x
      rts
      
@move_stop:
      lda actors+actor::state, x
;      eor #ACT_LEFT
 ;     ora #ACT_MOVE
      and #!(ACT_MOVE)
      sta actors+actor::state, x
      and #03
      asl 
      tax
      lda pacman_shapes,x
      sta sprite_tab_attr+SPRITE_N
      
      rts
      
      
      lda _vectors+0, y
      clc
      adc actors+actor::xpos, x
      sta actors+actor::xpos, x
      lda _vectors+1, y
      clc 
      adc actors+actor::ypos, x
      sta actors+actor::ypos, x
@exit:
      rts


debug_start:
      lda #0
      sta crs_x
      lda #8
      sta crs_y
      jmp gfx_vram_xy
debug:
      pha
      jsr gfx_hex_digits
      inc crs_x
      inc crs_x
      pla
      rts
      
set_maze_ptr:
      lda actors+actor::ypos, x; ;.Y * 32
      asl
      asl
      asl
      asl
      asl
      ora actors+actor::xpos, x
      clc
      adc #<game_maze
      sta p_game1+0
      lda actors+actor::ypos, x ; .Y * 32
      lsr ; div 8 -> page offset 0-2
      lsr
      lsr
      clc
      adc #>game_maze
      sta p_game1+1
      rts
      
pacman_move:
      ldx #0;actor_pacman, p_game1
      jsr move_actor
      rts
      
game_demo:
      lda actor_pacman+actor::state
      bmi @demo_move
      ; select direction
      
@demo_move:
      jsr pacman_move
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
      
      jsr food_eaten
      jsr draw_score
      
@exit:
      rts
      
add_score:
      clc
      lda #10
      ldx #3
      adc game_state+GameState::score
      sta game_state+GameState::score
      rts
      
food_eaten:
      sed
      cld
      rts

draw_score:
      lda #0
      sta crs_x
      lda #20
      sta crs_y
      jsr gfx_vram_xy
      lda game_state+GameState::score
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
      
      
      lda #STATE_READY
      sta game_state
      
      lda actor_pacman+actor::state
      and #03
      asl 
      tax
      lda pacman_shapes,x
      sta sprite_tab_attr+SPRITE_N
      
      rts
      
display_maze:
      vdp_vram_w ADDRESS_GFX3_SCREEN
      lda #<game_maze
      ldy #>game_maze
      ldx #4
      jsr vdp_memcpy
      
      rts

sprite_tab_attr:
      .byte 96, 188,   $18*4, 0
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

food:
    .tag actor
    .tag actor
    .tag actor
    .tag actor
    
actors:
actor_pacman:
    ;.tag actor
    .byte 12  ;ypos
    .byte 24  ;xpos
    .byte 1<<7 | ACT_LEFT   ;state bit 7 move, bit 1-0 dir 00 r, 01 l, 10 u, 11 d
    .byte 0
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
    

_vectors:
_vec_right:
      .byte 0,$ff
_vec_left:
      .byte 0, 1
_vec_up:
      .byte $ff,0
_vec_down:
      .byte 1, 0

pacman_shapes:
      .byte $10*4,$11*4 ;r  000
      .byte $12*4,$13*4 ;l  010
      .byte $14*4,$15*4 ;u  100 
      .byte $16*4,$17*4 ;d  110

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
