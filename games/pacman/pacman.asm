.include "pacman.inc"

.export game_state
.exportzp p_maze, p_video, p_sound, p_text, p_game

.autoimport


.zeropage
  p_video:  .res 2
  p_sound:  .res 2
  p_text:   .res 2
  p_game:   .res 2
  p_maze:   .res 2
  p_tmp:    .res 2

  video_tmp:    .res 1
  sound_tmp:    .res 1
  text_color:   .res 1

  _i: .res 1
  _j: .res 1
  _k: .res 1

.code
.proc  _main: near
main:
    jsr init
    jsr io_init
    jsr sound_init
    jsr gfx_init
    jsr gfx_mode_on

    jsr io_irq_on
    setIRQ frame_isr, save_irq

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

    restoreIRQ save_irq

    jmp io_exit

init:
    ldy #.sizeof(GameState)-1
    lda #0
:   sta game_state,y
    dey
    bpl :-

    jsr io_highscore_load

    lda #DIP_COINAGE_1 | DIP_LIVES_1 | DIP_DIFFICULTY | DIP_GHOSTNAMES
    sta game_state+GameState::dip_switches

    rts
.endproc

.bss
  save_irq:  .res 2
  game_state:
    .tag GameState
