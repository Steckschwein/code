		.include "pacman.inc"

		.export out_digits,out_digit
		.export out_hex_digit,out_hex_digits
		.export out_text
		.export frame_isr
		.export sys_crs_x
		.export sys_crs_y

		.import gfx_charout
		.import game_state
		.import io_isr

.code
frame_isr:
		push_axy

		jsr io_isr
		bpl @exit

		bgcolor Color_Yellow
		dec game_state+GameState::frames

@exit:
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
		jsr out_hex_digit
		rts
out_hex_digit:
		and #$0f		;mask lsb for hex print
		ora #'0'			;add "0"
		cmp #'9'+1		;is it a decimal digit?
		bcc @out
		adc #6			  ;add offset for letter a-f
@out: jsr charout
		inc sys_crs_x
		inc sys_crs_y
		rts

out_digits:
		pha
		lsr
		lsr
		lsr
		lsr
		jsr _od
		pla
out_digit:
		and #$0f
_od:
		ora #'0'
charout:
		jsr gfx_charout
		dec sys_crs_y
		rts

out_text:
		ldy #0
		lda (p_text),y
		sta sys_crs_x
		iny
		lda (p_text),y
		sta sys_crs_y
		iny
@l1:
		lda (p_text),y
		beq @rts
		cmp #WAIT
		beq @wait
		cmp #WAIT2
		bne @out
		jsr wait
@wait:
		jsr wait
		jmp @next	; TODO improve code
@out:
		jsr charout
@next:
		iny
		bne @l1
@rts:
		rts

wait:
		lda game_state+GameState::frames
		and #FRAMES_DELAY
		bne wait
		dec game_state+GameState::frames
		rts

.data

.bss
sys_crs_x: .res 1
sys_crs_y: .res 1
