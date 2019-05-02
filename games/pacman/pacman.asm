      .include "pacman.inc"

      .export game_state
      
      .import gfx_mode_on
      .import gfx_mode_off
      .import gfx_init
      .import gfx_display_maze
      
      .import io_init
      .import sound_init
      .import sound_play
      .import boot
      .import intro
      .import game
      

;appstart $1000
.code

main:
      sei
      jsr krn_textui_disable
      
      jsr io_init
      jsr sound_init
      
      jsr gfx_init
      jsr gfx_mode_on
      
      jsr boot
@intro:
      jsr init
      jsr intro
      bit game_state+GameState::state
      bmi @exit
      jsr game
      bit game_state+GameState::state
      bmi @exit
      jmp @intro
@exit:
      jsr gfx_mode_off
      jmp (retvec)
      
init:
      ldx #.sizeof(GameState)-1
:     lda #0
      sta game_state,x
      dex
      bpl :-
      rts
.data
game_state:
  .tag GameState