      .include "pacman.inc"
      .include "appstart.inc"

      .import gfx_mode_on
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
;      jsr sound_play

:
      jsr gfx_init
      jsr gfx_mode_on
      
      .if DEBUG = 0
      jsr boot
      .endif
      
@intro:
      jsr init
      .if DEBUG = 0
      jsr intro
      .endif
      bit game_state
      bmi @exit
      jsr game
      bra @intro
@exit:
      jmp (retvec)
      
init:
      ldx #.sizeof(GameState)
:     stz game_state,x
      dex
      bpl :-
      rts
      
.data
.export game_state
game_state:
  .tag GameState
