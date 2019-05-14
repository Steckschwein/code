      .include "pacman.inc"
      
      .export out_digits,out_digit
      .export out_hex_digit,out_hex_digits
      .export out_text
      .export frame_isr
      .export sys_crs_x
      .export sys_crs_y
      
      .import game_state
      .import gfx_charout
      .import gfx_vblank
      
      
.code
frame_isr:
      push_axy
      
      jsr gfx_vblank
      bpl @exit
      
      bgcolor Color_Yellow
      
      inc game_state+GameState::frames
@exit:
      bgcolor Color_Bg
      pop_axy
      rti

out_hex_digits:
      pha
      txa
      pha

      tax
      lsr
      lsr
      lsr
      lsr
      jsr out_hex_digit
      txa
      jsr out_hex_digit
      pla
      tax
      pla
      rts
out_hex_digit:
      and #$0f      ;mask lsb for hex print
      ora #'0'			;add "0"
      cmp #'9'+1		;is it a decimal digit?
      bcc @out
      adc #6			  ;add offset for letter a-f
@out: jmp charout
      
out_digits:
      pha
      lsr
      lsr
      lsr
      lsr
      jsr out_digit
      pla
out_digit:
      and #$0f
      ora #'0'
charout:
      jsr gfx_charout
      dec sys_crs_y
      rts
      
out_text:
      ldy #0
      lda (p_video),y
      sta sys_crs_x
      iny
      lda (p_video),y
      sta sys_crs_y
      iny
@l1:
      lda (p_video),y
      beq @rts
      cmp #WAIT
      beq @wait
      cmp #WAIT2
      bne @out
      jsr wait
@wait:
      jsr wait
      jmp @next   ; TODO improve code
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
      inc game_state+GameState::frames
      rts
      
.data

;.bss
sys_crs_x: .res 1
sys_crs_y: .res 1
actors: 
.export sprite_tab_attr
sprite_tab_attr:
;sprite_tab_attr       =actors+5*.sizeof(actor)
;sprite_tab_attr_end   =sprite_tab_attr+5*4*2
