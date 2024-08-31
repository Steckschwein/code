.export maze
.export draw_highscore
.export bonus_for_level
.export actors_move
.export lda_maze_ptr_ay

.export game_demo_init, game_demo_playing
.export game_init, game_level_init
.export game_ready, game_ready_wait
.export game_playing
.export game_ghost_catched
.export game_pacman_dying
.export game_level_cleared
.export game_game_over
.export game_intermission
.export game_state_delay

.ifdef __DEVMODE
.export target_dir
.export target_dist
.endif

.include "pacman.inc"

.autoimport

.importzp sys_crs_x, sys_crs_y

.zeropage
              game_tmp:   .res 1
              game_tmp2:  .res 1
              rx1:        .res 2  ; a 16 bit register
              px:         .res 1  ; maze tile x
              py:         .res 1  ; maze tile y

.code

game_state_delay:
              lda game_state+GameState::fn_state_next ; FIXME code smell - delay state but during dying pacman we must animate the screen
              cmp #FN_STATE_PACMAN_DYING
              bne :+
              jsr animate_screen
:             ;jsr sound_play
              lda game_state+GameState::state_frames
.ifdef __DEVMODE
              and #$00
.endif
              and #$7f
              bne @exit
@state:       tay ; A=0 to Y
              lda game_state+GameState::fn_state_next
              sty game_state+GameState::fn_state_next
              jmp system_set_state_fn
@exit:        rts


.export game_init_actors
game_init_actors:
              ldx #ACTOR_CLYDE
:             jsr @init_ghost
              jsr ghost_update_shape
              dex
              bpl :-
              ldx #ACTOR_PACMAN
              jsr @init_actor

              lda #Shape_Ix_Pacman  ; pacman shape complete ball
              sta actor_shape,x
              lda #0
              sta pacman_delay
              sta pacman_turn
              jmp gfx_sprites_on

@init_ghost:
              lda #Shape_Offset_Norm  ; ghost shape offset
              sta ghost_shape_offs,x
              lda #Shape_Mask_Norm
              sta ghost_shape_mask,x
              lda ghost_init_state,x
              sta ghost_state,x
              lda ghost_init_color,x
              sta ghost_color,x
              lda #0
              sta ghost_speed_offs,x
@init_actor:
              lda actor_init_x,x
              sta actor_sp_x,x
              lda actor_init_y,x
              sta actor_sp_y,x
              lda actor_init_d,x
              sta actor_move,x
              and #ACT_NEXT_DIR
              sta actor_shape,x
              lda #ACTOR_MODE_NORM
              sta actor_mode,x
              sta actor_speed_cnt,x
              rts


game_ready:
              jsr game_init_actors

              lda #0
              sta game_state+GameState::dot_cnt           ; reset global dot counter
              sta ghost_speed_offs+ACTOR_BLINKY           ; reset elroy mode

              sta game_state+GameState::sctchs_timer+0    ; reset mode timer
              sta game_state+GameState::sctchs_timer+1
              sta game_state+GameState::frghtd_timer+0
              sta game_state+GameState::frghtd_timer+1
              lda #7  ; mode timings table index
              sta game_state+GameState::sctchs_ix
              lda #%01010101
              sta game_state+GameState::sctchs_mode

              lda #Bonus_Clear  ; clear bonus
              jsr gfx_bonus

              ldy #Color_Food
              jsr draw_energizer

              jsr reset_dot_timer

              bit game_state+GameState::state ; in intro demo?
              bvc :+
              rts

:             ;jsr sound_play

              draw_text ready, Color_Yellow
              jsr delete_message_1

              ldy game_state+GameState::lives
              dey ; pick 1 live, redraw
              jsr gfx_lives

              lda #FN_STATE_READY_WAIT
              jmp system_set_state_fn

game_ready_wait:
              ;jsr sound_play
              jsr animate_up
.ifndef __DEVMODE
              lda game_state+GameState::state_frames
              cmp #$7f
              bne @detect_joystick
.endif
              jsr delete_message_2

              lda #FN_STATE_PLAYING
              jmp system_set_state_fn
@detect_joystick:
              jmp io_detect_joystick


game_pacman_dying:
              jsr animate_screen
              jsr actors_invisible

              lda game_state+GameState::state_frames
              lsr
              lsr
              lsr
              cmp #$18
              bcs @next_state

              cmp #$0c
              bcs @exit
              adc #Shape_Ix_Dying        ; shape offset
              ldx #ACTOR_PACMAN
              sta actor_shape,x
@exit:        rts

@next_state:  dec game_state+GameState::lives           ; dec 1 live

              lda #Dot_Cnt_Enabled                      ; enable global dot count
              sta game_state+GameState::dot_cnt_state
              lda game_state+GameState::dot_cnt_elroy   ; suspend elroy dot cnt
              ora #Elroy_Suspended
              sta game_state+GameState::dot_cnt_elroy

              lda #FN_STATE_READY
              ldy game_state+GameState::lives
              bne @set_state
              ldy #Color_Food
              jsr draw_energizer
              lda #Bonus_Clear
              jsr gfx_bonus
              draw_text text_game_over, Color_Red
              lda #FN_STATE_GAME_OVER
@set_state:   jmp system_set_state_fn


game_game_over:
              jsr animate_up
              lda game_state+GameState::state_frames
              and #$7f
              bne @exit
@next_state:  lda #FN_STATE_INTRO
              jmp system_set_state_fn
@exit:        rts

game_intermission:
              ldy #2  ; select intermission for level - lvl 2 (im1), lvl 5 (im2), lvl 9,13,17 (im3)
              lda game_state+GameState::level
              cmp #2
              beq @im_2
              cmp #5
              beq @im_1
              cmp #9
              beq @im
              cmp #13
              beq @im
              cmp #17
              bne @next
@im_2:        dey
@im_1:        dey
@im:
              lda game_state+GameState::state_frames
              bne :+
              jsr gfx_blank_screen
              lda game_state+GameState::level
              jsr gfx_bonus_stack
              rts
:             cmp #$ff
              bne @exit
@next:        inc game_state+GameState::level ; next level
              lda #FN_STATE_LEVEL_INIT
              jmp system_set_state_fn
@exit:        rts



actors_move:  jsr ghost_move
              ldy #ACTOR_PACMAN
              lda actor_xpos,x
              cmp actor_xpos,y
              bne @next
              lda actor_ypos,x
              cmp actor_ypos,y
              bne @next
              lda actor_mode,x
              cmp #ACTOR_MODE_CATCHED ; skip if already catched
              beq @next
              cmp #ACTOR_MODE_NORM
              bne @ghost_hit          ; ghost catched
@pacman_hit:  lda #FN_STATE_PACMAN_DYING
.ifndef __DEVMODE
              jmp system_set_state_fn_delay
.endif
@next:        dex
              bpl actors_move
              rts

@ghost_hit:   stx game_state+GameState::ghst_catched ; save current catched ghost number

              lda #ACTOR_MODE_BONUS
              sta actor_mode,x

              lda game_state+GameState::ghsts_to_catch  ; select shape for bonus
              jsr ghost_set_shape

              ldx #ACTOR_PACMAN
              lda #Shape_Ix_Invisible
              sta actor_shape,x

              lda #FN_STATE_GHOST_CATCHED
              bit game_state+GameState::state ; called from intro demo?
              bvs :+
              bpl :+
              lda #FN_STATE_INTRO_GHOST_CATCHED
:             jmp system_set_state_fn

ghost_move:   jsr actor_update_charpos
              jsr ghost_update_shape

              lda ghost_state,x
              cmp #GHOST_STATE_TARGET
              beq @move_target
              cmp #GHOST_STATE_RETURN
              beq @ghost_return
              jmp ghost_base

@ghost_return:lda #$0c  ; TODO clean code, use constants
              sta ghost_tgt_x,x
              lda #$0e
              sta ghost_tgt_y,x

              jsr :+ ; double speed when return to base, call it twice
:             lda #100
              cmp actor_sp_x,x
              bne @move_nodelay
              lda #112
              cmp actor_sp_y,x
              bne @move_nodelay
; base reached
              lda #GHOST_STATE_ENTER
              sta ghost_state,x
              rts

@move_target: lda actor_speed_cnt,x
              and #$7f    ; mask cnt
              bne @move_cnt

              lda actor_mode,x        ; during frightened phase and if the ghost reaches home and thus ghost is switched back to normal(0) the normal speed applies
              bne :+
              ora ghost_speed_offs,x  ; no elroy (0), elroy 1 (3), elroy 2 (4)
:             tay
              lda game_state+GameState::speed_cnt_init+1,y    ; init speed cnt for ghosts (+1)
              sta actor_speed_cnt,x
              beq @move_nodelay     ;  0 - 80% speed, 60 fps (60px/s)
              bmi @exit             ; -1 skip move for this frame (delay)
@move_2x:     jsr @move_nodelay     ; +1 additional move (push)
              jmp @move_nodelay
@move_cnt:    dec actor_speed_cnt,x
@move_nodelay:ldy actor_ypos,x
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
              bne @is_border
              cpy #$06
              bcc @tunnel
              cpy #$16
              bcc @move

@tunnel:      lda game_state+GameState::frames ; half speed is just every 2nd frame
              and #$01
              beq @update_dir
@exit:        rts

@update_dir:  jsr actor_center    ; center reached?
              bne @move_soft
              lda actor_move,x
              and #ACT_NEXT_DIR   ; just take over the new dir, it may have changed due to scatter/chase event
              sta actor_move,x
              lsr
              lsr
              jmp move_dir

@is_border:   cmp #INTRO_TUNNEL_X ; intro tunnel
              bne @move
              cpy #BORDER_RIGHT_Y ; y in right border? (used in intro only)
              bcs @update_dir     ; otherwise move on

@move:        jsr actor_center  ; center reached?
              beq :+
@move_soft:   jmp actor_move_soft

:             lda actor_move,x
              lsr ; next dir to current direction
              lsr
              and #ACT_DIR
              sta actor_move,x
              jsr actor_can_move_to_direction ; sets p_maze to ghost tile
.ifdef __ASSERTIONS
              bcc :+  ; should never be C=1
             .byte $db
:
.endif
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

              lda actor_mode,x
              beq short_dist   ; normal ?
              cmp #ACTOR_MODE_CATCHED
              beq short_dist   ; catched ?

              jsr system_rng  ; choose next direction randomly
@check_dir:   and #ACT_DIR
              sta target_dir
              cmp game_tmp2   ; reverse direction?
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

short_dist_reverse:
;              lda #$ff
 ;             sta game_tmp2 ; allow reverse
short_dist:
; check new direction in order up,left,down,right
              lda #$ff  ; init 16bit distance "far away"
              sta target_dist+0
              sta target_dist+1

              lda #ACT_UP
              sta game_tmp
@check:
              lda game_tmp
              cmp game_tmp2 ; discard reverse direction
              beq @next
              tay
              lda y_index,y
              tay
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

; in:
;   A direction to look ahead
; shortest distance to target via look ahead one tile in given direction (A)
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
.ifdef __ASSERTIONS
              cpy #squares_h-squares_l
              bcc :+
              .byte $db
:
.endif
              lda squares_l,y
              sta rx1+0
              lda squares_h,y
              sta rx1+1

              ldy game_tmp
              clc
              lda py
              adc vectors_y,y
              sec
              sbc ghost_tgt_y,x ; TODO can be improved |px-gx| and |py-gy| are const., add vector of direction afterwards
              bcs :+
              eor #$ff
              adc #1
:             tay
.ifdef __ASSERTIONS
              cpy #squares_h-squares_l
              bcc :+
              .byte $db
:
.endif
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

              lda game_state+GameState::state_frames
              and #$01
              bne @exit

              lda actor_sp_x,x
              bmi @reverse  ; $80 ?
              cmp #$78
              beq @reverse
              cmp #$7c
              bne @move
              cpx #ACTOR_BLINKY
              beq @leave
              lda game_state+GameState::dot_cnt_state ; if global dot counter enabled, the ghost specific dot counter is suspended
              bmi @move
              lda ghost_dot_cnt,x
              bne @move
@leave:       lda #GHOST_STATE_LEAVE
              sta ghost_state,x
@exit:        rts

@reverse:     lda actor_move,x
              eor #ACT_MOVE_REVERSE_NEXT|ACT_MOVE_REVERSE
              sta actor_move,x
@move:        jmp actor_move_soft

ghost_leave_base:
              cmp #GHOST_STATE_LEAVE
              bne @ghost_enter_base

              lda game_state+GameState::state_frames
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
              sta ghost_state,x
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

:             lda #ACT_MOVE|ACT_DOWN<<2|ACT_DOWN  ; always done, if in base they will reverse immediately
              sta actor_move,x
              lda #ACTOR_MODE_NORM
              sta actor_mode,x
              lda #GHOST_STATE_BASE
              sta ghost_state,x
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
              ldy actor_mode,x
              ora shape_offs,y
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

pacman_collect:
              lda actor_xpos,x
              ldy actor_ypos,x
              sta sys_crs_x
              sty sys_crs_y
              jsr lda_maze_ptr_ay
              cmp #Char_Energizer
              bne @is_dot

              jsr mode_frightened

              lda #Delay_Energizer
              sta pacman_delay

              bit game_state+GameState::state ; in intro demo?
              bvs @energizer
              bpl @energizer

              ldx #ACTOR_PACMAN
              lda actor_move,x
              eor #ACT_MOVE_REVERSE
              sta actor_move,x

@erase:       lda #Char_Blank
              ldy #0
              sta (p_maze),y
              jmp gfx_charout

@energizer:   jsr game_dot_logic
              jsr sound_play_pacman
              lda #Pts_Index_Energizer
              bne @score_and_erase

@is_dot:      cmp #Char_Dot
              bne @is_bonus

              jsr game_dot_logic
              inc pacman_delay
              jsr sound_play_pacman

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
              jsr @erase
              pla

add_score:    bit game_state+GameState::state
              bpl :+
              rts

:             tay
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
              bne @bonus_life
              dey
              bpl @cmp

@copy:        ldy #2
:             lda game_state+GameState::score,y
              sta game_state+GameState::highscore,y
              dey
              bpl :-

@bonus_life:  lda game_state+GameState::score+2
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
              jsr gfx_lives
@exit:        jmp draw_scores


base_next_ghost:
              ldx #ACTOR_PINKY
@loop:        lda ghost_state,x
              cmp #GHOST_STATE_BASE
              beq :+
@next:        inx
              cpx #ACTOR_CLYDE+1
              bne @loop
              clc
:             rts


game_dot_logic:
              dec game_state+GameState::dots    ; decrease remaining dots

              ; elroy 1/2 dot logic
              lda game_state+GameState::dot_cnt_elroy
              bpl @elroy_cnt
              ldy ghost_state+ACTOR_CLYDE
              beq :+    ; skip elroy if clyde is still in base
              and #$7f  ; mask elroy suspend bit
@elroy_cnt:   cmp game_state+GameState::dots
              bcc :+  ; TODO clarify whether below trigger or exact dot count, because of clyde in base logic after pacman has been killed
              lda ghost_speed_offs+ACTOR_BLINKY
              cmp #3
              lda #3
              adc #0
              sta ghost_speed_offs+ACTOR_BLINKY
              cmp #4
              beq :+
              lsr game_state+GameState::dot_cnt_elroy ; half dot trigger for 2nd elroy 2

:             lda game_state+GameState::dot_cnt_state ; global dot counter enabled?
              bpl @ghst_dot_cnt

              inc game_state+GameState::dot_cnt ; global dot counter
              lda game_state+GameState::dot_cnt
              ldy #ACTOR_PINKY
              cmp #7
              beq @leave
              iny         ; inky
              cmp #17
              beq @leave
              iny         ; clyde
              cmp #32
              bne reset_dot_timer
              lda ghost_state,y ; in base (0)
              bne reset_dot_timer
              sta game_state+GameState::dot_cnt_state ; A=0, reset global dot counter, ghost dot counter enabled
              sta game_state+GameState::dot_cnt
              beq reset_dot_timer ; branch always

@leave:       lda ghost_state,y
              bne reset_dot_timer
              lda #GHOST_STATE_LEAVE
              sta ghost_state,y
              jmp reset_dot_timer

@ghst_dot_cnt:
              txa
              pha
              jsr base_next_ghost
              bcc @done
              lda ghost_dot_cnt,x
              beq :+
              dec ghost_dot_cnt,x
              jmp @done
:             lda #GHOST_STATE_LEAVE
              sta ghost_state,x
@done:        pla
              tax

reset_dot_timer:
              lda #$b4
              ldy game_state+GameState::level
              cpy #5
              bcs :+
              lda #$f0
:             sta game_state+GameState::dot_timer ; reset timer
              rts

; in:   A - direction
; out:  C=0 can move, C=1 can not move to direction
actor_can_move_to_direction:
              jsr lda_actor_charpos_direction     ; update dir char pos
              cmp #Char_Base                      ; C=1 if char >= Char_Base which is a maze wall (>=$d0)
              rts

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
; tile center reached?
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
pacman_input: lda input_direction
              bmi @exit
              jsr actor_can_move_to_direction ; C=0 can move  ; TODO FIXME pacman stops at right tunnel, cause maze ram is not initialized at x=0,y=-1
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
              cmp #BORDER_RIGHT_Y   ; ... or >=28
              bcs @exit             ; ignore input

              lda input_direction
              jsr pacman_cornering
              beq @set_input_dir_to_current_dir   ; Z=1 center position, no pre-/post-turn
              lda #0
              bcc @l_preturn                      ; C=0 pre-turn, C=1 post-turn

              lda #ACT_MOVE_REVERSE          ;
@l_preturn:   eor actor_move,x  ; current direction
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

.export pacman_move
pacman_move:  ldx #ACTOR_PACMAN
              jsr actor_update_charpos
              jsr pacman_input
              lda pacman_delay
              beq :+
              dec pacman_delay
              rts

:             lda actor_speed_cnt,x
              and #$7f    ; mask cnt
              bne @move_cnt
              ldy actor_mode,x
              lda game_state+GameState::speed_cnt_init,y
              sta actor_speed_cnt,x
              beq @move          ; 80% speed, 60 frames
              bmi @exit          ; -1 skip move for this frame
@move_2x:     jsr @move          ; +1 additional move
.ifdef __ASSERTIONS
              cpx #ACTOR_PACMAN  ; assert X kept
              beq :+
              .byte $db
:
.endif
              jmp @move
@move_cnt:    dec actor_speed_cnt,x
@move:        lda pacman_turn
              bpl @move_dir      ; turning?
              jsr is_center
              bne @turn_soft
              lda pacman_turn
              and #<~ACT_TURN
              sta pacman_turn
@turn_soft:   lda pacman_turn
              jsr actor_move_sprite
@move_dir:    jsr actor_center      ; center reached?
              bne @move_soft  ; no, move soft

              jsr pacman_collect

              ldx #ACTOR_PACMAN
              ldy actor_ypos,x
              beq @move_soft    ; we're at right tunnel end, skip dir check
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

game_demo_init:
              lda #STATE_INTRO|STATE_DEMO
              sta game_state+GameState::state

              jsr game_init
              jsr game_level_init
              draw_text text_game_over, Color_Red
              jsr game_ready

              lda #0
              sta demo_script_ix
              sta demo_step_cnt
              ora #$80
              sta input_direction
              lda #1
              sta game_state+GameState::lives ; "game over" after 1 live

              lda #FN_STATE_DEMO_PLAYING
              jmp system_set_state_fn_delay

game_demo_playing:
              lda pacman_delay
              bne @play
              ldx #ACTOR_PACMAN
              jsr actor_center
              bne @play
              dec demo_step_cnt
              bpl @play
              ldy demo_script_ix
:             lda @demo_input_dirs,y
              bmi @exit
              cmp #$7f
              bne :+
              .byte $db
              iny
              bne :-
:             lsr
              lsr
              sta demo_step_cnt
              lda @demo_input_dirs,y
              and #ACT_DIR
              sta input_direction
              inc demo_script_ix
@play:        jmp game_playing
@exit:        rts

@demo_input_dirs: ; bit 7 (end), bit 6-2 steps, bit 1-0 direction
.byte 3<<2|ACT_LEFT
.byte 3<<2|ACT_DOWN,  3<<2|ACT_RIGHT, 3<<2|ACT_DOWN,  14<<2|ACT_RIGHT
.byte 2<<2|ACT_UP,    1<<2|ACT_LEFT,  2<<2|ACT_UP,    2<<2|ACT_RIGHT
.byte 1<<2|ACT_UP,    2<<2|ACT_UP,    6<<2|ACT_LEFT,  7<<2|ACT_UP,    7<<2|ACT_LEFT
.byte 2<<2|ACT_DOWN,  2<<2|ACT_LEFT,  13<<2|ACT_UP,   5<<2|ACT_LEFT
.byte 3<<2|ACT_DOWN,  9<<2|ACT_RIGHT, 3<<2|ACT_UP,    4<<2|ACT_LEFT
.byte 5<<2|ACT_DOWN,  4<<2|ACT_LEFT,  3<<2|ACT_UP,    6<<2|ACT_RIGHT
.byte 2<<2|ACT_DOWN,  2<<2|ACT_RIGHT, 2<<2|ACT_DOWN,  2<<2|ACT_LEFT
.byte 2<<2|ACT_DOWN,  19<<2|ACT_LEFT, 11<<2|ACT_DOWN, 4<<2|ACT_RIGHT
.byte 2<<2|ACT_DOWN,  24<<2|ACT_LEFT, 2<<2|ACT_UP,    1<<2|ACT_RIGHT
.byte 2<<2|ACT_UP,    1<<2|ACT_LEFT,  2<<2|ACT_UP,    11<<2|ACT_RIGHT
.byte 2<<2|ACT_DOWN,  2<<2|ACT_RIGHT, 2<<2|ACT_UP,    10<<2|ACT_RIGHT
.byte 2<<2|ACT_DOWN,  1<<2|ACT_LEFT,  2<<2|ACT_DOWN,  2<<2|ACT_RIGHT
.byte 2<<2|ACT_DOWN,  24<<2|ACT_LEFT, 2<<2|ACT_UP,    1<<2|ACT_RIGHT
.byte 2<<2|ACT_UP,    1<<2|ACT_LEFT,  4<<2|ACT_UP,    1<<2|ACT_RIGHT
.byte $ff



delete_message_1:
              ldx #12
              bne :+
delete_message_2:
              ldx #18
:             ldy #18
              lda #10
              jmp sys_blank_xy

game_ghost_catched:
              ldx #ACTOR_CLYDE  ; animate ghosts already catched
:             lda actor_mode,x
              cmp #ACTOR_MODE_CATCHED
              bne @next
              jsr ghost_move
@next:        dex
              bpl :-

              jsr animate_screen
              jsr animate_bonus

              lda game_state+GameState::state_frames
              cmp #1
              bne @wait

              ;jsr short_dist_reverse ; TODO possibility to reverse direction immediately when return

              lda game_state+GameState::ghsts_to_catch  ; 3,2,1,0
              asl
              adc #Pts_Index_Ghost_Catched    ; select score
              jsr add_score

              dec game_state+GameState::ghsts_to_catch
              bpl @exit

              dec game_state+GameState::ghsts_all_cnt
              bpl @exit
              lda #Pts_Index_6000   ; all ghost catched gives 12.000pts (2x6.000pts)
              jsr add_score
              lda #Pts_Index_6000
              jmp add_score

@wait:        and #$3f  ; TODO as long as necessary until catched ghost sound has finished
              bne @exit

              ;jsr sound_ghost_catched ; TODO

              ldx #ACTOR_PACMAN
              lda actor_move,x
              and #ACT_NEXT_DIR ; make pacman visible again, set shape
              sta actor_shape,x

              ldx game_state+GameState::ghst_catched
              lda #GHOST_STATE_RETURN
              sta ghost_state,x
              lda #ACTOR_MODE_CATCHED
              sta actor_mode,x

              lda #FN_STATE_PLAYING    ; continue playing
              bit game_state+GameState::state
              bvc :+
              lda #FN_STATE_DEMO_PLAYING
:             jmp system_set_state_fn
@exit:        rts


game_playing: jsr update_mode

              jsr pacman_move

;              ldx #ACTOR_INKY
 ;             ldx #ACTOR_BLINKY
  ;            ldx #ACTOR_PINKY
              ldx #ACTOR_CLYDE
              jsr actors_move

              jsr animate_screen
              jsr animate_bonus

              lda game_state+GameState::dot_timer
              bne @dot_timer

              jsr base_next_ghost
              bcc @timer
              lda #GHOST_STATE_LEAVE
              sta ghost_state,x
@timer:       jsr reset_dot_timer
@dot_timer:   dec game_state+GameState::dot_timer

              bit game_state+GameState::state ; in intro demo?
              bpl :+
              rts
:
              lda game_state+GameState::dots   ; all dots collected ?
              bne @exit

              lda #Pts_Index_Level_Cleared
              jsr add_score

              ldx #ACTOR_PACMAN
              lda #Shape_Ix_Pacman  ; pacman shape complete "ball"
              sta actor_shape,x

              lda #FN_STATE_LEVEL_CLEARED
              jmp system_set_state_fn_delay
@exit:        rts


; A - mode/offset to speed table - one of ACTOR_MODE_NORM or ACTOR_MODE_FRIGHT
actors_mode:  ldy #ACTOR_PACMAN
@next:        ldx actor_mode,y  ; TODO clobbers X
              cpx #ACTOR_MODE_CATCHED
              beq @skip
              sta actor_mode,y
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
              ldy game_state+GameState::level
              cpy #17 ; no frightened in level 17, but reverse ghost direction
              beq actors_reverse
              cpy #19 ; no frightened in level 19+, but reverse ghost direction
              bcs actors_reverse

              dey ; adjust level for lookup
              lda frghtd_timer_l,y
              sta game_state+GameState::frghtd_timer+0
              lda frghtd_timer_h,y
              sta game_state+GameState::frghtd_timer+1

              lda #ACTOR_MODE_FRIGHT
              jsr actors_mode

              lda #3
              sta game_state+GameState::ghsts_to_catch

actors_reverse: ; set next direction to reverse of current direction
              ldy #ACTOR_CLYDE
:             lda ghost_state,y
              cmp #GHOST_STATE_TARGET ; skip if in state back to base
              bne @next
              lda actor_move,y        ; change direction
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

; A ghost's objective in chase mode is to find and capture Pac-Man by hunting him down through the maze.
; Each ghost exhibits unique behavior when chasing Pac-Man, giving them their different personalities:
; Blinky (red) is very aggressive and hard to shake once he gets behind you,
; Pinky (pink) tends to get in front of you and cut you off,
; Inky (light blue) is the least predictable of the bunch, and
; Clyde (orange) seems to do his own thing and stay out of the way.
; In scatter mode, the ghosts give up the chase for a few seconds and head for their respective home corners. It is a welcome but brief rest-soon enough, they will revert to chase mode and be after Pac-Man again.
; Ghosts enter frightened mode whenever Pac-Man eats one of the four energizers located in the far corners of the maze. During the early levels, the ghosts will all turn dark blue (meaning they
; are vulnerable) and aimlessly wander the maze for a few seconds. They will flash moments before returning to their previous mode of behavior.

; Ghosts are forced to reverse direction by the system anytime the mode changes from: chase-to-scatter, chase-to-frightened, scatter-to-chase, scatter-to-frightened.
; Ghosts do not reverse direction when changing back from frightened to chase or scatter modes.
; Ghosts enter frightened mode, the scatter/chase timer is paused...  time runs out, they return to the mode they were in
update_mode:  lda game_state+GameState::frghtd_timer+0
              bne :+
              lda game_state+GameState::frghtd_timer+1
              beq @scatter_chase
              dec game_state+GameState::frghtd_timer+1
:             dec game_state+GameState::frghtd_timer+0
              rts

@scatter_chase:
              lda #ACTOR_MODE_NORM
              jsr actors_mode

              lda game_state+GameState::sctchs_timer+0
              bne :+
              dec game_state+GameState::sctchs_timer+1
              bmi @switch_mode
:             dec game_state+GameState::sctchs_timer+0
              and #$03 ; update targets every 4 frames
              beq @select_mode
              rts

@switch_mode: lda game_state+GameState::sctchs_ix
              bmi @exit ; underrun, no more mode switches

              cmp #7    ; skip reverse at initial mode switch
              beq :+
              jsr actors_reverse
:             lda game_state+GameState::sctchs_ix

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

              dec game_state+GameState::sctchs_ix
              asl game_state+GameState::sctchs_mode

@select_mode: lda game_state+GameState::sctchs_mode
              bpl @chase

@scatter:     ldy #ACTOR_CLYDE ; set scatter targets to all ghosts
:             lda ghost_scatter_x,y
              sta ghost_tgt_x,y
              lda ghost_scatter_y,y
              sta ghost_tgt_y,y
              dey
              bpl :-
              lda ghost_speed_offs+ACTOR_BLINKY ; blinky in elroy mode 1/2 target is pacman still
              beq @exit
              ldx #ACTOR_PACMAN
              jmp @tgt_blinky
@exit:        rts

@chase:       ldx #ACTOR_PACMAN
              lda actor_move,x
              bmi :+            ; pacman is moving, use current direction
              and #ACT_NEXT_DIR ; if stopped, next position
              lsr
              lsr
:             and #ACT_DIR
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
@clyde_sct:   lda ghost_scatter_x,y
              sta ghost_tgt_x,y
              lda ghost_scatter_y,y
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
; out: A - elroy dots
elroy_dots_for_level:
              lda #20
              ldy game_state+GameState::level
              cpy #1
              beq @exit
              cpy #2+1
              bcc @lvl_2
              cpy #5+1
              bcc @lvl_3_5
              cpy #8+1
              bcc @lvl_6_8
              cpy #11+1
              bcc @lvl_9_11
              cpy #14+1
              bcc @lvl_12_14
              cpy #18+1
              bcc @lvl_15_18
              clc
              adc #20
@lvl_15_18:   adc #20
@lvl_12_14:   adc #20
@lvl_9_11:    adc #10
@lvl_6_8:     adc #10
@lvl_3_5:     adc #10
@lvl_2:       adc #10
@exit:        rts


; in: A - level 1..$ff
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
              iny ; level 13+ bonus 8
:             rts

animate_bonus:
              lda game_state+GameState::bonus_cnt
              beq @bonus_trig
              lda game_state+GameState::frames
              and #$03  ; every 4 frames ~67ms
              bne @exit
              dec game_state+GameState::bonus_cnt
              bne @exit

              lda game_maze+($12+$20*$0d) ; below ghost base
              cmp #Char_Bonus ; bonus fruit timeout?
              bne @bonus_pts_clr
              lda #Char_Blank ; reset to blank char in maze
              sta game_maze+($12+$20*$0d) ; below ghost base
              lda #Bonus_Clear
              jmp gfx_bonus
@bonus_pts_clr:
              ldx #$12
              ldy #$0f
              lda #4
              jmp sys_blank_xy
@bonus_trig:
              lda game_state+GameState::dots
              bit game_state+GameState::bonus
              bmi @exit
              bvs @bonus_2
              cmp #MAX_DOTS-Bonus_Dots_Trig1
              bne @bonus_2
              lda #Bonus1_Triggered
              bne @bonus_1
@bonus_2:     cmp #MAX_DOTS-Bonus_Dots_Trig2
              bne @exit
              lda #Bonus2_Triggered
@bonus_1:     ora game_state+GameState::bonus
              sta game_state+GameState::bonus
              and #$1f  ; mask bonus number 1-8
              jsr gfx_bonus
              lda #Bonus_Time
              sta game_state+GameState::bonus_cnt
              lda #Char_Bonus ; set char in maze which will be handled in collect
              sta game_maze+($12+$20*$0d) ; below ghost base
@exit:        rts


draw_frame:   jsr gfx_sprites_off
              ldx #3                ; init maze
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
              bpl :-

              jsr gfx_display_maze

              jmp draw_scores


game_level_init:
              lda game_state+GameState::level
              jsr bonus_for_level
              sty game_state+GameState::bonus

              jsr elroy_dots_for_level
              sta game_state+GameState::dot_cnt_elroy

              lda #MAX_DOTS
              sta game_state+GameState::dots

              lda #3
              sta game_state+GameState::ghsts_all_cnt

              lda #0
              sta game_state+GameState::bonus_cnt
              sta game_state+GameState::dot_cnt_state ; disable global dot counter on new level init
              lda #$79
              sta game_state+GameState::rng+0
              eor #$ff
              sta game_state+GameState::rng+1

              lda #0
              ldx #ACTOR_CLYDE
:             sta ghost_dot_cnt,x
              dex
              bpl :-

              ldy game_state+GameState::level
              ; inky limit 30/0 (level1/2..), clyde limit 60/50/0 (level1/2/3..)
              ldx #ACTOR_CLYDE
              cpy #1
              bne :+
              lda #60 ; level 1 - dot limit clyde 60
              sta ghost_dot_cnt,x
              ldx #ACTOR_INKY
              lda #30 ;           dot limit inky 30
              sta ghost_dot_cnt,x
:             cpy #2
              bne :+
              lda #50 ;           dot limit clyde 50
              sta ghost_dot_cnt,x

:             jsr init_speed_cnt

              bit game_state+GameState::state ; in intro?
              bpl :+
              rts
:
              jsr draw_frame

              draw_text ready, Color_Yellow

              lda game_state+GameState::level
              jsr gfx_bonus_stack

              lda #FN_STATE_READY
              jmp system_set_state_fn

.export init_speed_cnt
init_speed_cnt:
              lda #5  ; table index 5 (last column in speed table)
              cpy #1      ; level 1 ?
              beq @lvl_1
              cpy #5      ; level 2-4 ?
              bcc @lvl_2_4
              cpy #21     ; level 21+ ?
              bcc @lvl_5_20
              clc
              adc #6      ; +18 - level 21+
@lvl_5_20:    adc #6      ; +12
@lvl_2_4:     adc #6      ; +6
@lvl_1:       tay
              ldx #5
:             lda speed_table,y
              sta game_state+GameState::speed_cnt_init,x
              dey
              dex
              bpl :-
              rts

game_level_cleared:
              jsr actors_invisible

              lda game_state+GameState::state_frames
              cmp #$88
              beq @next_state
              lsr
              lsr
              lsr
              and #$03
              tay
              jmp gfx_rotate_pal
@next_state:  lda #FN_STATE_INTERMISSION
              jmp system_set_state_fn


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
              bne @next
              beq @digits
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

animate_up:   bit game_state+GameState::state ; demo?
              bvs @exit

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
@exit:        rts


game_init:    jsr sound_play_game_start

              jsr system_dip_switches_lives
              sty game_state+GameState::lives

              jsr system_dip_switches_bonus_life
              sta game_state+GameState::bonus_life+0
              stx game_state+GameState::bonus_life+1  ; save trigger points for bonus pacman

              lda #1 ; start with level 1
              sta game_state+GameState::level

              ldy #2
              lda #0
:             sta game_state+GameState::score,y
              dey
              bpl :-

              jsr draw_frame

              bit game_state+GameState::state ; in intro?
              bpl :+
              rts
:
              ldy game_state+GameState::lives
              jsr gfx_lives

              lda game_state+GameState::level
              jsr gfx_bonus_stack

              draw_text text_player_one, Color_Cyan
              lda game_state+GameState::players
              beq :+
              draw_text text_player_two
:             draw_text ready, Color_Yellow

              lda #FN_STATE_LEVEL_INIT
              jmp system_set_state_fn_delay

.data

maze:
  .include "pacman.maze.inc"

actor_init_x: ; sprite pos x of blinky,pinky,inky,clyde,pacman
    .byte 100,$7c,$7c,$7c,196
actor_init_y:
    .byte 112,112,128,96,112
actor_init_d:
    .byte ACT_MOVE|ACT_LEFT<<2|ACT_LEFT
    .byte ACT_MOVE|ACT_DOWN<<2|ACT_DOWN
    .byte ACT_MOVE|ACT_UP<<2|ACT_UP
    .byte ACT_MOVE|ACT_UP<<2|ACT_UP
    .byte ACT_MOVE|ACT_LEFT<<2|ACT_LEFT
ghost_init_color:
    .byte Color_Blinky,Color_Pinky,Color_Inky,Color_Clyde
ghost_init_state:
    .byte GHOST_STATE_TARGET  ; blinky
    .byte GHOST_STATE_BASE
    .byte GHOST_STATE_BASE
    .byte GHOST_STATE_BASE

; ghost scatter targets
ghost_scatter_x:
    .byte $00,$00,$1f,$1f
ghost_scatter_y:
    .byte $03,$18,$00,$1b

; refer to speed table - https://pacman.holenet.info/#LvlSpecs
; bit 7 (1) denotes delay
speed_table:  ; pacman , ghost , fright pacman , fright ghost , elroy 1 , elroy 2
              .byte 0,  $80 | 20, 7,  $80 | 2, 0, 15  ; level 1
              .byte 7,        15, 5,  $80 | 3, 7, 5   ; level 2-4
              .byte 4,         5, 4,  $80 | 4, 4, 3   ; level 5..20
              .byte 7,         5, 7,  $80 | 2, 4, 3   ; level 21+    ; !!!NOTE - no frightened mode in level 21+, but we use speeds of level 21 within intro, therefore frght. pacman/ghost speeds are set

; mode timings in secs
;
; MODE      LEVEL 1    LEVELS 2-4    LEVELS 5+
; Scatter       7          7          5
; Chase        20         20         20
; Scatter       7          7          5
; Chase        20         20         20
; Scatter       5          5          5
; Chase        20       1033       1037
; Scatter       5       1/60       1/60
; Chase indefinite indefinite indefinite
mode_timer_l:
    .byte       0,        0   ,0
    .byte <(60*05),       0   ,0
    .byte <(60*20),<(60*1033) ,<(60*1037)
    .byte <(60*05),<(60*05)   ,<(60*05)
    .byte <(60*20),<(60*20)   ,<(60*20)
    .byte <(60*07),<(60*07)   ,<(60*05)
    .byte <(60*20),<(60*20)   ,<(60*20)
    .byte <(60*07),<(60*07)   ,<(60*05)
mode_timer_h:
    .byte        0,       0,      0
    .byte >(60*05),       0,      0
    .byte >(60*20),>(60*1033) ,>(60*1037)
    .byte >(60*05),>(60*05)   ,>(60*05)
    .byte >(60*20),>(60*20)   ,>(60*20)
    .byte >(60*07),>(60*07)   ,>(60*05)
    .byte >(60*20),>(60*20)   ,>(60*20)
    .byte >(60*07),>(60*07)   ,>(60*05)

; frightened timer
frghtd_timer_l:
    .byte <(60*06)  ; level 1
    .byte <(60*05)  ;
    .byte <(60*04)  ;
    .byte <(60*03)  ;
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


; squares for $00..$24
squares_l:
    .byte $00,$01,$04,$09,$10,$19,$24,$31,$40,$51,$64,$79,$90,$A9,$C4,$E1,$00,$21,$44,$69,$90,$B9,$E4,$11,$40,$71,$A4,$D9,$10,$49,$84,$C1,$00,$41,$84,$c9,$10
squares_h:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04,$04,$04,$05

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
Pts_Index_6000=(*-scoring_table) ;TODO
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
.export actor_sp_x,actor_sp_y,actor_shape,actor_move
.export ghost_tgt_x,ghost_tgt_y
.export actor_mode,ghost_color,ghost_state,ghost_speed_offs

.bss
  demo_script_ix:   .res 1
  demo_step_cnt:    .res 1  ; step counter current direction
  actor_sp_x:       .res 5  ; sprite x
  actor_sp_y:       .res 5  ; sprite y
  actor_xpos:       .res 5  ; tile x pos - 0..31
  actor_ypos:       .res 5  ; tile y pos - 0..28
  actor_shape:      .res 5  ; shape
  actor_move:       .res 5  ; bit 7 move, bit 3-2 next direction (ACT_NEXT_DIR mask), bit 1-0 current direction (ACT_DIR mask)
  actor_mode:       .res 5  ; 0 - normal, 2 - frightened, 1 - catched - see ACTOR_MODE_xxx
  actor_speed_cnt:  .res 5  ; bit 7 delay, bit 6..0 frame counter

  ghost_color:      .res 4  ; main color
  ghost_shape_mask: .res 4  ; shape mask - for normal, frightened or catched ghost
  ghost_shape_offs: .res 4  ; offset for normal frightened or catched ghost
  ghost_state:      .res 4  ; ghosts movement strategy - in base, leaving base, return to base, move arround (scatter/chase)
  ghost_speed_offs: .res 4  ; either 3 or 4, offset to speed_table
  ghost_dot_cnt:    .res 4  ; ghost dot counter, only one active at once and only if ghost within the house, pinky, inky, clyde => max. 240 + 4 super food
  ghost_tgt_x:      .res 4  ; current target tile x
  ghost_tgt_y:      .res 4  ; current target tile y

  pacman_delay:     .res 1  ; amount of frames to delay for various actions - 1 frame eating a dot, 10 frames eating an energizer
  pacman_turn:      .res 1  ; bit 7 turn, bit 1-0 turn direction

  target_dist:      .res 2  ; 16bit (x1-x2)² + (y1-y2)² to calc shortest distance
  target_dir:       .res 1

  game_maze         = ((__BSS_RUN__+__BSS_SIZE__) & $ff00)+$100  ; put at the end of BSS which is BSS_RUN + BSS_SIZE and align with page start
