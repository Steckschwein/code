.include "pacman.inc"

.export out_digits,out_digit
.export out_hex_digit,out_hex_digits
.export out_text_color
.export out_text
.export frame_isr
.export sys_crs_x
.export sys_crs_y

.autoimport

.zeropage
    sys_crs_x: .res 1
    sys_crs_y: .res 1

.code

frame_isr:
    push_axy

    jsr io_isr    ; v-blank?
    bpl @exit

    border_color Color_Yellow

    dec game_state+GameState::frames

@exit:
    border_color Color_Bg
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
              jsr out_hex_digit
              rts
out_hex_digit:
              and #$0f    ;mask lsb for hex print
              ora #'0'      ;add "0"
              cmp #'9'+1    ;is it a decimal digit?
              bcc @out
              adc #6        ;add offset for letter a-f
@out:         jsr charout
              inc sys_crs_x
              inc sys_crs_y
              rts

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
charout:      jsr gfx_charout
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
@out:         jsr charout
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

