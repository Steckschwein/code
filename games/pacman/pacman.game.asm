.export game
.export maze
.export draw_highscore
.export bonus_for_level

.include "pacman.inc"

.autoimport

.importzp sys_crs_x, sys_crs_y

.zeropage
  game_tmp:   .res 1
  game_tmp2:  .res 1
  rx1:        .res 2
  px:         .res 1  ; maze point x
  py:         .res 1  ; maze point y

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

    border_color Color_Green
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
              jsr pacman_move

              ldx #ACTOR_BLINKY
              jsr ghost_move
              ldx #ACTOR_PINKY
              jsr ghost_move
              ldx #ACTOR_INKY
              jsr ghost_move
              ldx #ACTOR_CLYDE
              jsr ghost_move

              ldy #ACTOR_PACMAN
              ldx #ACTOR_BLINKY
              jsr @pacman_hit
              beq @pacman_dead
              ldx #ACTOR_PINKY
              jsr @pacman_hit
              beq @pacman_dead
              ldx #ACTOR_INKY
              jsr @pacman_hit
              beq @pacman_dead
              ldx #ACTOR_CLYDE
              jsr @pacman_hit
              bne @exit
@pacman_dead: lda actors+ghost::mode,x
              cmp #GHOST_MODE_NORM
              beq @dying
              lda #GHOST_STATE_RETURN
              sta actors+ghost::strategy,x
              lda #GHOST_MODE_CATCHED
              sta actors+ghost::mode,x
              rts
@dying:       lda #STATE_PACMAN_DYING
              jmp game_set_state_frames_delay
@pacman_hit:
              lda actors+actor::xpos,x
              cmp actors+actor::xpos,y
              bne @exit
              lda actors+actor::ypos,x
              cmp actors+actor::ypos,y
@exit:        rts


shape_offs:  ; normal, frightened, catched ghost
  .byte Shape_Offset_Norm,Shape_Offset_Catched,Shape_Offset_Fright
shape_mask:
  .byte Shape_Mask_Norm,Shape_Mask_Norm,Shape_Mask_Fright

ghost_move:   jsr actor_update_charpos
              ldy actors+ghost::mode,x
              lda shape_offs,y
              sta actors+ghost::shape_offs,x
              lda shape_mask,y
              sta actors+ghost::shape_mask,x
              jsr ghost_update_shape

              lda actors+ghost::strategy,x
ghost_base:   cmp #GHOST_STATE_BASE
              bne ghost_leave_base

              lda game_state+GameState::frames
              and #$01
              bne @exit

              lda actors+actor::sp_x,x
              bmi @inverse  ; $80 ?
              cmp #$78
              beq @inverse
              cmp #$7c
              bne @move
@leave:       lda actors+ghost::dot_cnt,x
              cmp actors+ghost::dot_limit,x
              bne @move
              lda #GHOST_STATE_LEAVE
              sta actors+ghost::strategy,x
@exit:        rts
@inverse:     lda actors+actor::move,x
              eor #ACT_MOVE_INVERSE_NEXT|ACT_MOVE_INVERSE
              sta actors+actor::move,x
@move:        jmp actor_move_soft

ghost_leave_base:
              cmp #GHOST_STATE_LEAVE
              bne ghost_move_target

              lda game_state+GameState::frames
              and #$01
              bne @exit

              lda actors+actor::sp_y,x
              cmp #112  ; middle of house ?
              beq @mov_middle
              bcc @mov_left
              lda #ACT_MOVE|ACT_RIGHT<<2|ACT_RIGHT
              bne @move
@mov_left:    lda #ACT_MOVE|ACT_LEFT<<2|ACT_LEFT
@move:        sta actors+actor::move,x
              jmp actor_move_soft
@mov_middle:  lda actors+actor::sp_x,x
              cmp #100
              beq @base_leaved
              lda #ACT_MOVE|ACT_UP<<2|ACT_UP
              bne @move
@base_leaved: lda #ACT_MOVE|ACT_LEFT<<2|ACT_LEFT
              sta actors+actor::move,x
              lda #GHOST_STATE_TARGET
              sta actors+ghost::strategy,x
@exit:        rts


ghost_move_target:
              cmp #GHOST_STATE_RETURN
              bne :+
              jsr move_target
              jmp move_target

:             lda actors+ghost::mode,x
              beq move_target
              lda game_state+GameState::frames
              and #$01
              beq move_target
              rts
move_target:
              lda actors+actor::move,x
              jsr actor_center  ; center reached?
              beq :+
              jmp actor_move_soft

:             lda actors+ghost::strategy,x
              cmp #GHOST_STATE_RETURN
              bne move_dir

              lda #$0c  ; TODO
              sta actors+ghost::tgt_x,x
              lda #$0e
              sta actors+ghost::tgt_y,x

              cmp actors+actor::ypos,x
              bne move_dir
              lda actors+ghost::tgt_x,x
              cmp actors+actor::xpos,x
              bne move_dir
; base reached
              lda #GHOST_STATE_TARGET
              sta actors+ghost::strategy,x
              lda #GHOST_MODE_NORM
              sta actors+ghost::mode,x
              rts

move_dir:     lda actors+actor::move,x
              lsr ; next dir to current direction
              lsr
              and #ACT_DIR
              sta actors+actor::move,x
              jsr lda_actor_charpos_direction
              cmp #Char_Base ; sanity check wont be C=1
              bcs halt

              lda actors+actor::move,x
              eor #ACT_MOVE_INVERSE
              sta game_tmp2 ; exclude inverse of the new direction

              sec
              lda p_maze+0
              sbc #32 ; adjust maze ptr one char line above (tile right)
              sta p_maze+0
              lda p_maze+1
              sbc #0
              sta p_maze+1

              lda actors+ghost::mode,x
              beq @short_dist   ; normal ?
              cmp #GHOST_MODE_CATCHED
              beq @short_dist   ; catched ?

; random choose next direction
;              .byte $db
              jsr system_rng
@check_dir:   and #ACT_DIR
              sta target_dir
              cmp game_tmp2 ; discard inverse direction ?
              beq @next_dir
              tay
              lda _p_index,y
              tay
              lda (p_maze),y
              cmp #Char_Base
              bcc @next_direction
@next_dir:    inc target_dir
              lda target_dir
              jmp @check_dir

@short_dist:
; check new direction in order up,left,down,right
              lda #$ff  ; init 16bit distance "far away"
              sta target_dist+0
              sta target_dist+1

              lda #ACT_UP
              sta game_tmp
@check:       lda game_tmp
              cmp game_tmp2 ; discard inverse direction ?
              beq @next
              tay
              lda _p_index,y
              tay
              jsr calc_distance
@next:        dec game_tmp
              bpl @check

@next_direction:
              lda target_dir  ; setup next direction from calculation
              asl
              asl
              ora #ACT_MOVE   ; enable move
              ora actors+actor::move,x
              sta actors+actor::move,x

move_soft:    jmp actor_move_soft

halt:         .byte $db
              nop
              rts

; shortest distance to target via look ahead one tile in move direction
; same distance => order: up, left, down, right
; we compare |x1-x2|² + |y1-y2|² with a previously stored sum, cause we dont need the distance. we just decide which direction.
calc_distance:lda (p_maze),y
              cmp #Char_Base
              bcs @exit ; carry from cmp above
              ldy game_tmp
              cmp #Char_Not_Up
              bne :+
              cpy #ACT_UP
              beq @exit
:             clc
              lda px
              adc _vectors_x,y
              sec
              sbc actors+ghost::tgt_x,x
              bpl :+
              eor #$ff
:             tay
              lda _squares_l,y
              sta rx1+0
              lda _squares_h,y
              sta rx1+1

              ldy game_tmp
              clc
              lda py
              adc _vectors_y,y
              sec
              sbc actors+ghost::tgt_y,x
              bpl :+
              eor #$ff
:             tay
              clc
              lda _squares_l,y
              adc rx1+0
              sta rx1+0
              lda _squares_h,y
              adc rx1+1
              sta rx1+1
              cmp target_dist+1
              beq :+    ; == ?
              bcs @exit ; > ?
:             lda rx1+0
              cmp target_dist+0
              bcs @exit ; >= ?
              sta target_dist+0 ; save new shortest distance
              lda rx1+1
              sta target_dist+1
              lda game_tmp
              sta target_dir ; save direction of shortest distance
@exit:        rts


ghost_update_shape:
              lda game_state+GameState::frames
              lsr
              lsr
              lsr
              and #$01
              sta actors+actor::shape,x

              lda actors+actor::move,x
              and #ACT_NEXT_DIR
              ora actors+actor::shape,x
              ora actors+ghost::shape_offs,x
              and actors+ghost::shape_mask,x
              sta actors+actor::shape,x
              rts

; .A new direction
pacman_cornering:
              tay
              lda #$07
              sta game_tmp2
              lda actors+actor::move,x
              and #$03  ; either +x or +y, down or left
              beq :+   ; 00 ? (ACT_RIGHT)
              cmp #ACT_UP
              beq :+
              lda #0
              sta game_tmp2
:             tya
l_test:
              and #ACT_MOVE_UP_OR_DOWN    ; new direction is a turn
              bne l_up_or_down            ; so we have to test with the current direction (orthogonal)
l_left_or_right:
              lda actors+actor::sp_x,x
              jmp l_compare ; always branch
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

pacman_move:  lda pacman+pacman::delay
              beq :+
              dec pacman+pacman::delay
@exit:        rts
:
              lda game_state+GameState::frames
              and #$01
       ;       bne @exit

              lda actors+pacman::turn,x
              bpl @move_dir      ; turning?
              jsr actor_center
              bne @turn_soft
              lda actors+pacman::turn,x
              and #<~ACT_TURN
              sta actors+pacman::turn,x
@turn_soft:   lda actors+pacman::turn,x
              jsr actor_move_sprite
@move_dir:
              lda actors+actor::move,x
              bpl :+
              jsr @move
:             jmp pacman_collect
@move:
              jsr actor_center   ; center reached?
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
              sta actors+actor::shape,x

              lda actors+actor::move,x
              and #ACT_DIR
              asl
              asl
              ora actors+actor::shape,x
              sta actors+actor::shape,x

actor_move_soft:
              lda actors+actor::move,x
actor_move_sprite:
              bpl @exit
              and #ACT_DIR
              tay
              clc
              lda actors+actor::sp_x,x
              adc _vectors_x,y
              sta actors+actor::sp_x,x

              clc
              lda actors+actor::sp_y,x
              ;cmp #$df
              ;beq @exit
 ;             .byte $db
              adc _vectors_y,y
              sta actors+actor::sp_y,x
@exit:        rts

pacman_collect:
              lda pacman+actor::xpos
              sta sys_crs_x
              ldy pacman+actor::ypos
              sty sys_crs_y
              jsr lda_maze_ptr_ay
              cmp #Char_Energizer
              bne :+
              dec game_state+GameState::dots
              lda #GHOST_MODE_FRIGHT
              sta actors+ACTOR_BLINKY+ghost::mode
              sta actors+ACTOR_PINKY+ghost::mode
              sta actors+ACTOR_INKY+ghost::mode
              sta actors+ACTOR_CLYDE+ghost::mode

              lda #Delay_Energizer
              sta pacman+pacman::delay
              lda #Pts_Index_Energizer
              bne @score_and_erase
:             cmp #Char_Dot
              bne :+
              dec game_state+GameState::dots
              inc pacman+pacman::delay
              lda #Pts_Index_Dot
              beq @score_and_erase  ; dots index is 0
:             cmp #Char_Bonus
              beq @bonus
              rts

@bonus:       lda #Bonus_Clear
              jsr gfx_bonus
              lda #Color_Pink
              ldx #$12
              ldy #$0f
              jsr sys_set_pen
              lda game_state+GameState::bonus
              and #$1f
              sec     ; TODO adjust table
              sbc #1
              asl
              asl
              tay
              ldx #4
:             lda points_digits,y
              jsr sys_charout
              iny
              dex
              bne :-
              lda #Bonus_Pts_Time
              sta game_state+GameState::bonus_cnt
              lda game_state+GameState::bonus
              and #$1f  ; mask bonus for index to points table
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


; in:   A - direction
; out:  C=0 can move, C=1 can not move to direction
actor_can_move_to_direction:
              jsr lda_actor_charpos_direction     ; update dir char pos
              cmp #Char_Base                      ; C=1 if char >= Char_Base which is a maze wall (>=$d0)
              rts

pacman_input:
              jsr get_input
              bcc @exit                       ; key/joy input ?
              sta input_direction
              jsr actor_can_move_to_direction ; C=0 can move
              bcs @set_input_dir_to_next_dir  ; no - only set next dir

              lda actors+pacman::turn,x
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

;              lda actors+actor::ypos,x      ;is tunnel ?
 ;             beq @exit                    ;ypos=0
  ;            cmp #28                  ;... or >=28
   ;           bcs @exit                    ;ignore input

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
              sta actors+pacman::turn,x

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
@exit:        rts

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
    lda actors+pacman::turn,x
    jsr out_hex_digits
    lda keyboard_input
    jsr out_hex_digits
    pla
    tax
    pla
    jsr out_hex_digits
    rts

; in:  .A - direction
lda_actor_charpos_direction:
              tay
              lda actors+actor::xpos,x
              clc
              adc _vectors_x,y
              sta px
              lda actors+actor::ypos,x
              clc
              adc _vectors_y,y
              sta py
              tay
              jmp lda_maze_ptr

; in: A/Y - as x/y char postition
; out: A - char at position
lda_maze_ptr_ay:
              sta px
              tya           ; y * 32
lda_maze_ptr:
              asl
              asl
              asl
              asl
              asl
              ora px
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
:             lda #Char_Blank
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
              ;jsr animate_ghosts

              jsr animate_screen
              jsr animate_bonus

              jsr update_target

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

update_target:
              ; Ghosts are forced to reverse direction by the system anytime the mode changes from: chase-to-scatter, chase-to-frightened, scatter-to-chase, and scatter-to-frightened.
              ; Ghosts do not reverse direction when changing back from frightened to chase or scatter modes.
              rts

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

              lda #Char_Blank ; reset to blank char in maze
              sta game_maze+($12+$20*$0d) ; below ghost base
              lda #Bonus_Clear
              jsr gfx_bonus
              ldx #$12
              ldy #$0f
              lda #4
              jmp sys_blank_xy
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
              sta game_maze+($12+$20*$0d) ; below ghost base
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
              sta game_state+GameState::bonus_cnt
              sta game_state+GameState::rng+0
              sta game_state+GameState::rng+1

              ldx #ACTOR_INKY
              sta actors+ghost::dot_cnt,x
              ldx #ACTOR_PINKY
              sta actors+ghost::dot_cnt,x
              ldx #ACTOR_CLYDE
              sta actors+ghost::dot_cnt,x

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


game_init:
              lda game_state+GameState::state
              cmp #STATE_INIT
              beq :+
              rts

:             jsr sound_init_game_start

              jsr system_dip_switches_lives
 ;             sty game_state+GameState::lives_1up
;              sty game_state+GameState::lives_2up
              sty game_state+GameState::lives

              jsr system_dip_switches_bonus_life
              stx game_state+GameState::bonus_life+1  ; save trigger points for bonus pacman
              sta game_state+GameState::bonus_life+0

              lda #3 ; start with level 1
              sta game_state+GameState::level

              ldy #2
              lda #0
:;             sta game_state+GameState::score_1up,y
;              sta game_state+GameState::score_2up,y
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
              jsr @init_ghost
              ldx #ACTOR_PINKY
              jsr @init_ghost
              ldx #ACTOR_INKY
              jsr @init_ghost
              ldx #ACTOR_CLYDE
              jsr @init_ghost
              lda game_state+GameState::level
              cmp #1
              bne :+
              lda #60 ; level 1 - dot limit clyde 60
              sta actors+ghost::dot_limit,x
              lda #30 ;           dot limit inky 30
              ldx #ACTOR_INKY
              sta actors+ghost::dot_limit,x
:             cmp #2
              bne :+
              lda #50 ;           dot limit clyde 50
              sta actors+ghost::dot_limit,x
:
              ;jsr animate_ghosts  ; update shape

              ldx #ACTOR_PACMAN
              jsr @init_actor
              lda #2  ; pacman shape complete ball
              sta actors+actor::shape,x
              lda #0
              sta actors+pacman::delay,x
              jmp gfx_sprites_on

@init_ghost:
              lda #Shape_Offset_Norm  ; ghost shape offset
              sta actors+ghost::shape_offs,x
              lda #Shape_Mask_Norm
              sta actors+ghost::shape_mask,x
              lda ghost_init_state,y
              sta actors+ghost::strategy,x
              lda #0
              sta actors+ghost::dot_limit,x
              sta actors+ghost::mode,x
              lda ghost_init_sct_x,y
              sta actors+ghost::sct_x,x
              sta actors+ghost::tgt_x,x
              lda ghost_init_sct_y,y
              sta actors+ghost::sct_y,x
              sta actors+ghost::tgt_y,x
              lda ghost_init_color,y
              sta actors+ghost::color,x
@init_actor:
              lda actor_init_x,y
              sta actors+actor::sp_x,x
              lda actor_init_y,y
              sta actors+actor::sp_y,x
              lda actor_init_d,y
              sta actors+actor::move,x
              iny
              rts

.data

maze:
  .include "pacman.maze.inc"

actor_init_x: ; sprite pos x of blinky,pinky,inky,clyde,pacman
    .byte 100,$7c,$7c,$7c,196
actor_init_y:
    .byte 112,128,112,96,112
actor_init_d:
    .byte ACT_MOVE|ACT_LEFT<<2|ACT_LEFT
    .byte ACT_MOVE|ACT_UP<<2|ACT_UP
    .byte ACT_MOVE|ACT_DOWN<<2|ACT_DOWN
    .byte ACT_MOVE|ACT_UP<<2|ACT_UP
    .byte ACT_MOVE|ACT_LEFT<<2|ACT_LEFT

ghost_init_color:
    .byte Color_Blinky,Color_Pinky,Color_Inky,Color_Clyde
ghost_init_sct_x: ; ghost scatter targets
    .byte $00,$00,$1f,$1f
ghost_init_sct_y:
    .byte $04,$17,$00,$1b
ghost_init_state:
    .byte GHOST_STATE_TARGET  ; blinky
    .byte GHOST_STATE_BASE
    .byte GHOST_STATE_BASE
    .byte GHOST_STATE_BASE

_squares_l:
    .byte $01,$01,$04,$09,$10,$19,$24,$31,$40,$51,$64,$79,$90,$A9,$C4,$E1,$00,$21,$44,$69,$90,$B9,$E4,$11,$40,$71,$A4,$D9,$10,$49,$84,$C1
_squares_h:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03,$03

energizer_x:
   .byte 4,24,4,24
energizer_y:
   .byte 1,1,26,26

_p_index: ; y pointer offsets to p_maze - up, left, down, right
  .byte 0, 33, 64, 31

_vectors_x:  ; X, Y adjust +0 X, -1 Y, screen is rotated 90 degree clockwise ;)
    .byte $00,$01,$00,$ff
_vectors_y:
    .byte $ff,$00,$01,$00

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

points_digits:
  .byte Char_Blank,$01,$05,Char_Blank
  .byte Char_Blank,$02,$05,Char_Blank
  .byte Char_Blank,$03,$05,Char_Blank
  .byte Char_Blank,$04,$05,Char_Blank
  .byte Char_Blank,$06,$0d,$0e
  .byte $07,$08,$0d,$0e
  .byte $09,$0a,$0d,$0e
  .byte $0b,$0c,$0d,$0e


.export game_maze
.export actors

.bss
  save_irq:         .res 2
  input_direction:  .res 1
  keyboard_input:   .res 1
  actors:
  ghosts:           .res 4*.sizeof(ghost)
  pacman:           .res 1*.sizeof(pacman)
  target_dist:      .res 2  ; word
  target_dir:       .res 1
  game_maze         = ((__BSS_RUN__+__BSS_SIZE__) & $ff00)+$100  ; put at the end of BSS which is BSS_RUN + BSS_SIZE and align with $100