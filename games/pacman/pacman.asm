      .include "pacman.inc"
      .include "appstart.inc"

      .import gfx_mode_on
      .import gfx_mode_off
      .import gfx_init
      .import gfx_display_maze
      
      .import sound_init
      .import sound_play
      .import boot
      .import intro
      .import game
      
appstart

main:
      sei
      jsr krn_textui_disable
      
      jsr joystick_on
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
      bra @intro
@exit:
      jsr gfx_mode_off
      jmp (retvec)
      
init:
      ldx #.sizeof(GameState)-1
:     stz game_state,x
      dex
      bpl :-
      rts
      
.data
.export game_state
game_state:
  .tag GameState
