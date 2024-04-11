.include "pacman.inc"

.export game_state

.autoimport

.exportzp p_maze, p_video, p_sound, p_text, p_game

.zeropage
  p_video:  .res 2
  p_sound:  .res 2
  p_text:   .res 2
  p_game:   .res 2
  p_maze:   .res 2
  p_tmp:    .res 2

  video_tmp:    .res 1
  sound_tmp:    .res 1
  game_tmp:     .res 1
  game_tmp2:    .res 1
  gfx_tmp:      .res 1
  text_color:   .res 1

  _i: .res 1
  _j: .res 1
  _k: .res 1

.code
.proc  _main: near
main:
    sei
    jsr init
    jsr io_init
    jsr sound_init
    jsr gfx_init
    jsr gfx_mode_on

    jsr io_irq_on
    setIRQ frame_isr, _save_irq

    cli

    jsr boot

@intro:
    jsr intro
    bit game_state+GameState::state
    bmi @exit
    jsr game
    bit game_state+GameState::state
    bmi @exit
    jmp @intro
@exit:
    jsr gfx_mode_off

    restoreIRQ _save_irq

    jmp io_exit

init:
    ldx #.sizeof(GameState)-1
    lda #0
:   sta game_state,x
    dex
    bpl :-
    ldx #1
    stx game_state+GameState::highscore
    inx
    stx game_state+GameState::highscore+1
    inx
    stx game_state+GameState::highscore+2
    inx
    stx game_state+GameState::highscore+3

    rts
.endproc

.bss
  _save_irq:  .res 2, 0
  game_state:
    .tag GameState
