		.export intro

		.include "pacman.inc"

		.import gfx_vram_xy
		.import gfx_blank_screen
		.import gfx_hires_on
		.import frame_isr
		.import io_getkey
		.import out_text
		.import out_digits,out_digit
		.import sys_crs_x
		.import sys_crs_y
		
		.import game_state
		
.macro draw_actor addr, color
		draw_text addr, color
		draw_text (addr+6)
		draw_text (addr+11)
		draw_text (addr+16)
.endmacro

intro:
		.ifdef __NO_INTRO
		  rts
		.endif
		;jsr gfx_hires_on
		jsr intro_frame
		draw_text _table_head
		
		draw_actor _row1, Color_Blinky
		draw_actor _row2, Color_Pinky
		draw_actor _row3, Color_Inky
		draw_actor _row4, Color_Clyde
		
		draw_text _points_1, Color_Gray
		draw_text _points_2
		
@wait_credit:
		jsr io_getkey
		cmp #'c'			 ; increment credit
		bne @wait_credit
		
		jsr credit_inc
		
		jsr intro_frame
		draw_text _start
		draw_text _players
		draw_text _bonus
		
@wait_start1up:
		jsr io_getkey
		cmp #'1'
		beq @start_1up
		cmp #'c'			 ; increment credit
		bne @wait_start1up
		jsr credit_inc
.ifdef __DEBUG
		lda game_state+GameState::frames
		and #WAIT
		bne @wait_start1up
		inc game_state+GameState::frames
		jsr credit_inc
		lda game_state+GameState::credit
		cmp #$99
		beq @start_1up
.endif
		jmp @wait_start1up
		
@start_1up:
		rts

intro_frame:
		jsr gfx_blank_screen
		draw_text _header_1, 0;Color_Gray
		draw_text _header_2
		draw_text _copyright
		draw_text _copyright_sw
		draw_text _footer
display_credit:
		lda #31
		sta sys_crs_x
		lda #16
		sta sys_crs_y
		
		lda game_state+GameState::credit
		cmp #10
		bcs @l1
		dec sys_crs_y
		jmp out_digit
@l1:
		jmp out_digits

credit_dec:
		lda game_state+GameState::credit
		beq @exit
		sed
		sbc #0
		sta game_state+GameState::credit
		cld
@exit:
		rts
		
credit_inc:
		lda game_state+GameState::credit
		cmp #$99
		beq @exit
		sed
		adc #01
		sta game_state+GameState::credit
		cld
		jmp display_credit
@exit:
		rts
		
		
.data
_save_irq:  .res 2, 0

_screen1:
_header_1:
  .byte 0,24,"1UP	HIGH SCORE	2UP",0
_header_2:
  .byte 1,22,"00",0
_footer:
  .byte 31,24,"CREDIT ",0

_table_head:; delay between text
  .byte 4,20,"CHARACTER / NICKNAME",0
_row1:
  .byte 5,24, WAIT2,$b0,$b1,0
  .byte 6,24, $b2,$b3,0
  .byte 7,24, $b4,$b5,0
  .byte 6,24, WAIT2, $b2,$b3, WAIT, "  -SHADOW	 ",WAIT,'"',"BLINKY",'"',0
_row2:
  .byte 8,24, WAIT,$b0,$b1,0
  .byte 9,24, $b2,$b3,0
  .byte 10,24, $b4,$b5,0
  .byte 9,24, WAIT2, $b2,$b3, WAIT, "  -SPEEDY	 ",WAIT,'"',"PINKY",'"',0
_row3:
  .byte 11,24, WAIT,$b0,$b1,0
  .byte 12,24, $b2,$b3,0
  .byte 13,24, $b4,$b5,0
  .byte 12,24,WAIT2, $b2,$b3, WAIT,"  -BASHFUL	",WAIT,'"',"INKY",'"',0
_row4:
  .byte 14,24, WAIT,$b0,$b1,0
  .byte 15,24, $b2,$b3,0
  .byte 16,24, $b4,$b5,0
  .byte 15,24,WAIT2, $b2,$b3, WAIT,"  -POKEY	  ",WAIT,'"',"CLYDE",'"',0
_points_1:
  .byte 22,17,Char_Food, " 10 ", Char_Pts,0
_points_2:
  .byte 24,17,Char_Superfood, " 50 ", Char_Pts,0
  
_start:
  .byte 16,21,"PUSH START BUTTON",0
_players:
  .byte 19,19,"1 PLAYER ONLY",0
_bonus:
  .byte 22,25,"BONUS PACMAN FOR 10000 ",Char_Pts,0
_copyright:
  .byte 27,19, "@ ",$23,$24,$25,$26,$27,$28,$29," 1980",0
_copyright_sw:
  .byte 29,19, "@ STECKSOFT 2019",0
