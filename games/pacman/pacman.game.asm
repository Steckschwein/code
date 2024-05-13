.export game
.export draw_highscore
.export bonus_for_level

.include "pacman.inc"

.autoimport

.importzp sys_crs_x, sys_crs_y

.zeropage
  game_tmp:   .res 1
  game_tmp2:  .res 1

.code
game:
    setIRQ game_isr, save_irq

@loop:
    lda #STATE_INIT
@set_state:
    jsr game_set_state_frames
@waitkey:
    lda game_state+GameState::state
    cmp #STATE_INTRO
    beq @exit
    jsr io_getkey
    bcc @waitkey
    sta keyboard_input
    cmp #'d'
    bne :+
    lda #STATE_PACMAN_DYING
    bne @set_state
:   cmp #'g'
    bne :+
    lda #1  ; 1 left
    sta game_state+GameState::lives
    lda #STATE_PACMAN_DYING
    bne @set_state
:   cmp #'r'
    bne :+
    lda #STATE_INIT
    beq @set_state
:   cmp #'i'
    bne :+
    lda #STATE_LEVEL_INIT
    bne @set_state
:   cmp #'c'
    bne :+
    lda #STATE_LEVEL_CLEARED
    bne @set_state
:   cmp #'p'
    bne @exit_key
    lda game_state+GameState::state
    eor #STATE_PAUSE
    sta game_state+GameState::state
    and #STATE_PAUSE
    jsr gfx_pause
    lda #0
@exit_key:
    cmp #KEY_EXIT
    bne @waitkey
    lda #STATE_EXIT
@exit:
    sta game_state+GameState::state
    jsr sound_init

    restoreIRQ save_irq
    rts

game_isr:
    push_axy
    jsr io_isr
    bpl @exit

    border_color Color_Yellow
    jsr gfx_update

    border_color Color_Gray

    ;jsr @call_state_fn
    jsr game_state_delay
    jsr game_init
    jsr game_level_init
    jsr game_ready
    jsr game_ready_wait
    jsr game_playing
    jsr game_pacman_dying
    jsr game_level_cleared
    jsr game_game_over

    inc game_state+GameState::frames
.ifdef __DEBUG
    border_color Color_Cyan
    ;jsr debug
.endif
@exit:
    border_color Color_Bg
    pop_axy
    rti
@call_state_fn:
    jmp (game_state+GameState::fn)


game_state_delay:
              lda game_state+GameState::state
              cmp #STATE_DELAY
              bne @exit

              lda game_state+GameState::nextstate ; code smell
              cmp #STATE_PACMAN_DYING
              bne :+
              jsr animate_screen
              lda game_state+GameState::frames
              and #$3f
              beq @state

:             jsr sound_play
              lda game_state+GameState::frames
              and #$7f
              bne @exit
@state:       tay ; A=0 to Y
              lda game_state+GameState::nextstate
              sty game_state+GameState::nextstate
              jmp game_set_state_frames
@exit:        rts

game_ready:   lda game_state+GameState::state
              cmp #STATE_READY
              bne @exit

              jsr sound_play
              jsr game_init_actors
              lda #Bonus_Clear
              jsr gfx_bonus
              draw_text _ready, Color_Yellow
              ldy #Color_Food
              jsr draw_energizer
              lda #12
              jsr delete_message

              ldy game_state+GameState::lives
              dey ; pick 1 live, redraw
              jsr gfx_lives
              lda #STATE_READY_WAIT
              jmp game_set_state_frames
@exit:        rts

game_ready_wait:
              lda game_state+GameState::state
              cmp #STATE_READY_WAIT
              bne @exit
              jsr sound_play
              jsr animate_up
              lda game_state+GameState::frames
              and #$7f
              bne @detect_joystick
              lda #18
              jsr delete_message
              lda #STATE_PLAYING
              jmp game_set_state
@detect_joystick:
              jmp io_detect_joystick
@exit:        rts

game_pacman_dying:
              lda game_state+GameState::state
              cmp #STATE_PACMAN_DYING
              bne @exit
              jsr animate_screen
              jsr actors_invisible

              lda game_state+GameState::frames
              lsr
              lsr
              lsr
              cmp #$18
              bcc @pacman_dying

              dec game_state+GameState::lives ; dec 1 live

              lda #STATE_READY
              ldy game_state+GameState::lives
              bne @set_state
              ldy #Color_Food
              jsr draw_energizer
              draw_text _text_game_over, Color_Red
              lda #STATE_GAME_OVER
@set_state:   jmp game_set_state_frames
@pacman_dying:cmp #$0c
              bcs @exit
              adc #SHAPE_IX_DYING        ; shape offset
              ldx #ACTOR_PACMAN
              sta actors+actor::shape,x
@exit:        rts


game_game_over:
              lda game_state+GameState::state
              cmp #STATE_GAME_OVER
              bne @exit
              jsr animate_up
              lda game_state+GameState::frames
              and #$7f
              bne @exit
              lda game_state+GameState::credit
              sec
              sed
              sbc #1
              sta game_state+GameState::credit
              cld
              lda #STATE_INTRO
              jmp game_set_state_frames
@exit:        rts


actors_invisible:
              lda #SHAPE_IX_INVISIBLE
              ldx #ACTOR_BLINKY
              sta actors+actor::shape,x
              ldx #ACTOR_INKY
              sta actors+actor::shape,x
              ldx #ACTOR_PINKY
              sta actors+actor::shape,x
              ldx #ACTOR_CLYDE
              sta actors+actor::shape,x
              rts


    ; key/joy input ?
    ;  (input direction != current direction)?
    ;  y - input direction inverse current direction?
    ;     y - set current direction = inverse input direction
    ;     n - can move to input direction?
    ;        y - pre-turn? (+4px)
    ;            y - set turn direction = current direction
    ;             - set turn bit on
    ;         - post-turn?  (-3px)
    ;            y - set turn direction = inverse current direction (eor)
    ;              set turn bit on
    ;         - set current direction = input direction
    ;         - change pacman shape
    ;      - set next direction = input direction
    ;
    ; block reached? (center)
    ;  y - is turn?
    ;      y - reset turn bit
    ;        - reset turn direction
    ;    - can move to current direction?
    ;      n - change pacman shape to next direction
    ;         reset move bit
    ;
    ; soft move current direction
    ; turn bit on?
    ;  y - soft move to turn direction


actors_move:
              ldx #ACTOR_PACMAN
              jsr actor_update_charpos
              jsr pacman_input
              jsr actor_move

              ldx #ACTOR_BLINKY
              jsr ghost_move
              ldx #ACTOR_INKY
              jsr ghost_move
              ldx #ACTOR_PINKY
              jsr ghost_move
              ldx #ACTOR_CLYDE
              jsr ghost_move

              ldx #ACTOR_PACMAN
              ldy #ACTOR_BLINKY
              jsr @pacman_hit
              beq @pacman_dead
              ldy #ACTOR_PINKY
              jsr @pacman_hit
              beq @pacman_dead
              ldy #ACTOR_INKY
              jsr @pacman_hit
              beq @pacman_dead
              ldy #ACTOR_CLYDE
              jsr @pacman_hit
              bne @exit
@pacman_dead: lda #STATE_PACMAN_DYING
              jmp game_set_state_frames_delay
@pacman_hit:
              lda actors+actor::xpos,x
              cmp actors+actor::xpos,y
              bne @exit
              lda actors+actor::ypos,x
              cmp actors+actor::ypos,y
@exit:        rts


ghost_move:   lda game_state+GameState::frames
              and #$01
              beq :+
              rts
:             jsr actor_update_charpos
;  short distance, same distance => order: up, left, down, right.
ghost_base:   lda actors+actor::strategy,x
              cmp #GHOST_STATE_BASE
              bne ghost_leave_base
              lda actors+actor::sp_x,x
              bmi :+
              cmp #$78
              bne @leave
:             lda actors+actor::move,x
              eor #ACT_MOVE_INVERSE
              sta actors+actor::move,x
@move:        jmp actor_move_soft
@leave:       cmp #$7c
              bne @move
              lda actors+actor::dot_limit,x
              clc
              adc game_state+GameState::dots
              cmp #MAX_DOTS
              bne @move
              rts




ghost_leave_base:
              cmp #GHOST_STATE_LEAVE
              bne ghost_catch
              rts
ghost_catch:
              rts

              jsr actor_center
              bne @soft    ; center reached?

              lda actors+actor::move,x
              and #ACT_DIR
              jsr actor_can_move_to_direction
              bcc @soft  ; C=0, can move to

              lda actors+actor::move,x
              eor #ACT_DIR ;? inverse
:             sta game_tmp
              jsr actor_can_move_to_direction
              lda game_tmp
              eor #$01    ; ?left right?
              bcs :-
              lda actors+actor::move,x  ;otherwise stop move
              and #<~ACT_DIR
              ora game_tmp
              sta actors+actor::move,x
              rts
@soft:
              jmp actor_move_soft
              rts


    ; .A new direction
pacman_cornering:
    tay
    lda actors+actor::move,x
    and #$01  ;bit 0 set, either +x or +y, down or left
    beq @l1
    lda #$07   ;
@l1:
    eor #$07
    sta game_tmp2 ;
    tya
l_test:
    and #ACT_MOVE_UP_OR_DOWN    ; new direction is a turn
    bne l_up_or_down          ; so we have to test with the current direction (orthogonal)

l_left_or_right:
    lda actors+actor::sp_x,x
    bne l_compare ; always branch
l_up_or_down:
    lda actors+actor::sp_y,x
l_compare:
    eor game_tmp2
    and #$07
    cmp #$04   ; 0100 - center pos, <0100 pre-turn, >0100 post-turn
    rts

;     A - bit 0-1 the direction
actor_center:
              ldy #0
              sty game_tmp2
              eor #ACT_MOVE_UP_OR_DOWN
              jmp l_test

actor_move:
              lda actors+actor::turn,x
              bpl @actor_move_dir      ; turning?
              jsr actor_center
              bne @actor_turn_soft      ;
              lda actors+actor::turn,x  ;
              and #<~ACT_TURN
              sta actors+actor::turn,x
@actor_turn_soft:
              lda actors+actor::turn,x
              jsr actor_move_sprite

@actor_move_dir:
              lda actors+actor::move,x
              bpl :+
              jsr pacman_move
:             jmp pacman_collect

pacman_move:
              jsr actor_center        ; center reached?
              bne @move_soft     ; no, move soft

              lda actors+actor::move,x
              and #ACT_DIR
              jsr actor_can_move_to_direction
              bcc @move_soft     ; C=0 - can move to

              lda actors+actor::move,x  ;otherwise stop move
              and #<~ACT_MOVE
              sta actors+actor::move,x
              and #ACT_NEXT_DIR       ; set shape of next direction
              sta actors+actor::shape,x
              rts

@move_soft:
              lda game_state+GameState::frames
              lsr
              and #$03
              jsr actor_shape_update

actor_move_soft:
              lda actors+actor::move,x
actor_move_sprite:
              bpl @exit
              and #ACT_DIR
              asl
              tay

              lda actors+actor::sp_x,x
              adc _vectors+0,y
              sta actors+actor::sp_x,x

              clc
              lda actors+actor::sp_y,x
              ;cmp #$df
              ;beq @exit
 ;             .byte $db
              adc _vectors+1,y
              sta actors+actor::sp_y,x
@exit:        rts

actor_shape_move:
              lda game_state+GameState::frames
              lsr
              lsr
              lsr
              and #$01

actor_shape_update:
              ora actors+actor::mask,x
              sta actors+actor::shape,x

              lda actors+actor::move,x
              and #ACT_DIR
              asl
              asl
              ora actors+actor::shape,x
              sta actors+actor::shape,x
              rts

pacman_collect:
              lda actors+actor::xpos,x
              sta sys_crs_x
              ldy actors+actor::ypos,x
              sty sys_crs_y
              jsr lda_maze_ptr_ay
              cmp #Char_Energizer
              bne :+
              dec game_state+GameState::dots
              lda #Pts_Index_Energizer
              bne @score_and_erase
:             cmp #Char_Dot
              bne :+
              dec game_state+GameState::dots
              lda #Pts_Index_Dot
              beq @score_and_erase  ; dots index is 0
:             cmp #Char_Bonus
              beq @bonus
              rts

@bonus:       lda #1
              sta game_state+GameState::bonus_cnt ; will erase bonus next frame(s)
              lda game_state+GameState::bonus
              and #$3f
              asl
@score_and_erase:
              pha
              lda #Char_Blank
              ldy #0
              sta (p_maze),y
              jsr gfx_charout
              pla
              tay
add_score:
              jsr @add_score
              jsr draw_scores

              lda game_state+GameState::score+2
              cmp game_state+GameState::bonus_life+1
              bcc @exit
              lda game_state+GameState::score+1
              cmp game_state+GameState::bonus_life+0
              bcc @exit
              jsr system_dip_switches_bonus_life
              stx game_tmp
              sed
              clc
              adc game_state+GameState::bonus_life+0
              sta game_state+GameState::bonus_life+0
              lda game_state+GameState::bonus_life+1
              adc game_tmp
              sta game_state+GameState::bonus_life+1
              cld
              ldy game_state+GameState::lives
              inc game_state+GameState::lives
              jmp gfx_lives

@add_score:
              sed
              clc
              lda game_state+GameState::score+0
              adc points+1,y ; readable bcd, top down
              sta game_state+GameState::score+0
              lda game_state+GameState::score+1
              adc points+0,y
              sta game_state+GameState::score+1
              lda game_state+GameState::score+2
              adc #0
              sta game_state+GameState::score+2
              cld

              ldy #2
@cmp:         lda game_state+GameState::highscore,y
              cmp game_state+GameState::score,y
              bcc @copy ; highscore < score ?
              bne @exit
              dey
              bpl @cmp
@exit:        rts

@copy:        ldy #2
:             lda game_state+GameState::score,y
              sta game_state+GameState::highscore,y
              dey
              bpl :-
              rts



    ; in:  .A - direction
    ; out:  .C=0 can move, C=1 can not move to direction
actor_can_move_to_direction:
    jsr lday_actor_charpos_direction    ; update dir char pos
    jsr lda_maze_ptr_ay            ; calc ptr to next char at input direction
    cmp #Char_Bg                ; C=1 if char >= Char_Bg
    rts

pacman_input:
    jsr get_input
    bcc @exit                    ; key/joy input ?
    sta input_direction
    jsr actor_can_move_to_direction      ; C=0 can move
    bcs @set_input_dir_to_next_dir    ; no - only set next dir

    lda actors+actor::turn,x
    bmi @exit  ;exit if turn is active

    ;current dir == input dir ?
    lda actors+actor::move,x
    and #ACT_DIR
    cmp input_direction          ;same direction ?
    beq @set_input_dir_to_next_dir  ;yes, do nothing...
    ;current dir == inverse input dir ?
    eor #ACT_MOVE_INVERSE
    cmp input_direction
    beq @set_input_dir_to_current_dir

    lda actors+actor::ypos,x      ;is tunnel ?
    beq @exit                    ;ypos=0
    cmp #28                  ;... or >=28
    bcs @exit                    ;ignore input

    lda input_direction
    jsr pacman_cornering
    beq @set_input_dir_to_current_dir  ; Z=1 center position, no pre-/post-turn
    lda #0
    bcc @l_preturn                 ; C=0 pre-turn, C=1 post-turn

    lda #ACT_MOVE_INVERSE          ;
@l_preturn:
    eor actors+actor::move,x  ; current direction
    and #ACT_DIR
    ora #ACT_TURN
    sta actors+actor::turn,x

@set_input_dir_to_current_dir:
    lda input_direction
    ora #ACT_MOVE
    sta actors+actor::move,x

@set_input_dir_to_next_dir: ; bit 3-2
    lda input_direction
    asl
    asl
    sta game_tmp
    lda actors+actor::move,x
    and #<~ACT_NEXT_DIR
    ora game_tmp
    sta actors+actor::move,x
@exit: rts

; in:  .A - direction
lday_actor_charpos_direction:
    asl
    tay
    lda actors+actor::xpos,x
    clc
    adc _vectors+0,y
    pha ; save x pos
    lda actors+actor::ypos,x
    clc
    adc _vectors+1,y
    tay
    pla
    rts

actor_update_charpos: ;offset x=+4,y=+4  => x,y 2,1 => 4+2*8, 4+1*8
    lda actors+actor::sp_x,x
    lsr
    lsr
    lsr
    sta actors+actor::xpos,x
    lda actors+actor::sp_y,x
    lsr
    lsr
    lsr
    sta actors+actor::ypos,x
    rts

get_input:
    ldy #0
    lda keyboard_input
    sty keyboard_input        ; "consume" key pressed
    jmp io_player_direction   ; return C=1 if any valid key or joystick input, A=ACT_xxx

debug:
    pha
    txa
    pha
    lda #11
    sta sys_crs_x
    lda #31
    sta sys_crs_y
    lda #Color_Text
    sta text_color
    ldx #ACTOR_PACMAN
    lda actors+actor::xpos,x
    jsr out_hex_digits
    lda actors+actor::sp_x,x
;    jsr out_hex_digits
    lda actors+actor::ypos,x
    jsr out_hex_digits
    lda actors+actor::sp_y,x
;    jsr out_hex_digits
    lda input_direction
    jsr out_hex_digits
    lda actors+actor::move,x
    jsr out_hex_digits
    lda actors+actor::turn,x
    jsr out_hex_digits
    lda keyboard_input
    jsr out_hex_digits
    pla
    tax
    pla
    jsr out_hex_digits
    rts

; in: A/Y - as x/y char postition
; out: A - char at position
lda_maze_ptr_ay:
    sta game_tmp
    tya           ; y * 32
    asl
    asl
    asl
    asl
    asl
    ora game_tmp
    sta p_maze+0

    tya
    lsr ; div 8 -> page offset 0..n
    lsr
    lsr
    clc
    adc #>game_maze
    sta p_maze+1
    ldy #0
    lda (p_maze),y
    rts

game_demo:
@demo_text:
              lda game_state+GameState::frames
              and #$07
              bne :+
              draw_text _text_pacman
              draw_text _text_demo
@exit:         rts
:             lda game_state+GameState::frames
              and #$08
              beq @exit
              lda #12
              jsr delete_message
              lda #18
delete_message:
              sta sys_crs_x
              lda #18
              sta sys_crs_y
              ldx #10
              lda #Color_Bg
              sta text_color
:             lda #Char_Bg
              jsr gfx_charout
              dec sys_crs_y
              dex
              bne :-
              rts

game_playing:
              lda game_state+GameState::state
              cmp #STATE_PLAYING
              bne @exit

              ;jsr game_demo
              jsr actors_move
              jsr animate_ghosts

              jsr animate_screen
              jsr animate_bonus

              lda game_state+GameState::dots   ; all dots collected ?
              ;cmp #230
              bne @exit

              ldy #Pts_Index_Level_Cleared
              jsr add_score

              ldx #ACTOR_PACMAN
              lda #2  ; pacman shape complete "ball"
              sta actors+actor::shape,x

              lda #STATE_LEVEL_CLEARED
              jmp game_set_state_frames_delay
@exit:        rts

; in: A - level
; out: Y - bonus
bonus_for_level:
              tay
              cmp #2+1 ; level 1 or 2 bonus 1 or 2
              bcc :+
              ldy #3
              cmp #4+1 ; level 3,4 bonus 3
              bcc :+
              iny
              cmp #6+1 ; level 5,6 bonus 4
              bcc :+
              iny
              cmp #8+1 ; level 7,8 bonus 5
              bcc :+
              iny
              cmp #10+1 ; level 9,10 bonus 6
              bcc :+
              iny
              cmp #12+1 ; level 11,12 bonus 7
              bcc :+
              iny ; level 13- bonus 8
:             rts

animate_bonus:
              lda game_state+GameState::bonus_cnt
              beq @bonus_trig
              lda game_state+GameState::frames
              and #$03  ; every 4 frames ~67ms
              bne @exit
              dec game_state+GameState::bonus_cnt
              bne @exit
              lda #Bonus_Clear
              jmp gfx_bonus
@bonus_trig:
              lda game_state+GameState::dots
              bit game_state+GameState::bonus
              bmi @exit
              bvs @bonus2
              cmp #MAX_DOTS-Bonus_Dots_Trig1
              bne @bonus2
              lda #Bonus1_Triggered
              bne @bonus
@bonus2:      cmp #MAX_DOTS-Bonus_Dots_Trig2
              bne @exit
              lda #Bonus2_Triggered
@bonus:       ora game_state+GameState::bonus
              sta game_state+GameState::bonus
              and #$1f  ; mask bonus number 1-8
              jsr gfx_bonus
              lda #Bonus_Time
              sta game_state+GameState::bonus_cnt
              lda #Char_Bonus ; set char in maze which will be handled in collect
              sta game_maze+($12+$20*$0d)
@exit:        rts


draw_frame:   ldx #3                ; init maze
              ldy #0
:             lda maze+$000,y
              sta game_maze+$000,y
              lda maze+$100,y
              sta game_maze+$100,y
              lda maze+$200,y
              sta game_maze+$200,y
              lda maze+$280,y
              sta game_maze+$280,y
              iny
              bne :-
              ldy #4*32-1
              lda #Char_Blank
:             sta game_maze+$380,y
              dey
              bne :-

              jsr gfx_sprites_off

              jsr gfx_display_maze

              draw_text _ready, Color_Yellow

              jsr draw_scores

              ldy game_state+GameState::lives
              jsr gfx_lives

              lda game_state+GameState::level
              jmp gfx_bonus_stack

game_set_state_frames_delay:
              sta game_state+GameState::nextstate
              ;lda #STATE_DELAY ; fast
game_set_state_frames:
              ldy #0   ; otherwise ready frames are skipped immediately
              sty game_state+GameState::frames
game_set_state:
              sta game_state+GameState::state
              rts


game_level_init:
              lda game_state+GameState::state
              cmp #STATE_LEVEL_INIT
              beq :+
              rts

:             lda game_state+GameState::level
              jsr bonus_for_level
              sty game_state+GameState::bonus

              lda #MAX_DOTS
              sta game_state+GameState::dots

              lda #0
              sta game_state+GameState::dot_cnt
              ldx #ACTOR_INKY
              sta actors+actor::dot_cnt,x
              ldx #ACTOR_PINKY
              sta actors+actor::dot_cnt,x
              ldx #ACTOR_CLYDE
              sta actors+actor::dot_cnt,x

              jsr draw_frame

              lda #STATE_READY
              jmp game_set_state_frames


game_level_cleared:
              lda game_state+GameState::state
              cmp #STATE_LEVEL_CLEARED
              bne @exit

              jsr actors_invisible

              lda game_state+GameState::frames
              cmp #$88
              bne @rotate

              inc game_state+GameState::level ; next level

              lda #STATE_LEVEL_INIT
              jmp game_set_state_frames
@rotate:
              lsr
              lsr
              lsr
              and #$03
              tay
              jmp gfx_rotate_pal
@exit:        rts

select_player_score:
              ldx game_state+GameState::active_up
              inx
              inx
              inx
              rts

draw_scores:  ldx #0
              ldy #19
              setPtr (game_state+GameState::score), p_game
              jsr _draw_score
              ldx #0
              ldy #6
draw_highscore:
              setPtr (game_state+GameState::highscore), p_game
_draw_score:
              stx sys_crs_x
              sty sys_crs_y
              lda #Color_Text
              sta text_color
              ldy #2
@next:        lda (p_game),y
              bne :+
              dec sys_crs_y ; leading 00, skip digits
              dec sys_crs_y
              dey
              bpl @next
              rts
:             and #$f0  ;0? ?
              bne @digits
              dec sys_crs_y ;output the 0-9 only
              lda (p_game),y
              jsr out_digit
              jmp @digits_inc
@digits:      lda (p_game),y
              jsr out_digits
@digits_inc:  dey
              bpl @digits
              rts


animate_screen:
              jsr animate_up
animate_energizer:
              ldy #Color_Food
              lda game_state+GameState::frames
              and #$08
              bne draw_energizer
              tay
draw_energizer:
              sty text_color
              ldx #3
@l0:          lda energizer_x,x
              sta sys_crs_x
              ldy energizer_y,x
              sty sys_crs_y
              jsr lda_maze_ptr_ay
              cmp #Char_Blank ; eaten?
              beq @next
              jsr gfx_charout
@next:        dex
              bpl @l0
              rts
animate_up:
              ldy #Color_Text
              lda game_state+GameState::frames
              and #$10
              bne @l0
              tay ; A = 0 => Color_Bg
@l0:          sty text_color
              lda game_state+GameState::active_up
              bne @2_up
              draw_text _text_1up
              rts
@2_up:        draw_text _text_2up
              rts


animate_ghosts:
              ldx #ACTOR_BLINKY
              jsr actor_shape_move
              ldx #ACTOR_INKY
              jsr actor_shape_move
              ldx #ACTOR_PINKY
              jsr actor_shape_move
              ldx #ACTOR_CLYDE
              jmp actor_shape_move

game_init:
              lda game_state+GameState::state
              cmp #STATE_INIT
              beq :+
              rts

:             jsr sound_init_game_start

              jsr system_dip_switches_lives
              sty game_state+GameState::lives_1up
              sty game_state+GameState::lives_2up
              sty game_state+GameState::lives

              jsr system_dip_switches_bonus_life
              stx game_state+GameState::bonus_life+1  ; save trigger points for bonus pacman
              sta game_state+GameState::bonus_life+0

              lda #1 ; start with level 1
              sta game_state+GameState::level

              ldy #2
              lda #0
:             sta game_state+GameState::score_1up,y
              sta game_state+GameState::score_2up,y
              sta game_state+GameState::score,y
              dey
              bpl :-

              jsr draw_frame

              ldy game_state+GameState::lives
              jsr gfx_lives

              draw_text _text_player_one, Color_Cyan
              lda game_state+GameState::players
              beq :+
              draw_text _text_player_two
:
              lda #STATE_LEVEL_INIT
              jmp game_set_state_frames_delay

game_init_actors:
              ldy #0
              ldx #ACTOR_BLINKY
              jsr game_init_actor
              ldx #ACTOR_INKY
              jsr game_init_actor
              ldx #ACTOR_PINKY
              jsr game_init_actor
              ldx #ACTOR_CLYDE
              jsr game_init_actor
              lda game_state+GameState::level
              cmp #1
              bne :+
              lda #60 ; level 1 - dot limit clyde 60
              sta actors+actor::dot_limit,x
              lda #30 ;           dot limit inky 30
              ldx #ACTOR_INKY
              sta actors+actor::dot_limit,x
:             cmp #2
              bne :+
              lda #50 ;           dot limit clyde 50
              sta actors+actor::dot_limit,x
:
              jsr animate_ghosts  ; update shape

              ldx #ACTOR_PACMAN
              jsr game_init_actor
              lda #2  ; pacman shape complete ball
              sta actors+actor::shape,x
              lda #0
              sta actors+actor::mask,x

              jmp gfx_sprites_on

game_init_actor:
              lda actor_init_x,y
              sta actors+actor::sp_x,x
              lda actor_init_y,y
              sta actors+actor::sp_y,x
              lda actor_init_d,y
              sta actors+actor::move,x
              lda #$10  ; ghost shape offset
              sta actors+actor::mask,x
              lda actor_init_strategy,y
              sta actors+actor::strategy,x
              lda #0
              sta actors+actor::dot_limit,x
              iny
              rts


actor_init_x: ; sprite pos x of blinky,pinky,inky,clyde,pacman
    .byte 100,$7c,$7c,$7c,196
actor_init_y:
    .byte 112,128,112,96,112
actor_init_d:
    .byte ACT_MOVE|ACT_LEFT, ACT_MOVE|ACT_UP, ACT_MOVE|ACT_DOWN, ACT_MOVE|ACT_UP, ACT_MOVE|ACT_LEFT<<2 | ACT_LEFT
actor_init_strategy:
    .byte GHOST_STATE_CATCH  ; blinky
    .byte GHOST_STATE_BASE
    .byte GHOST_STATE_BASE
    .byte GHOST_STATE_BASE

actor_init: ;x,y,init direction
    ; x, y, dir
    .byte 64,$a4,  ACT_MOVE|ACT_LEFT
    .byte 88,$a4,   ACT_MOVE|ACT_UP
    .byte 112,$a4,  ACT_MOVE|ACT_DOWN

;    .byte 136,$a4,  ACT_MOVE|ACT_UP
      .byte 124,88,  ACT_MOVE|ACT_UP

    .byte 196,104,  ACT_MOVE|ACT_LEFT<<2 | ACT_LEFT ; pacman

;    .byte 100,104,  ACT_MOVE|ACT_LEFT
;    .byte 124,120, ACT_MOVE|ACT_UP
;    .byte 124,104,  ACT_MOVE|ACT_DOWN
;    .byte 124,88,  ACT_MOVE|ACT_UP
;    .byte 196,104,  ACT_MOVE|ACT_LEFT<<2 | ACT_LEFT ; pacman
actor_init_end:


.data

maze:
  .include "pacman.maze.inc"

energizer_x:
   .byte 4,24,4,24
energizer_y:
   .byte 1,1,26,26

_vectors:  ; X, Y adjust
_vec_right:      ;00
    .byte 0,$ff  ; +0 X, -1 Y, screen is rotated 90 degree clockwise ;)
_vec_left:      ;01
    .byte 0, 1
_vec_up:        ;10
    .byte $ff,0
_vec_down:      ;11
    .byte 1, 0

_text_1up:
    .byte 0, 24, "1UP",0
_text_2up:
    .byte 0, 24, "2UP",0
_text_pacman:
    .byte 12,15, "PACMAN",0
_text_demo:
    .byte 18,15, "DEMO!",0

_text_player_one:
    .byte 12,18, "PLAYER ONE",0
_text_player_two:
    .byte 12,11, "TWO",0
_ready:
    .byte 18,16, "READY!"
    .byte 0
_text_game_over:
    .byte 18,18, "GAME  OVER",0



points: ; score values in BCD format
Pts_Index_Dot=(*-points)
  .byte $00,$10 ; dot / pill
; bonus at 70 dots, 170 dots - visible between nine and ten seconds. The exact duration (i.e., 9.3333 seconds, 10.0 seconds, 9.75
  .byte $01,$00 ; cherry
  .byte $03,$00 ; strawberry
  .byte $05,$00 ; orange
  .byte $07,$00 ; apple
  .byte $10,$00 ; grapes
  .byte $20,$00 ; galaxian
  .byte $30,$00 ; bell
  .byte $50,$00 ; key
Pts_Index_Energizer=(*-points)
  .byte $00,$50 ; energizer
Pts_Index_Level_Cleared=(*-points)
  .byte $26,$00 ; level cleared
  .byte $02,$00 ; ghost catched 200,400,800,1600pts (shift left for any further ghost) - blue time reduced from 7 to 2s
Pts_Index_All_Ghosts=(*-points) ;TODO
  .byte $01,$20,$00 ; 4 times all ghosts catched, 12.000 pts extra

.export game_maze
.export actors

.bss
  save_irq:         .res 2
  input_direction:  .res 1
  keyboard_input:   .res 1
  actors:           .res 5*.sizeof(actor)
  game_maze         = ((__BSS_RUN__+__BSS_SIZE__) & $ff00)+$100  ; put at the end of BSS which is BSS_RUN + BSS_SIZE and align with $100
  path_maze         = game_maze + $400
