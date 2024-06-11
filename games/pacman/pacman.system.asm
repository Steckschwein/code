.include "pacman.inc"

.export out_digits_xy,out_digits,out_digit
.export out_hex_digit,out_hex_digits
.export sys_charout,sys_blank_xy,sys_set_pen
.export out_text_color
.export out_text
.export frame_isr
.export sys_crs_x
.export sys_crs_y
.export system_rng
.export system_dip_switches_lives
.export system_dip_switches_bonus_life

.autoimport

.zeropage
    sys_crs_x:  .res 1
    sys_crs_y:  .res 1
.code

frame_isr:
    push_axy

    jsr gfx_isr ; v-blank?
    bpl @exit

    bgcolor Color_Yellow

    inc game_state+GameState::frames
    inc game_state+GameState::vblank

@exit:
    jsr io_isr

    bgcolor Color_Bg

    pop_axy
    rti

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
              beq @rts
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

wait:
              lda game_state+GameState::frames
              and #FRAMES_DELAY
              bne wait
              dec game_state+GameState::frames
              rts

system_rng:   ;.byte $db
              ldy game_state+GameState::rng+1
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

system_dip_switches_bonus_life:
              lda game_state+GameState::dip_switches
              and #DIP_BONUS_LIFE_1 | DIP_BONUS_LIFE_0 ; see pacman.inc
              lsr
              lsr
              lsr
              tay
              ldx bonus_life+0,y
              lda bonus_life+1,y
              rts
.data
  bonus_life: .byte $01,$00
              .byte $01,$50
              .byte $02,$00
              .byte $00,$00  ; BCD - just the TT T digit