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

.export out_digits_xy,out_digits,out_digit
.export out_hex_digit,out_hex_digits
.export sys_charout,sys_blank_xy,sys_set_pen
.export out_text_color
.export out_text
.export sys_isr
.export sys_crs_x
.export sys_crs_y
.export system_set_state_fn, system_set_state_fn_delay
.export system_call_state_fn
.export system_wait_vblank
.export system_rng
.export system_credit_inc, system_credit_dec
.export system_dip_switches_lives
.export system_dip_switches_bonus_life
.export system_dip_switches_coinage

.export input_direction

.autoimport

.zeropage
              sys_crs_x:  .res 1
              sys_crs_y:  .res 1
              p_text:     .res 2

.code

sys_isr:      push_axy

              jsr gfx_isr
              bpl @io_isr ; v-blank? (bit 7)

              bgcolor Color_Yellow

              jsr gfx_update    ; timing critical

              bit game_state+GameState::state ; intro?
              bmi :+
              jsr sound_update  ; update sound
:

              lda game_state+GameState::state
              and #STATE_PAUSE
              bne :+
              inc game_state+GameState::frames
              inc game_state+GameState::state_frames
:
              bgcolor Color_Bg

              inc game_state+GameState::vblank

@io_isr:      jsr io_isr

              pop_axy
              rti

system_wait_vblank:
              lda #0
              sta game_state+GameState::vblank
:             lda game_state+GameState::vblank  ; wait vblank
              beq :-
              rts

out_hex_digits:
              pha
              lsr
              lsr
              lsr
              lsr
              jsr out_hex_digit
              pla
out_hex_digit:
              and #$0f      ;mask lsb for hex print
              ora #'0'      ;add "0"
              cmp #'9'+1    ;is it a decimal digit?
              bcc @out
              adc #6        ;add offset for letter a-f
@out:         jmp sys_charout

sys_set_pen:
              stx sys_crs_x
              sty sys_crs_y
              sta text_color
              rts

; X/Y - coordinates
; A   - amount of chars to blank
sys_blank_xy:
              stx sys_crs_x
              sty sys_crs_y
              tax
              lda #Color_Bg
              sta text_color
:             lda #Char_Blank
              jsr sys_charout
              dex
              bne :-
              rts
; X/Y - coordinates
; A   - number (BCD)
out_digits_xy:
              stx sys_crs_x
              sty sys_crs_y
out_digits:
              pha
              lsr
              lsr
              lsr
              lsr
              jsr out_digit0
              pla
out_digit:    and #$0f
out_digit0:   ora #'0'
sys_charout:  jsr gfx_charout
              dec sys_crs_y
              rts

out_text_color:
              sta text_color
out_text:     jsr @next_char
              sta sys_crs_x
              jsr @next_char
              sta sys_crs_y
@next:        jsr @next_char
              cmp #0
              beq @rts
              cmp #TXT_CRS_XY
              beq out_text
              cmp #TXT_COLOR
              bne @ghost
              jsr @next_char
              sta text_color
              jmp @next
@ghost:       cmp #TXT_GHOST
              bne @is_wait
              jsr gfx_ghost_icon
              jmp @next
@is_wait:     cmp #TXT_WAIT
              beq @wait
              cmp #TXT_WAIT2
              bne @out
              jsr wait
@wait:        jsr wait
              jmp @next
@out:         jsr sys_charout
              jmp @next
@next_char:   ldy #0
              lda (p_text),y
              inc p_text
              bne @rts
              inc p_text+1
@rts:         rts

wait:         jsr system_wait_vblank
              lda game_state+GameState::frames
              and #FRAMES_DELAY
              bne wait
              rts

system_set_state_fn_delay:
              sta game_state+GameState::fn_state_next
              lda #FN_STATE_DELAY
system_set_state_fn:
              ldy #0
              sty game_state+GameState::state_frames
              tay
              lda system_state_table+0,y
              sta game_state+GameState::fn_state+0
              lda system_state_table+1,y
              sta game_state+GameState::fn_state+1
system_noop:  rts

system_call_state_fn:
              jmp (game_state+GameState::fn_state)


system_rng:   ldy game_state+GameState::rng+1
              lda game_state+GameState::rng+0
              asl ; *2
              rol game_state+GameState::rng+1
              asl ; *4
              rol game_state+GameState::rng+1
              clc
              adc game_state+GameState::rng+0 ; *5
              adc #1
              sta game_state+GameState::rng+0 ; +1
              tya
              adc game_state+GameState::rng+1
              and #$1f                        ; mod 8192
              sta game_state+GameState::rng+1
              lda game_state+GameState::rng+0
              sta p_text+0
              lda game_state+GameState::rng+1
              sta p_text+1
              ldy #0
              lda (p_text),y
              rts

system_dip_switches_coinage:
              lda game_state+GameState::dip_switches
              and #DIP_COINAGE_0 | DIP_COINAGE_1 ; see pacman.inc
              rts

system_dip_switches_lives:
              lda game_state+GameState::dip_switches
              and #DIP_LIVES_1 | DIP_LIVES_0 ; see pacman.inc
              lsr
              lsr
              clc
              adc #1
              tay
              and #1<<2
              beq :+
              iny
:             rts

; out:
;   Z=1 no bonus life at all
system_dip_switches_bonus_life:
              lda game_state+GameState::dip_switches
              and #DIP_BONUS_LIFE_1 | DIP_BONUS_LIFE_0 ; see pacman.inc
              lsr
              lsr
              lsr
              tay
              lda bonus_life+1,y
              ldx bonus_life+0,y  ; @see bonus_life table, if the first BCD digit is zero no bonus life at all (Z=1)
              rts

system_credit_dec:
              lda game_state+GameState::credit
              beq @exit
              sed
              sec
              sbc #1
              sta game_state+GameState::credit
              cld
@exit:        rts

system_credit_inc:
              lda game_state+GameState::credit
              cmp #$99
              bcs @exit
              sed
              adc #01
              sta game_state+GameState::credit
              cld
@exit:        rts

.data
  bonus_life: .byte $01,$00
              .byte $01,$50
              .byte $02,$00
              .byte $00,$00  ; BCD - just the TT T digit

system_state_table:
              .word system_noop
              .word game_init
              .word game_level_init
              .word game_ready
              .word game_state_delay
              .word game_ready_wait
              .word game_playing
              .word game_pacman_dying
              .word game_level_cleared
              .word game_game_over
              .word game_ghost_catched
              .word game_interlude
              .word game_demo_init
              .word game_demo_playing
              .word intro
              .word intro_ghosts
              .word intro_ghost_catched
              .word intro_select_player

.bss
  input_direction:  .res 1  ; last user input
