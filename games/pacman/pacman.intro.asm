.export intro
.export intro_select_player
.export intro_ghost_catched
.export intro_ghosts

.include "pacman.inc"

.autoimport

.importzp sys_crs_x,sys_crs_y

.zeropage
              tmp:  .res 1

.code

intro:
              lda #STATE_DEMO
              sta game_state+GameState::state

              jsr intro_frame

              lda game_state+GameState::credit    ; credit available? (maybe from game over, or inserted during game ;)
              bne :+
              jsr system_dip_switches_coinage     ; free play dip switched?
              bne @wait_credit

:             draw_text _start, Color_Orange

              jsr system_dip_switches_bonus_life
              beq @copyright  ; 0 - none - no bonus life at all
              sta tmp
              txa
              lsr
              ror tmp
              lsr
              ror tmp
              lsr
              ror tmp
              lsr
              ror tmp
              lda tmp
              pha
              draw_text _bonus, Color_Orange  ; ... otherwise display bonus life at xx000Pts
              pla
              ldx #22
              ldy #8
              jsr out_digits_xy

@copyright:   draw_text _copyright, Color_Pink

              lda #FN_STATE_INTRO_SELECT_PLAYER
              jmp system_set_state_fn

@wait_credit: draw_text _table_head
              draw_text _blinky,  Color_Blinky
              draw_text _pinky,   Color_Pinky
              draw_text _inky,    Color_Inky
              draw_text _clyde,   Color_Clyde

              draw_text _points, Color_Text
              draw_text _food, Color_Food

              draw_text _copyright, Color_Pink

              jsr intro_init_script

              lda #Color_Bg
              sta text_color

.ifdef __DEVMODE
              lda #FN_STATE_DEMO_INIT
              jmp system_set_state_fn
.endif
              lda #FN_STATE_INTRO_GHOSTS
              jsr system_set_state_fn
              lda #$0e  ; initial delay ghost move
              sta game_state+GameState::state_frames
@exit:        rts

intro_select_player:
              jsr display_credit
              rts

display_credit:
              jsr system_dip_switches_coinage
              bne :+
              draw_text _free_play, Color_Text
              rts

:             draw_text _credit, Color_Text

              lda Color_Text
              sta text_color

              lda game_state+GameState::credit
              cmp #2
              bcc :+
              draw_text _2up, Color_Cyan

:             ldx #31
              ldy #16
              lda #Color_Text
              jsr sys_set_pen
              lda game_state+GameState::credit
              cmp #10
              bcs :+
              dec sys_crs_y
              jmp out_digit
:             jmp out_digits

intro_frame:  jsr gfx_sprites_off
              jsr gfx_blank_screen

              draw_text _header_1, Color_Text
              draw_text _header_2
              ldx #1
              ldy #18
              jsr draw_highscore

              jmp display_credit

intro_init_script:
              lda #18
              ldy #31
              sta sys_crs_x
              sty sys_crs_y

:             lda sys_crs_x ; draw an invisible tunnel the ghosts must pass through
              ldy sys_crs_y
              jsr lda_maze_ptr_ay

              ldy #0
              lda #Char_Maze_Blank
              sta (p_maze),y
              iny
              lda #Char_Blank
              sta (p_maze),y
              iny
              lda #Char_Maze_Blank
              sta (p_maze),y
              dec sys_crs_y
              bpl :-

              lda #INTRO_TUNNEL_X
              ldy #23
              jsr lda_maze_ptr_ay
              lda #Char_Energizer
              sta (p_maze),y

              ldy #21  ; speed of level 21 - pacman 90%/ghost 95% speed
              jsr init_speed_cnt

              jsr game_init_actors
              ldx #ACTOR_PACMAN
:             lda #ACT_MOVE|ACT_LEFT<<2|ACT_LEFT
              sta actor_move,x
              lda #INTRO_TUNNEL_X*8+4 ; center +4px
              sta actor_sp_x,x
              txa
              asl
              clc
              adc #29*8+4
              sta actor_sp_y,x
              cpx #ACTOR_PACMAN
              beq @next
@ghost:       lda #GHOST_STATE_TARGET
              sta ghost_state,x
@next:        dex
              bpl :-

              lda #$fe
              sta ghost_cnt
              lda #0
              sta game_state+GameState::speed_ix
              rts

intro_ghosts: ldx #ACTOR_PACMAN
              jsr pacman_move

              lda #INTRO_TUNNEL_X
              sta sys_crs_x
              ldy #23
              sty sys_crs_y
              jsr lda_maze_ptr_ay
              jsr gfx_charout

              lda game_state+GameState::state_frames
              and #$0f  ; spwan ghost every 16 frames
              bne @move
              ldx ghost_cnt
              cpx #ACTOR_CLYDE
              beq @move
              inc ghost_cnt

@move:        ldx ghost_cnt
              bmi @exit
              jsr actors_move
@exit:        jmp animate_energizer

intro_ghost_catched:
              lda game_state+GameState::state_frames
              and #$1f
              bne animate_energizer
              sec
              lda #3
              sbc game_state+GameState::ghsts_to_catch
              tax
              lda #30*8
              sta actor_sp_y,x
              lda #GHOST_STATE_BASE
              sta ghost_state,x
              dec game_state+GameState::ghsts_to_catch
              bmi @demo
              lda #FN_STATE_INTRO_GHOSTS  ; go on
              jmp system_set_state_fn
@demo:        lda #FN_STATE_DEMO_INIT
              jmp system_set_state_fn
animate_energizer:
              lda game_state+GameState::frames
              and #$0f
              bne @exit
              lda text_color
              eor #Color_Food
              sta text_color
              draw_text _superfood
@exit:        rts


.data

_header_1:
  .byte 0,24,"1UP   HIGH SCORE    2UP"
  .byte 0
_header_2:
  .byte 1,22,"00"
  .byte 0
_credit:
  .byte 31,25,"CREDIT"
  .byte 0
_free_play:
  .byte 31,25,"FREE PLAY"
  .byte 0
_table_head:; delay between text
  .byte 4,20,"CHARACTER / NICKNAME"
  .byte 0
_blinky:
  .byte 5,22, TXT_WAIT2,TXT_GHOST
  .byte TXT_CRS_XY, 6,20, TXT_WAIT2, TXT_WAIT, "-SHADOW    ",TXT_WAIT,Char_Quote,"BLINKY",Char_Quote
  .byte 0
_pinky:
  .byte 8,22, TXT_WAIT,TXT_GHOST
  .byte TXT_CRS_XY, 9,20, TXT_WAIT2, TXT_WAIT, "-SPEEDY    ",TXT_WAIT,Char_Quote,"PINKY",Char_Quote
  .byte 0
_inky:
  .byte 11,22, TXT_WAIT,TXT_GHOST
  .byte TXT_CRS_XY, 12,20,TXT_WAIT2, TXT_WAIT, "-BASHFUL   ",TXT_WAIT,Char_Quote,"INKY",Char_Quote
  .byte 0
_clyde:
  .byte 14,22, TXT_WAIT,TXT_GHOST
  .byte TXT_CRS_XY, 15,20,TXT_WAIT2, TXT_WAIT, "-POKEY     ",TXT_WAIT,Char_Quote,"CLYDE",Char_Quote
  .byte 0
_points:
  .byte 22,15, TXT_WAIT2, TXT_WAIT2, "10 ", Char_Pts
  .byte TXT_CRS_XY, 24,15, "50 ", Char_Pts
  .byte 0
_food:
  .byte 22,17, Char_Dot
  .byte TXT_CRS_XY, 24,17, Char_Energizer
  .byte TXT_WAIT2, TXT_WAIT2
  .byte 0
_superfood:
  .byte 24,17, Char_Energizer
  .byte 0
_start:
  .byte 16,21,"PUSH START BUTTON"
  .byte TXT_CRS_XY, 19,19, TXT_COLOR, Color_Cyan, "1 PLAYER ONLY"
  .byte 0
_bonus:
  .byte 22,25, TXT_COLOR, Color_Dark_Pink, "BONUS PACMAN FOR   000 ",Char_Pts
  .byte 0
 _2up:
  .byte 19,17, "OR 2 PLAYERS"
  .byte 0
_copyright:
  .byte 27,19, "@ ",$23,$24,$25,$26,$27,$28,$29," 1980"
  .byte TXT_CRS_XY, 29,19, "@ STECKSOFT 2019", TXT_WAIT2
  .byte 0

.bss
  ghost_cnt:  .res 1
