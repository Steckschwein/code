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
      
      jsr sound_init
;      jsr sound_play
      
:
      jsr gfx_init
      jsr gfx_mode_on
      
      jsr boot

@intro:
      jsr init
      jsr intro
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
      bne :-
      rts
      
.data
.export game_state
game_state:
.tag GameState