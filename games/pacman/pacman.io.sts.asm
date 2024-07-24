;i/o
.include "pacman.sts.inc"

.export io_init
.export io_detect_joystick
.export io_joystick_read
.export io_exit
.export io_getkey
.export io_player_direction
.export io_isr
.export io_irq_on

.autoimport

appstart $1000

.code

io_init:
    jsr joystick_on

    ;TODO ...
    clc
    rts

io_isr:       jmp fetchkey

io_irq_on:  ; nothing todo here on sts hw
              rts

io_detect_joystick:
              jsr joystick_detect
              beq @exit
              sta joystick_port
@exit:        rts

io_joystick_read:
      lda joystick_port
      jmp joystick_read

io_getkey=getkey

io_player_direction:
      beq @joystick
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
      jsr io_joystick_read
      and #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP)
      cmp #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP)
      beq @rts ; nothing pressed
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

.export io_highscore_load
io_highscore_load:
      lda #0
      sta game_state+GameState::highscore
      sta game_state+GameState::highscore+1
      sta game_state+GameState::highscore+2
      sta game_state+GameState::highscore+3
      rts

io_exit:
      jmp (retvec)

.data
    joystick_port:  .res 1, JOY_PORT1 ; TODO auto detect
