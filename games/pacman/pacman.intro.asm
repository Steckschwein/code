.export intro

.include "pacman.inc"

.autoimport

.importzp sys_crs_x, sys_crs_y

intro:
              .ifdef __NO_INTRO
                rts
              .endif

              jsr intro_frame
              draw_text _table_head

              draw_text _row1, Color_Blinky
              draw_text _row2, Color_Pinky
              draw_text _row3, Color_Inky
              draw_text _row4, Color_Clyde

              draw_text _points, Color_Text
              draw_text _food, Color_Food

              draw_text _copyright, Color_Pink

              lda #Color_Bg
              sta text_color
@wait_credit:
 :            lda game_state+GameState::frames
              and #$0f
              bne :-
              lda text_color
              eor #Color_Food
              sta text_color
              draw_text _superfood
 :            lda game_state+GameState::frames
              and #$0f
              beq :-

              jsr io_getkey
              cmp #'c'       ; increment credit
              bne @wait_credit

              jsr intro_frame
              draw_text _start, Color_Orange
              draw_text _copyright, Color_Pink
              lda Color_Text
              sta text_color

@insert_coin: jsr credit_inc
@wait_start1up:
              jsr io_getkey
              cmp #'1'
              beq @start_1up
              cmp #'c'       ; increment credit
              bne @wait_start1up
              lda game_state+GameState::credit
              cmp #$99
              beq @wait_start1up
              jmp @insert_coin
@start_1up:   rts

intro_frame:
              jsr gfx_blank_screen

              draw_text _header_1, Color_Text
              draw_text _header_2
              ldx #1
              ldy #18
              jsr draw_highscore

              draw_text _footer, Color_Text
display_credit:
              lda #31
              sta sys_crs_x
              lda #16
              sta sys_crs_y

              lda game_state+GameState::credit
              cmp #10
              bcs :+
              dec sys_crs_y
              jmp out_digit
:             jmp out_digits

credit_dec:
              lda game_state+GameState::credit
              beq @exit
              sed
              sbc #0
              sta game_state+GameState::credit
              cld
@exit:        rts

credit_inc:
              lda game_state+GameState::credit
              cmp #$99
              bcs @exit
              sed
              adc #01
              sta game_state+GameState::credit
              cld
              jmp display_credit
@exit:        rts


.data
_header_1:
  .byte 0,24,"1UP   HIGH SCORE    2UP",0
_header_2:
  .byte 1,22,"00",0
_footer:
  .byte 31,24,"CREDIT ",0

_table_head:; delay between text
  .byte 4,20,"CHARACTER / NICKNAME",0
_row1:
  .byte 5,22, TXT_WAIT2,TXT_GHOST
  .byte TXT_CRS_XY, 6,20, TXT_WAIT2, TXT_WAIT, "-SHADOW    ",TXT_WAIT,Char_Quote,"BLINKY",Char_Quote
  .byte 0
_row2:
  .byte 8,22, TXT_WAIT,TXT_GHOST
  .byte TXT_CRS_XY, 9,20, TXT_WAIT2, TXT_WAIT, "-SPEEDY    ",TXT_WAIT,Char_Quote,"PINKY",Char_Quote
  .byte 0
_row3:
  .byte 11,22, TXT_WAIT,TXT_GHOST
  .byte TXT_CRS_XY, 12,20,TXT_WAIT2, TXT_WAIT, "-BASHFUL   ",TXT_WAIT,Char_Quote,"INKY",Char_Quote
  .byte 0
_row4:
  .byte 14,22, TXT_WAIT,TXT_GHOST
  .byte TXT_CRS_XY, 15,20,TXT_WAIT2, TXT_WAIT, "-POKEY     ",TXT_WAIT,Char_Quote,"CLYDE",Char_Quote
  .byte 0
_points:
  .byte 22,15, TXT_WAIT2, TXT_WAIT2, "10 ", Char_Pts
  .byte TXT_CRS_XY, 24,15, "50 ", Char_Pts
  .byte 0
_food:
  .byte 22,17, Char_Food
  .byte TXT_CRS_XY, 24,17, Char_Superfood
  .byte TXT_WAIT2, TXT_WAIT2, 0
_superfood:
  .byte 19,22, Char_Superfood
  .byte TXT_CRS_XY, 24,17, Char_Superfood
  .byte 0

; get ready
_start:
  .byte 16,21,"PUSH START BUTTON"
  .byte TXT_CRS_XY, 19,19, TXT_COLOR, Color_Cyan, "1 PLAYER ONLY"
  .byte TXT_CRS_XY, 22,25, TXT_COLOR, Color_Dark_Pink, "BONUS PACMAN FOR 10000 ",Char_Pts
  .byte 0

_copyright:
  .byte 27,19, "@ ",$23,$24,$25,$26,$27,$28,$29," 1980"
  .byte TXT_CRS_XY, 29,19, "@ STECKSOFT 2019", TXT_WAIT2
  .byte 0

.bss
  vblank: .res 1