; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

.include "pacman.inc"

.export game_state

.exportzp p_maze, p_sound
.exportzp p_video

.autoimport

.zeropage
  p_video:  .res 2
  p_sound:  .res 2
  p_maze:   .res 2

  text_color:   .res 1
  sound_tmp:    .res 1

.code

.proc  _main: near
main:
              jsr init_state
              jsr io_init
              bcc :+
              rts

:             sei
              jsr sound_init
              jsr gfx_init
              jsr gfx_mode_on
              jsr io_irq_on
              cli

              jsr boot

@init_state:  lda #FN_STATE_INTRO
              .ifdef __NO_INTRO
              lda #FN_STATE_INIT  ; directly to game init
              .endif
@set_state:   jsr system_set_state_fn

@main_loop:   jsr system_wait_vblank

              bgcolor Color_Red

              lda game_state+GameState::state
              and #STATE_PAUSE
              bne :+
              jsr system_call_state_fn
:
              jsr gfx_prepare_update

              bgcolor Color_Bg

              jsr io_getkey
              pha
              bit game_state+GameState::state ; skip user input in intro/demo
              bmi @skip_input
              jsr io_player_direction     ; return C=1 if any valid key or joystick input, A=ACT_xxx
              bcs :+                      ; key/joy input ?
@skip_input:  lda #$80                    ; flag no input
:             sta input_direction
              pla
              cmp #KEY_EXIT
              bne :+
              jmp quit
:             cmp #'p'
              bne :+
              lda game_state+GameState::state
              eor #STATE_PAUSE
              sta game_state+GameState::state
              jsr gfx_pause
              jmp @main_loop
:             cmp #'c'
              bne :+
              jsr system_credit_inc
              bit game_state+GameState::state ; in intro?
              bpl @main_loop
              lda #FN_STATE_INTRO
              jmp @set_state
:             bit game_state+GameState::state ; in intro?
              bpl :+
              cmp #'1'
              beq @start_game
              cmp #'2'
              beq @start_game
              jmp @main_loop
@start_game:  sbc #'0'  ; make numeric
              sta game_state+GameState::players
              jsr system_credit_dec
              lda #0    ; reset state from intro
              sta game_state+GameState::state
              lda #FN_STATE_INIT
              jmp @set_state
:             cmp #'r'  ; reset
              bne :+
              jmp @init_state
.ifdef __DEVMODE  ; debug keys
:             cmp #'x'
;              bne :+
              ldy #ACTOR_PACMAN
              lda actor_sp_x,y
              sta @lmmm+0
              lda actor_sp_y,y
              sta @lmmm+2
              lda #<@lmmm
              ldx #>@lmmm
              bgcolor Color_Yellow
              jsr vdp_cmd_hmmm
              bgcolor Color_Bg
              jmp @main_loop
@lmmm:
  .word 0,512,128,600,48,48
:             cmp #'d'  ; dying
              bne :+
              lda #FN_STATE_PACMAN_DYING
              jmp @set_state
:             cmp #'g'  ; game over
              bne :+
              lda #1    ; 1 left
              sta game_state+GameState::lives
              lda #FN_STATE_PACMAN_DYING
              jmp @set_state
:             cmp #'s' ;
              bne :+
              jsr sound_play_eat_dot
              lda #0
:             cmp #'b' ;
              bne :+
              jsr sound_play_eat_fruit
              lda #0
:             cmp #'a' ;
              bne :+
              jsr sound_play_ghost_alarm
              lda #0
:             cmp #'f' ;
              bne :+
              jsr sound_play_ghost_frightened
              lda #0
:             cmp #'k' ;
              bne :+
              jsr sound_play_ghost_catched
              lda #0
:             cmp #'o' ;
              bne :+
              jsr sound_play_pacman_dying
              lda #0
:             cmp #'l' ; level skip
              bne :+
              lda #0
              sta game_state+GameState::dots
:             cmp #'i'  ; intermission
              bne :+
              lda #2
              sta game_state+GameState::level
              lda #FN_STATE_INTERLUDE
              jmp @set_state
:             cmp #'m'
              bne :+
              lda #0
              sta game_state+GameState::sctchs_timer+0
              sta game_state+GameState::sctchs_timer+1
              jmp @main_loop
:             cmp #'e'  ; elroy
              bne :+
              ldx #ACTOR_BLINKY
              lda #4
              sta ghost_speed_offs,x
              lda game_state+GameState::frames
              jmp @main_loop
:             cmp #'n'
              bne :+
              lda #1<<6
              bne @debug
:             cmp #'v'
              bne :+
              lda #1<<7
@debug:       eor game_state+GameState::debug
              sta game_state+GameState::debug
              jmp @main_loop
:             cmp #'1'
              bcc :+
              cmp #'4'+1
              bcs :+
              and #$0f
              adc #$ff
              tax
              asl
              clc
              adc #1
              sei
              pha
              ldy ghost_tgt_y,x
              lda ghost_tgt_x,x
              tax
              pla
              jsr sys_set_pen
              lda #'T'
              jsr sys_charout
              cli
:
.endif
              jmp @main_loop

quit:         jsr sound_off
              jsr gfx_mode_off
              jmp io_exit
.endproc


init_state: ldy #.sizeof(GameState)-1
            lda #0
:           sta game_state,y
            dey
            bpl :-
.ifdef __DEVMODE
            lda #$80
            sta game_state+GameState::debug
.endif
            jsr io_highscore_load

            lda #DIP_COINAGE_1 | DIP_LIVES_1 | DIP_DIFFICULTY | DIP_GHOSTNAMES  ; 1 coin/1 credit, bonus life at 10.000pts
;            lda DIP_LIVES_1 | DIP_DIFFICULTY | DIP_GHOSTNAMES
            sta game_state+GameState::dip_switches

            rts

.bss
  game_state:
    .tag GameState
