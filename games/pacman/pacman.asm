.include "pacman.inc"

.export game_state

.exportzp p_maze, p_sound, p_text
.exportzp p_game
.exportzp p_video

.autoimport

.zeropage
  p_video:  .res 2
  p_sound:  .res 2
  p_text:   .res 2
  p_game:   .res 2
  p_maze:   .res 2

  sound_tmp:    .res 1
  text_color:   .res 1

.code

.proc  _main: near
main:
              jsr init_state
              jsr io_init
              bcc :+
              rts

:             jsr sound_init
              jsr gfx_init
              jsr gfx_mode_on

              jsr io_irq_on
              setIRQ sys_isr, save_irq

              jsr boot

@init_state:  lda #FN_STATE_INTRO
              .ifdef __NO_INTRO
              lda #FN_STATE_INIT  ; directly to game init
              .endif

@set_state:   jsr system_set_state_fn

@main_loop:   jsr system_wait_vblank

              border_color Color_Green

              lda game_state+GameState::state
              and #STATE_PAUSE
              bne :+
              jsr system_call_state_fn
:
              jsr gfx_prepare_update

              border_color Color_Bg

              jsr io_getkey
              bcs :+
              lda #0                      ; 0 - no key pressed
:             pha
              jsr io_player_direction     ; return C=1 if any valid key or joystick input, A=ACT_xxx
              bcs :+                      ; key/joy input ?
              ora #$80                    ; flag no input
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
              lda #0
              ; debug keys
          :   cmp #'r'
              beq @init_state
              cmp #'d'
              bne :+
              lda #FN_STATE_PACMAN_DYING
              bne @set_state
          :   cmp #'g'
              bne :+
              lda #1  ; 1 left
              sta game_state+GameState::lives
              lda #FN_STATE_PACMAN_DYING
              jmp @set_state
          :   cmp #'i'
              bne :+
              lda #2
              sta game_state+GameState::level
              lda #FN_STATE_INTERMISSION
              jmp @set_state
:             cmp #'c'
              bne :+
              jsr system_credit_inc
              bit game_state+GameState::state ; in intro?
              bpl @main_loop
              lda #FN_STATE_INTRO
              jmp @set_state
:             cmp #'m'
              bne :+
              lda #0
              sta game_state+GameState::sctchs_timer+0
              sta game_state+GameState::sctchs_timer+1
              jmp @main_loop

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
              lda #0  ; reset state from intro
              sta game_state+GameState::state
              lda #FN_STATE_INIT
              jmp @set_state

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
              jmp @main_loop

quit:
              jsr sound_init
              jsr gfx_mode_off
              restoreIRQ save_irq
              jmp io_exit
.endproc


init_state:
            ldy #.sizeof(GameState)-1
            lda #0
:           sta game_state,y
            dey
            bpl :-

            jsr io_highscore_load

            lda #DIP_COINAGE_1 | DIP_LIVES_1 | DIP_DIFFICULTY | DIP_GHOSTNAMES  ; 1 coin/1 credit, bonus life at 10.000pts
;            lda DIP_LIVES_1 | DIP_DIFFICULTY | DIP_GHOSTNAMES
            sta game_state+GameState::dip_switches

            rts

.bss
  save_irq:  .res 2
  game_state:
    .tag GameState
