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

@call_state_fn:
              jmp (game_state+GameState::fn)

game:         setIRQ game_isr, save_irq

@init_state:  lda #STATE_INIT
@set_state:   jsr game_set_state_frames

@game_loop:
:             lda game_state+GameState::vblank  ; wait vblank
              beq :-
              dec game_state+GameState::vblank

              border_color Color_Green

              ;jsr @call_state_fn
              jsr game_playing
              jsr game_state_delay
              jsr game_init
              jsr game_level_init
              jsr game_ready
              jsr game_ready_wait
              jsr game_pacman_dying
              jsr game_ghost_catched
              jsr game_level_cleared
              jsr game_intermission
              jsr game_game_over

              jsr gfx_prepare_update

              border_color Color_Bg

              lda game_state+GameState::state
              cmp #STATE_INTRO
              beq @exit
              jsr io_getkey
              bcc @game_loop
              sta keyboard_input
              cmp #KEY_EXIT
              bne :+
              lda #STATE_EXIT
              sta game_state+GameState::state
@exit:
              jsr sound_init
              restoreIRQ save_irq
              rts
; debug keys
:   cmp #'r'
    beq @init_state
:   cmp #'d'
    bne :+
    lda #STATE_PACMAN_DYING
    bne @set_state
:   cmp #'g'
    bne :+
    lda #1  ; 1 left
    sta game_state+GameState::lives
    lda #STATE_PACMAN_DYING
    jmp @set_state
    cmp #'i'
    bne :+
    lda #STATE_LEVEL_INIT
    jmp @set_state
:   cmp #'c'
    bne :+
    lda #STATE_LEVEL_CLEARED
    jmp @set_state
:   cmp #'m'
    bne :+
    lda #0
    sta game_state+GameState::sctchs_timer+0
    sta game_state+GameState::sctchs_timer+1
    jmp @game_loop
:   cmp #'p'
    bne :+
    lda game_state+GameState::state
    eor #STATE_PAUSE
    sta game_state+GameState::state
    and #STATE_PAUSE
    jsr gfx_pause
    lda #0
:   cmp #'1'
    bcc :+
    cmp #'4'+1
    bcs :+
    and #$0f
    adc #$ff
    tax
    asl
    clc
    adc #1
    sei
    pha
    ldy ghost_tgt_y,x
    lda ghost_tgt_x,x
    tax
    pla
    jsr sys_set_pen
    lda #'T'
    jsr sys_charout
    cli
:
    jmp @game_loop


game_isr:
    push_axy
    jsr gfx_isr
    bpl @io_isr ; vblank from gfx?

    jsr gfx_update  ; timing critical

    inc game_state+GameState::frames
    lda #1
    sta game_state+GameState::vblank
@io_isr:
    jsr io_isr
    pop_axy
    rti

game_state_delay:
              lda game_state+GameState::state
              cmp #STATE_DELAY
              bne @exit

              lda game_state+GameState::nextstate ; FIXME code smell - delay but during dying pacman we must animate the screen
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
              draw_text ready, Color_Yellow
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

              lda #0
              sta game_state+GameState::sctchs_timer+0
              sta game_state+GameState::sctchs_timer+1
              sta game_state+GameState::frghtd_timer+0
              sta game_state+GameState::frghtd_timer+1
              lda #7  ; mode timings table index
              sta game_state+GameState::sctchs_ix
              lda #%01010101
              sta game_state+GameState::sctchs_mode

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
              draw_text text_game_over, Color_Red
              lda #STATE_GAME_OVER
@set_state:   jmp game_set_state_frames
@pacman_dying:cmp #$0c
              bcs @exit
              adc #Shape_Ix_Dying        ; shape offset
              ldx #ACTOR_PACMAN
              sta actor_shape,x
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

game_intermission:
              lda game_state+GameState::state
              cmp #STATE_INTERMISSION
              bne @exit
;              .byte $db
              ldy #2
              lda game_state+GameState::level
              cmp #2
              beq @im_1
              cmp #5
              beq @im_2
              cmp #9
              beq @im
              cmp #13
              beq @im
              cmp #17
              bne @next
@im_2:        dey
@im_1:        dey
@im:          lda game_state+GameState::frames
              bne :+
              jsr gfx_blank_screen
              lda game_state+GameState::level
              jmp gfx_bonus_stack
:             cmp #$ff
              bne @exit
@next:        inc game_state+GameState::level ; next level
              lda #STATE_LEVEL_INIT
              jmp game_set_state_frames

@exit:        rts



    ; key/joy input ?
    ;  (input direction != current direction)?
    ;  y - input direction reverse current direction?
    ;     y - set current direction = reverse input direction
    ;     n - can move to input direction?
    ;        y - pre-turn? (+4px)
    ;            y - set turn direction = current direction
    ;             - set turn bit on
    ;         - post-turn?  (-3px)
    ;            y - set turn direction = reverse current direction (eor)
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
              ldx #ACTOR_CLYDE
              ;ldx #ACTOR_BLINKY
@loop:        jsr ghost_move
@check_hit:   ldy #ACTOR_PACMAN
              lda actor_xpos,x
              cmp actor_xpos,y
              bne @next
              lda actor_ypos,x
              cmp actor_ypos,y
              bne @next
              lda ghost_mode,x
              cmp #GHOST_MODE_CATCHED ; already catched?
              beq @next
              cmp #GHOST_MODE_NORM    ; otherwise ghost catched
              bne @ghost_hit
@pacman_hit:  lda #STATE_PACMAN_DYING
              ;jmp game_set_state_frames_delay
@next:        dex
              bpl @loop

              lda game_state+GameState::speed_ghst_cnt
              and #$7f  ; mask cnt value
              bne @exit
              lda game_state+GameState::speed_ghst    ; init again
              sta game_state+GameState::speed_ghst_cnt
              rts
@exit:        dec game_state+GameState::speed_ghst_cnt
              rts

@ghost_hit:   stx game_state+GameState::catched_ghost ; ghost number

              lda #GHOST_MODE_BONUS
              sta ghost_mode,x

              lda game_state+GameState::ghosts_tocatch  ; select shape for bonus
              jsr ghost_set_shape

              ;jsr short_dist_catched ; TODO possibility to reverse direction immediately when return

              ldx #ACTOR_PACMAN
              lda #Shape_Ix_Invisible
              sta actor_shape,x

              lda game_state+GameState::ghosts_tocatch  ; 3,2,1,0
              asl
              adc #Pts_Index_Ghost_Catched    ; select score
              jsr add_score

              dec game_state+GameState::ghosts_tocatch
              bpl :+

              dec game_state+GameState::all_ghosts_cnt
              bpl :+
              lda #Pts_Index_All_Ghosts
              jsr add_score
              lda #Pts_Index_All_Ghosts
              jsr add_score

:             lda #STATE_GHOST_CATCHED
              jmp game_set_state_frames

ghost_move:   jsr actor_update_charpos
              jsr ghost_update_shape

              lda ghost_strategy,x
              cmp #GHOST_STATE_TARGET
              beq move_target
ghost_return: cmp #GHOST_STATE_RETURN
              beq :+
              jmp ghost_base

:             lda #$0c  ; TODO clean code, use constants
              sta ghost_tgt_x,x
              lda #$0e
              sta ghost_tgt_y,x

              jsr :+ ; double speed when return to base
:             lda #100
              cmp actor_sp_x,x
              bne move_nodelay
              lda #112
              cmp actor_sp_y,x
              bne move_nodelay
; base reached
              lda #GHOST_STATE_ENTER
              sta ghost_strategy,x
              rts

move_target:  lda game_state+GameState::speed_ghst_cnt
              and #$7f    ; mask cnt
              bne move_nodelay
              lda game_state+GameState::speed_ghst
              beq move_nodelay       ;  0 - 80% speed, 60 frames
              bpl @move_2x
              rts                    ; -1 skip move for this frame
@move_2x:     jsr move_nodelay       ; +1 additional move
move_nodelay:
              ldy actor_ypos,x
              lda actor_xpos,x
              cmp #$0c  ; upper "red zone" ?
              beq @is_red_zone
              cmp #$18  ; lower "red zone" ?
              bne @is_tunnel

@is_red_zone: cpy #$0b
              bcc @move   ; no, move on
              cpy #$10+1
              bcc @update_dir

@is_tunnel:   cmp #$0f
              bne @move
              cpy #$06
              bcc @tunnel
              cpy #$16
              bcc @move

@tunnel:      lda game_state+GameState::frames ; half speed, means every 2nd frame
              and #$01
              beq @update_dir
              rts

@update_dir:  jsr actor_center    ; center reached?
              bne @move_soft
              lda actor_move,x
              and #ACT_NEXT_DIR   ; just take over the new dir, it may have changed due to scatter/chase event
              sta actor_move,x
              lsr
              lsr
              jmp move_dir

@move:        jsr actor_center  ; center reached?
              beq :+
@move_soft:   jmp actor_move_soft

:             lda actor_move,x
              lsr ; next dir to current direction
              lsr
              and #ACT_DIR
              sta actor_move,x
              jsr lda_actor_charpos_direction
              cmp #Char_Base ; sanity check wont be C=1
              bcs halt

              sec
              lda p_maze+0
              sbc #$20 ; adjust maze ptr one char line above (tile right)
              sta p_maze+0
              lda p_maze+1
              sbc #0
              sta p_maze+1

              lda actor_move,x
              eor #ACT_MOVE_REVERSE
              sta game_tmp2 ; exclude reverse of the new direction

              lda ghost_mode,x
              beq short_dist   ; normal ?
              cmp #GHOST_MODE_CATCHED
              beq short_dist   ; catched ?

              jsr system_rng  ; choose next direction randomly
@check_dir:   and #ACT_DIR
              sta target_dir
              cmp game_tmp2 ; reverse direction?
              beq @next_dir
              tay
              lda y_index,y
              tay
              lda (p_maze),y
              cmp #Char_Base
              bcc tgt_direction
@next_dir:    inc target_dir
              lda target_dir
              jmp @check_dir

short_dist_catched:
;              lda #$ff
 ;             sta game_tmp2 ; allow reverse
short_dist:
; check new direction in order up,left,down,right
              lda #$ff  ; init 16bit distance "far away"
              sta target_dist+0
              sta target_dist+1

              lda #ACT_UP
              sta game_tmp
@check:       lda game_tmp
              cmp game_tmp2 ; discard reverse direction
              beq @next
              tay
              lda y_index,y
              tay
;              .byte $db
              jsr calc_distance
@next:        dec game_tmp
              bpl @check

tgt_direction:
              lda target_dir  ; setup next direction from calculation
              asl
              asl
move_dir:     ora #ACT_MOVE   ; enable move
              ora actor_move,x
              sta actor_move,x
              jmp actor_move_soft

halt:         .byte $db
              nop
              rts

; shortest distance to target via look ahead one tile in move direction
; same distance => order: up, left, down, right
; we compare |x1-x2|² + |y1-y2|² with a previously calculated distance (sum). we must not calc the square root (distance),
; the smallest sum is sufficient to decide which direction to go
calc_distance:lda (p_maze),y
              cmp #Char_Base
              bcs @exit ; carry from cmp above

              ldy game_tmp
              clc
              lda px
              adc vectors_x,y
              sec
              sbc ghost_tgt_x,x
              bcs :+
              eor #$ff
              adc #1
:             tay
              cpy #$20
              bcc :+
              .byte $db
:             lda squares_l,y
              sta rx1+0
              lda squares_h,y
              sta rx1+1

              ldy game_tmp
              clc
              lda py
              adc vectors_y,y
              sec
              sbc ghost_tgt_y,x ; TODO can be improved |px-gx| and |py-gy| const. + vector of direction
              bcs :+
              eor #$ff
              adc #1
:             cpy #$20
              bcc :+
              .byte $db
:             tay
              clc
              lda squares_l,y
              adc rx1+0
              sta rx1+0
              lda squares_h,y
              adc rx1+1
              sta rx1+1
              cmp target_dist+1
              beq @equal  ; == ?
              lda rx1+0
              bcs @exit   ; > ?
              bcc @save
@equal:       lda rx1+0
              cmp target_dist+0
              bcs @exit   ; >= ?
@save:        sta target_dist+0 ; save new shortest distance
              lda rx1+1
              sta target_dist+1
              lda game_tmp
              sta target_dir ; save direction of shortest distance
@exit:        rts

ghost_base:   cmp #GHOST_STATE_BASE
              bne ghost_leave_base

              lda game_state+GameState::frames
              and #$01
              bne @exit

              lda actor_sp_x,x
              bmi @reverse  ; $80 ?
              cmp #$78
              beq @reverse
              cmp #$7c
              bne @move
@leave:       lda ghost_dot_cnt,x
              cmp ghost_dot_limit,x
              bne @move
              lda #GHOST_STATE_LEAVE
              sta ghost_strategy,x
@exit:        rts

@reverse:     lda actor_move,x
              eor #ACT_MOVE_REVERSE_NEXT|ACT_MOVE_REVERSE
              sta actor_move,x
@move:        jmp actor_move_soft

ghost_leave_base:
              cmp #GHOST_STATE_LEAVE
              bne @ghost_enter_base

              lda game_state+GameState::frames
              and #$01
              bne @exit

              lda actor_sp_y,x
              cmp #112  ; middle of house ?
              beq @move_middle
              bcc @move_left ; left or right
@move_right:  lda #ACT_MOVE|ACT_RIGHT<<2|ACT_RIGHT
              bne @move
@move_left:   lda #ACT_MOVE|ACT_LEFT<<2|ACT_LEFT
@move:        sta actor_move,x
              jmp actor_move_soft

@move_middle: lda actor_sp_x,x
              cmp #100
              beq @base_leaved
              lda #ACT_MOVE|ACT_UP<<2|ACT_UP
              bne @move
@base_leaved: lda #ACT_MOVE|ACT_LEFT<<2|ACT_LEFT
              sta actor_move,x
              lda #GHOST_STATE_TARGET
              sta ghost_strategy,x
@exit:        rts

@ghost_enter_base:
              cmp #GHOST_STATE_ENTER
              bne @exit

              lda actor_sp_x,x
              bmi @home

              lda #ACT_MOVE|ACT_DOWN<<2|ACT_DOWN
              sta actor_move,x
              jsr actor_move_soft
              jmp actor_move_soft
@home:
              lda actor_sp_y,x
              cmp actor_init_y,x
              beq :+
              bcc @move_left
              bcs @move_right

:             lda actor_init_d,x
              sta actor_move,x
              ; TODO strategy dot count
              lda #GHOST_STATE_LEAVE
              sta ghost_strategy,x
              lda #GHOST_MODE_NORM
              sta ghost_mode,x
              rts


ghost_update_shape:
              lda game_state+GameState::frames
              lsr
              lsr
              lsr
              and #$01
              sta actor_shape,x

              lda actor_move,x
              and #ACT_NEXT_DIR
              ora actor_shape,x
ghost_set_shape:
              ldy ghost_mode,x
              ;ora ghost_shape_offs,x
              ora shape_offs,y
              ;and ghost_shape_mask,x
              and shape_mask,y

              sta actor_shape,x
              rts

shape_offs:  ; normal, catched, frightened, "bonus" ghost
  .byte Shape_Offset_Norm,Shape_Offset_Catched,Shape_Offset_Fright,Shape_Offset_Bonus
shape_mask:
  .byte Shape_Mask_Norm,Shape_Mask_Norm,Shape_Mask_Small,Shape_Mask_Small

; .A new direction
pacman_cornering:
              tay
              lda #$07
              sta game_tmp2
              lda actor_move,x
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
              lda actor_sp_x,x
              jmp l_compare ; always branch
l_up_or_down:
              lda actor_sp_y,x
l_compare:
              eor game_tmp2
              and #$07
              cmp #$04   ; 0100 - center pos, <0100 pre-turn, >0100 post-turn
              rts

;     A - bit 0-1 the direction
actor_center: lda actor_move,x
is_center:    ldy #0
              sty game_tmp2
              eor #ACT_MOVE_UP_OR_DOWN
              jmp l_test

pacman_move:  lda pacman_delay
              beq :+
              dec pacman_delay
              rts
:             lda game_state+GameState::speed_pcmn_cnt
              and #$7f    ; mask cnt
              bne @move_cnt
              lda game_state+GameState::speed_pcmn
              sta game_state+GameState::speed_pcmn_cnt
              beq @move          ; 80% speed, 60 frames
              bmi @exit          ; -1 skip move for this frame
@move_double: jsr @move          ; +1 additional move
              cpx #4    ; assert X kept TODO debug
              beq @move
              .byte $db
@move_cnt:    dec game_state+GameState::speed_pcmn_cnt

@move:        lda game_state+GameState::frames
              and #$1f
;              bne @exit
              lda pacman_turn
              bpl @move_dir      ; turning?
              jsr is_center
              bne @turn_soft
              lda pacman_turn
              and #<~ACT_TURN
              sta pacman_turn
@turn_soft:   lda pacman_turn
              jsr actor_move_sprite
@move_dir:    jsr actor_center  ; center reached?
              bne @move_soft    ; no, move soft

              jsr pacman_collect

              ldx #ACTOR_PACMAN
              lda actor_move,x
              and #ACT_DIR
              jsr actor_can_move_to_direction
              bcc @move_soft    ; C=0 - can move to

              lda actor_move,x  ; otherwise stop move
              and #<~ACT_MOVE
              sta actor_move,x
              and #ACT_NEXT_DIR ; set shape of next direction
              sta actor_shape,x
@exit:        rts
@move_soft:
              lda game_state+GameState::frames
              lsr
              and #$03
              sta actor_shape,x

              lda actor_move,x
              and #ACT_DIR
              asl
              asl
              ora actor_shape,x
              sta actor_shape,x

actor_move_soft:
              lda actor_move,x
actor_move_sprite:
              bpl @exit
              and #ACT_DIR
              tay
              clc
              lda actor_sp_x,x
              adc vectors_x,y
              sta actor_sp_x,x
              clc
              lda actor_sp_y,x
              adc vectors_y,y
              sta actor_sp_y,x
@exit:        rts

pacman_collect:
              lda actor_xpos,x
              sta sys_crs_x
              ldy actor_ypos,x
              sty sys_crs_y
              jsr lda_maze_ptr_ay
              cmp #Char_Energizer
              bne @is_dot
              dec game_state+GameState::dots
              jsr mode_frightened
              lda #Delay_Energizer
              sta pacman_delay
              lda #Pts_Index_Energizer
              bne @score_and_erase
@is_dot:      cmp #Char_Dot
              bne @is_bonus
              dec game_state+GameState::dots
              inc pacman_delay
              lda #Pts_Index_Dot
              beq @score_and_erase  ; dots index is 0
@is_bonus:    cmp #Char_Bonus
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

add_score:    jsr @add_score

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
              clc ; calc next bonus life threshold
              adc game_state+GameState::bonus_life+0
              sta game_state+GameState::bonus_life+0
              lda game_state+GameState::bonus_life+1
              adc game_tmp
              sta game_state+GameState::bonus_life+1
              cld
              ldy game_state+GameState::lives
              inc game_state+GameState::lives
              jmp gfx_lives

 @add_score:  tay
              sed
              clc
              lda game_state+GameState::score+0
              adc scoring_table+1,y ; readable bcd from table
              sta game_state+GameState::score+0
              lda game_state+GameState::score+1
              adc scoring_table+0,y
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
              ldy #0
              lda keyboard_input
              sty keyboard_input          ; "consume" key pressed
              jsr io_player_direction     ; return C=1 if any valid key or joystick input, A=ACT_xxx
              bcc @exit                   ; key/joy input ?
              sta input_direction
              jsr actor_can_move_to_direction ; C=0 can move
              bcs @set_input_dir_to_next_dir  ; no - only set next dir

              lda pacman_turn
              bmi @exit  ;exit if turn is active

              ;current dir == input dir ?
              lda actor_move,x
              and #ACT_DIR
              cmp input_direction             ;same direction ?
              beq @set_input_dir_to_next_dir  ;yes, do nothing...
              ;current dir == reverse input dir ?
              eor #ACT_MOVE_REVERSE
              cmp input_direction
              beq @set_input_dir_to_current_dir

              lda actor_ypos,x      ; is tunnel ?
              beq @exit             ; ypos == 0
              cmp #28               ; ... or >=28
              bcs @exit             ; ignore input

              lda input_direction
              jsr pacman_cornering
              beq @set_input_dir_to_current_dir   ; Z=1 center position, no pre-/post-turn
              lda #0
              bcc @l_preturn                      ; C=0 pre-turn, C=1 post-turn

              lda #ACT_MOVE_REVERSE          ;
@l_preturn:
              eor actor_move,x  ; current direction
              and #ACT_DIR
              ora #ACT_TURN
              sta pacman_turn

@set_input_dir_to_current_dir:
              lda input_direction
              ora #ACT_MOVE
              sta actor_move,x

@set_input_dir_to_next_dir: ; bit 3-2
              lda actor_move,x
              bpl @exit           ; stopped already? (bit 7 = 0), dont change next dir
              lda input_direction
              asl
              asl
              sta game_tmp
              lda actor_move,x
              and #<~ACT_NEXT_DIR
              ora game_tmp
              sta actor_move,x
@exit:        rts

actor_update_charpos: ; offset x=+4,y=+4  => x,y 2,1 => 4+2*8, 4+1*8
              lda actor_sp_x,x
              lsr
              lsr
              lsr
              sta actor_xpos,x
              lda actor_sp_y,x
              lsr
              lsr
              lsr
              sta actor_ypos,x
              rts


; in:  .A - direction
lda_actor_charpos_direction:
              tay
              clc
              lda actor_xpos,x
              adc vectors_x,y
              sta px
              clc
              lda actor_ypos,x
              adc vectors_y,y
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
              draw_text text_pacman
              draw_text text_demo
@exit:        rts
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

game_ghost_catched:
              lda game_state+GameState::state
              cmp #STATE_GHOST_CATCHED
              bne @exit

              jsr animate_screen
              jsr animate_bonus

              ;jsr sound_ghost TODO

              lda game_state+GameState::frames
              and #$3f
              bne @exit

              ldx #ACTOR_PACMAN
              lda actor_move,x
              and #ACT_NEXT_DIR ; make pacman visible again, set shape
              sta actor_shape,x

              ldx game_state+GameState::catched_ghost
              lda #GHOST_STATE_RETURN
              sta ghost_strategy,x
              lda #GHOST_MODE_CATCHED
              sta ghost_mode,x
              lda #STATE_PLAYING    ; continue playing
              jmp game_set_state
@exit:        rts


game_playing:
              lda game_state+GameState::state
              cmp #STATE_PLAYING
              bne @exit

              ldx #ACTOR_PACMAN
              jsr actor_update_charpos
              jsr pacman_input
              jsr pacman_move

              jsr update_mode

              ;jsr game_demo
              jsr actors_move

              jsr animate_screen
              jsr animate_bonus

              lda game_state+GameState::dots   ; all dots collected ?
              ;cmp #230
              bne @exit

              lda #Pts_Index_Level_Cleared
              jsr add_score

              ldx #ACTOR_PACMAN
              lda #Shape_Ix_Pacman  ; pacman shape complete "ball"
              sta actor_shape,x

              lda #STATE_LEVEL_CLEARED
              jmp game_set_state_frames_delay
@exit:        rts


actors_mode:
;              sta game_tmp
              ldy #ACTOR_CLYDE
@next:        ldx ghost_mode,y  ; TODO clobbers X
              cpx #GHOST_MODE_CATCHED
              beq @skip
              ;lda game_tmp
              sta ghost_mode,y
@skip:        dey
              bpl @next
              rts

actors_invisible:
              ldy #ACTOR_CLYDE
              lda #Shape_Ix_Invisible
:             sta actor_shape,y
              dey
              bpl :-
              rts

mode_frightened:
              lda #GHOST_MODE_FRIGHT
              jsr actors_mode
              lda #3
              sta game_state+GameState::ghosts_tocatch

              ldy game_state+GameState::level
              cpy #17 ; no frightened in level 17
              beq actors_reverse
              cpy #19 ; no frightened in level 19+
              bcs actors_reverse

              dey ; adjust for lookup
              lda frghtd_timer_l,y
              sta game_state+GameState::frghtd_timer+0
              lda frghtd_timer_h,y
              sta game_state+GameState::frghtd_timer+1

              lda #2  ; index for frightened speeds
              jsr update_speed

actors_reverse: ; set next direction to reverse of current direction
              ldy #ACTOR_CLYDE
:             lda ghost_strategy,y
              cmp #GHOST_STATE_TARGET
              bne @next
              lda actor_move,y  ; change direction
              and #<~ACT_NEXT_DIR
              sta actor_move,y
              eor #ACT_MOVE_REVERSE
              asl
              asl
              and #ACT_NEXT_DIR
              ora actor_move,y
              sta actor_move,y
@next:        dey
              bpl :-
              rts

update_speed: ;.byte $db
              ldy game_state+GameState::level
              cpy #1      ; level 1 ?
              beq @lvl_1
              cpy #5      ; level 2-4 ?
              bcc @lvl_2_4
              cpy #21     ; level 21+ ?
              bcc @lvl_5_20
              clc
              adc #4      ; +12
@lvl_5_20:    adc #4      ; +8
@lvl_2_4:     adc #4      ; +4
@lvl_1:       tay
              lda speed_table+0,y
              sta game_state+GameState::speed_pcmn
              lda speed_table+1,y
              sta game_state+GameState::speed_ghst
              rts

speed_table:  ; pacman | ghost | fright pacman | fright ghost - bit 7 denotes delay
              .byte 0,  $80 | 20, 7,  $80 | 2  ; level 1
              .byte 7,        15, 5,  $80 | 3  ; level 2-4
              .byte 4,         5, 4,  $80 | 4  ; level 5..20
              .byte 7,         5, 0,        0  ; level 21+

update_mode:  ; Ghosts are forced to reverse direction by the system anytime the mode changes from:
              ;   - chase-to-scatter
              ;   - chase-to-frightened
              ;   - scatter-to-chase
              ;   - scatter-to-frightened.
              ; Ghosts do not reverse direction when changing back from frightened to chase or scatter modes.
              ; ghosts enter frightened mode, the scatter/chase timer is paused...  time runs out, they return to the mode they were in
              ;
              lda game_state+GameState::frghtd_timer+0
              bne :+
              lda game_state+GameState::frghtd_timer+1
              beq @scatter_chase
              dec game_state+GameState::frghtd_timer+1
:             dec game_state+GameState::frghtd_timer+0
              rts

@scatter_chase:
              lda #GHOST_MODE_NORM
              jsr actors_mode

              lda #0 ; speed table index
              jsr update_speed

              lda game_state+GameState::sctchs_timer+0
              bne :+
              dec game_state+GameState::sctchs_timer+1
              bmi @switch_mode
:             dec game_state+GameState::sctchs_timer+0
              and #$03 ; update targets every 4 frames
              beq @select_mode
              rts

@switch_mode: ;.byte $db
              lda game_state+GameState::sctchs_ix
              bmi @exit ; underrun, no more mode switches

              asl ; *2
              adc game_state+GameState::sctchs_ix ; *3
              tay
              lda game_state+GameState::level
              cmp #1      ; level 1 ?
              beq @lvl_1
              cmp #5      ; level 2-4 ?
              bcc @lvl_2_4
              iny
@lvl_2_4:     iny
@lvl_1:       lda mode_timer_l,y
              sta game_state+GameState::sctchs_timer+0
              lda mode_timer_h,y
              sta game_state+GameState::sctchs_timer+1

              lda game_state+GameState::sctchs_ix
              cmp #7              ; skip reverse at initial mode switch
              beq :+
              jsr actors_reverse
:
              lda #0
              sta game_state+GameState::speed_pcmn_cnt
              sta game_state+GameState::speed_ghst_cnt

              dec game_state+GameState::sctchs_ix
              asl game_state+GameState::sctchs_mode

@select_mode: lda game_state+GameState::sctchs_mode
              ;jmp @chase
              bpl @chase

@scatter:     ldy #ACTOR_CLYDE ; set scatter targets to all ghosts
:             lda ghost_init_sct_x,y
              sta ghost_tgt_x,y
              lda ghost_init_sct_y,y
              sta ghost_tgt_y,y
              dey
              bpl :-
@exit:        rts

@chase:       ldx #ACTOR_PACMAN
              lda actor_move,x
              and #ACT_NEXT_DIR
              lsr
              lsr
              sta game_tmp

@tgt_pinky:   tay
              lda vectors_x,y
              asl
              asl
              adc actor_xpos,x
              and #$1f
              sta ghost_tgt_x+ACTOR_PINKY

              lda vectors_y,y
              asl
              asl
              adc actor_ypos,x
              and #$1f
              sta ghost_tgt_y+ACTOR_PINKY

@tgt_inky:    ldy game_tmp
              lda vectors_x,y
              asl
              adc actor_xpos,x
              sec
              sbc actor_xpos+ACTOR_BLINKY
              asl
              clc
              adc actor_xpos+ACTOR_BLINKY
              and #$1f
              sta ghost_tgt_x+ACTOR_INKY

              lda vectors_y,y
              asl
              adc actor_ypos,x
              sec
              sbc actor_ypos+ACTOR_BLINKY
              asl
              clc
              adc actor_ypos+ACTOR_BLINKY
              and #$1f
              sta ghost_tgt_y+ACTOR_INKY

@tgt_clyde:   ldy #ACTOR_CLYDE
              lda actor_xpos,x
              sec
              sbc actor_xpos,y
              bcs :+
              eor #$ff
              adc #1
:             cmp #8
              bcs @clyde_pcmn
              lda actor_ypos,x
              sec
              sbc actor_ypos,y
              bcs :+
              eor #$ff
              adc #1
:             cmp #8
              bcs @clyde_pcmn
@clyde_sct:   lda ghost_init_sct_x,y
              sta ghost_tgt_x,y
              lda ghost_init_sct_y,y
              sta ghost_tgt_y,y
              bcc @tgt_blinky
@clyde_pcmn:  jsr @tgt_pacman

@tgt_blinky:  ldy #ACTOR_BLINKY

@tgt_pacman:  lda actor_xpos,x
              sta ghost_tgt_x,y
              lda actor_ypos,x
              sta ghost_tgt_y,y
              rts


; in: A - level 1..$ff
; out: Y - bonus -
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

              draw_text ready, Color_Yellow

              jsr draw_scores

              ldy game_state+GameState::lives
              jsr gfx_lives

              lda game_state+GameState::level
              jmp gfx_bonus_stack

game_set_state_frames_delay:
              sta game_state+GameState::nextstate
              ;lda #STATE_DELAY ; fast start
game_set_state_frames:
              ldy #0 ; otherwise ready frames are skipped immediately
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

              lda #3
              sta game_state+GameState::all_ghosts_cnt

              lda #0
              sta game_state+GameState::dot_cnt
              sta game_state+GameState::bonus_cnt
              sta game_state+GameState::rng+0
              sta game_state+GameState::rng+1

              ldx #ACTOR_CLYDE
:             sta ghost_dot_cnt,x
              dex
              bpl :-

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

              lda #STATE_INTERMISSION
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
              and #$08  ; TODO colour every 10 frames.
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
              draw_text text_1up
              rts
@2_up:        draw_text text_2up
              rts


game_init:
              lda game_state+GameState::state
              cmp #STATE_INIT
              beq :+
              rts

:             jsr sound_init_game_start

              jsr system_dip_switches_lives
              sty game_state+GameState::lives

              jsr system_dip_switches_bonus_life
              stx game_state+GameState::bonus_life+1  ; save trigger points for bonus pacman
              sta game_state+GameState::bonus_life+0

              lda #1 ; start with level 1
              sta game_state+GameState::level

              ldy #2
              lda #0
:             sta game_state+GameState::score,y
              dey
              bpl :-

              jsr draw_frame

              ldy game_state+GameState::lives
              jsr gfx_lives

              draw_text text_player_one, Color_Cyan
              lda game_state+GameState::players
              beq :+
              draw_text text_player_two
:
              lda #STATE_LEVEL_INIT
              jmp game_set_state_frames_delay

game_init_actors:
              ldx #ACTOR_CLYDE
:             jsr @init_ghost
              dex
              bpl :-
              ldx #ACTOR_CLYDE
              lda game_state+GameState::level
              cmp #1
              bne :+
              lda #60 ; level 1 - dot limit clyde 60
              sta ghost_dot_limit,x
              lda #30 ;           dot limit inky 30
              ldx #ACTOR_INKY
              sta ghost_dot_limit,x
:             cmp #2
              bne :+
              lda #50 ;           dot limit clyde 50
              sta ghost_dot_limit,x
:
              ldx #ACTOR_PACMAN
              jsr @init_actor
              lda #2  ; pacman shape complete ball
              sta actor_shape,x
              lda #0
              sta pacman_delay

              jmp gfx_sprites_on

@init_ghost:
              lda #Shape_Offset_Norm  ; ghost shape offset
              sta ghost_shape_offs,x
              lda #Shape_Mask_Norm
              sta ghost_shape_mask,x
              lda ghost_init_state,x
              sta ghost_strategy,x
              lda ghost_init_color,x
              sta ghost_color,x
              lda #0
              sta ghost_dot_limit,x
              lda #GHOST_MODE_NORM
              sta ghost_mode,x
@init_actor:
              lda actor_init_x,x
              sta actor_sp_x,x
              lda actor_init_y,x
              sta actor_sp_y,x
              lda actor_init_d,x
              sta actor_move,x
              rts

.data

maze:
  .include "pacman.maze.inc"

actor_init_x: ; sprite pos x of blinky,pinky,inky,clyde,pacman
    .byte 100,$7c,$7c,$7c,196
actor_init_y:
    .byte 112,112,128,96,112
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
    .byte $03,$18,$00,$1b
ghost_init_state:
    .byte GHOST_STATE_TARGET  ; blinky
    .byte GHOST_STATE_BASE
    .byte GHOST_STATE_BASE
    .byte GHOST_STATE_BASE


; MODE      LEVEL 1    LEVELS 2-4    LEVELS 5+
; Scatter       7          7          5
; Chase        20         20         20
; Scatter       7          7          5
; Chase        20         20         20
; Scatter       5          5          5
; Chase        20       1033       1037
; Scatter       5       1/60       1/60
; Chase indefinite indefinite indefinite
;
; reverse order
mode_timer_l:
    .byte       0,        0,0
    .byte <(60*05),       0,0
    .byte <(60*20),<(60*09),<(60*$0d)
    .byte <(60*05),<(60*05),<(60*05)
    .byte <(60*20),<(60*20),<(60*20)
    .byte <(60*07),<(60*07),<(60*05)
    .byte <(60*20),<(60*20),<(60*20)
    .byte <(60*07),<(60*07),<(60*05)
mode_timer_h:
    .byte       0,        0,0
    .byte >(60*05),       0,0
    .byte >(60*20),>(60*09),>(60*$0d)
    .byte >(60*05),>(60*05),>(60*05)
    .byte >(60*20),>(60*20),>(60*20)
    .byte >(60*07),>(60*07),>(60*05)
    .byte >(60*20),>(60*20),>(60*20)
    .byte >(60*07),>(60*07),>(60*05)

; frightened timer
frghtd_timer_l:
    .byte <(60*06)  ; level 1
    .byte <(60*05)  ;
    .byte <(60*04)
    .byte <(60*03)
    .byte <(60*02)  ; level 5
    .byte <(60*05)
    .byte <(60*02)
    .byte <(60*02)
    .byte <(60*01)
    .byte <(60*05)  ; level 10
    .byte <(60*02)
    .byte <(60*01)
    .byte <(60*01)
    .byte <(60*03)
    .byte <(60*01)
    .byte <(60*01)
    .byte 0         ; level 17
    .byte <(60*01)  ; level 18

frghtd_timer_h:
    .byte >(60*06)  ; level 1
    .byte >(60*05)  ;
    .byte >(60*04)
    .byte >(60*03)
    .byte >(60*02)  ; level 5
    .byte >(60*05)
    .byte >(60*02)
    .byte >(60*02)
    .byte >(60*01)
    .byte >(60*05)  ; level 10
    .byte >(60*02)
    .byte >(60*01)
    .byte >(60*01)
    .byte >(60*03)
    .byte >(60*01)
    .byte >(60*01)
    .byte 0         ; level 17
    .byte >(60*01)  ; level 18


; squares for 0..31
squares_l:
    .byte $01,$01,$04,$09,$10,$19,$24,$31,$40,$51,$64,$79,$90,$A9,$C4,$E1,$00,$21,$44,$69,$90,$B9,$E4,$11,$40,$71,$A4,$D9,$10,$49,$84,$C1
squares_h:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03,$03

energizer_x:
   .byte 4,24,4,24
energizer_y:
   .byte 1,1,26,26

y_index: ; y pointer offsets to p_maze - up, left, down, right
  .byte 0, 33, 64, 31

vectors_x: ; X, Y adjust +0 X, -1 Y in order r,d,l,u - screen is rotated 90 degree clockwise ;)
    .byte $00,$01,$00,$ff
vectors_y:
    .byte $ff,$00,$01,$00

text_1up:
    .byte 0, 24, "1UP",0
text_2up:
    .byte 0, 24, "2UP",0
text_pacman:
    .byte 12,15, "PACMAN",0
text_demo:
    .byte 18,15, "DEMO!",0
text_player_one:
    .byte 12,18, "PLAYER ONE",0
text_player_two:
    .byte 12,11, "TWO",0
ready:
    .byte 18,16, "READY!"
    .byte 0
text_game_over:
    .byte 18,18, "GAME  OVER",0


scoring_table: ; score values in BCD format
Pts_Index_Dot=(*-scoring_table)
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
Pts_Index_Energizer=(*-scoring_table)
  .byte $00,$50 ; energizer
Pts_Index_Level_Cleared=(*-scoring_table)
  .byte $26,$00 ; level cleared
Pts_Index_Ghost_Catched=(*-scoring_table)
  .byte $16,$00 ; ghost catched 200,400,800,1600pts (shift left for any further ghost) - blue time reduced from 7 to 2s
  .byte $08,$00 ;
  .byte $04,$00 ;
  .byte $02,$00 ;
Pts_Index_All_Ghosts=(*-scoring_table) ;TODO
  .byte $60,$00 ; 4 times all ghosts catched, 12.000 pts extra => 2 * 6.000

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
.export actor_sp_x,actor_sp_y,actor_shape
.export ghost_mode,ghost_color

.bss
  save_irq:         .res 2
  input_direction:  .res 1
  keyboard_input:   .res 1
  actor_sp_x:       .res 5  ; sprite x
  actor_sp_y:       .res 5  ; sprite y
  actor_xpos:       .res 5  ; tile x pos - 0..31
  actor_ypos:       .res 5  ; tile y pos - 0..28
  actor_shape:      .res 5  ; shape
  actor_move:       .res 5  ; bit 7 move, bit 3-2 next direction (ACT_NEXT_DIR mask), bit 1-0 current direction (ACT_DIR mask)
  ghost_color:      .res 4  ; main color
  ghost_shape_mask: .res 4  ; shape mask - for normal, frightened or catched ghost
  ghost_shape_offs: .res 4  ; offset for normal frightened or catched ghost
  ghost_strategy:   .res 4  ; ghost movement strategy - in base, leaving base, return to base, move arround (scatter/chase)
  ghost_mode:       .res 4  ; 0 - normal, 1 - frightened, 2 - catched
  ghost_dot_cnt:    .res 4  ; 0 at start, one counter active at once and only if ghost within the house, pinky, inky, clyde => max. 240 + 4 super food
  ghost_dot_limit:  .res 4  ; ghost leave house, deactivate counter, pinky limit 0, inky limit 30/0 (level1/2..), clyde limit 60/50/0 (level1/2/3..)
  ghost_tgt_x:      .res 4  ; current target tile x
  ghost_tgt_y:      .res 4  ; current target tile y

  pacman_delay:     .res 1  ; amount of frames to delay for various actions - 1 frame eating a dot, 10 frames eating an energizer
  pacman_turn:      .res 1  ; bit 7 turn, bit 1-0 turn direction


  target_dist:      .res 2  ; word
  target_dir:       .res 1
  game_maze         = ((__BSS_RUN__+__BSS_SIZE__) & $ff00)+$100  ; put at the end of BSS which is BSS_RUN + BSS_SIZE and align with $100
