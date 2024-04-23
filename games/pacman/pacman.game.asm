.export game
.export draw_highscore

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
    jsr game_set_state
@waitkey:
    lda game_state+GameState::state
    cmp #STATE_INTRO
    beq @exit
    jsr io_getkey
    bcc @waitkey
    sta keyboard_input
    cmp #'d'
    bne :+
    lda #STATE_DYING
    bne @set_state
:   cmp #'g'
    bne :+
    lda #1  ; 1 left
    sta game_state+GameState::lives_1up
    sta game_state+GameState::lives_2up
    lda #STATE_DYING
    bne @set_state
:   cmp #'r'
    bne :+
    lda #STATE_READY_PLAYER
    bne @set_state
:   cmp #'i'
    beq @loop
    cmp #'p'
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
    bpl game_isr_exit

    border_color Color_Yellow
    jsr gfx_update

    border_color Color_Gray

    jsr game_init
    jsr game_ready
    jsr game_ready_player
    jsr game_ready_wait
    jsr game_playing
    jsr game_pacman_dying
    jsr game_level_cleared
    ;TODO jsr game_next_level
    jsr game_game_over

    inc game_state+GameState::frames
.ifdef __DEBUG
    border_color Color_Cyan
    ;jsr debug
.endif
game_isr_exit:
    border_color Color_Bg
    pop_axy
    rti

game_ready:
              lda game_state+GameState::state
              cmp #STATE_READY
              bne @exit
              jsr sound_play
              lda game_state+GameState::frames
              and #$7f
              bne @exit
              lda #STATE_READY_PLAYER
              jmp game_set_state
@exit:        rts

game_ready_player:
              lda game_state+GameState::state
              cmp #STATE_READY_PLAYER
              bne @exit
              jsr sound_play
              jsr game_init_actors
              draw_text _ready, Color_Yellow
              ldy #Color_Food
              jsr draw_superfood
              lda #12
              jsr delete_message
              lda #STATE_READY_WAIT
              jmp game_set_state
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
              cmp #STATE_DYING
              bne @exit
              jsr animate_screen
              lda game_state+GameState::frames  ; TODO delay before dead
              lsr
              lsr
              lsr
              cmp #$18
              bcc @pacman_dying

              lda #STATE_READY_PLAYER
              dec game_state+GameState::lives_1up
              bne @set_state
              ldy #Color_Food
              jsr draw_superfood
              draw_text _text_game_over, Color_Red
              lda #STATE_GAME_OVER
@set_state:   jmp game_set_state

@pacman_dying:cmp #$0c
              bcs @exit
              ora #$20        ; shape offset
              ldx #ACTOR_PACMAN
              sta actors+actor::shape,x

              lda #SHAPE_IX_INVISIBLE
              ldx #ACTOR_BLINKY
              sta actors+actor::shape,x
              ldx #ACTOR_INKY
              sta actors+actor::shape,x
              ldx #ACTOR_PINKY
              sta actors+actor::shape,x
              ldx #ACTOR_CLYDE
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
              jmp game_set_state
@exit:        rts


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
          ;    jsr ghost_move
              ldx #ACTOR_PINKY
          ;    jsr ghost_move
              ldx #ACTOR_CLYDE
          ;    jsr ghost_move

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
@pacman_dead: lda #STATE_DYING
              jmp game_set_state
@pacman_hit:
              lda actors+actor::xpos,x
              cmp actors+actor::xpos,y
              bne :+
              lda actors+actor::ypos,x
              cmp actors+actor::ypos,y
@exit:        rts

ghost_move:
    jsr actor_update_charpos
    jmp actor_move_dir

    ; .A new direction
pacman_cornering:
    pha
    lda actors+actor::move,x
    and #$01  ;bit 0 set, either +x or +y, down or left
    beq @l1
    lda #$07   ;
@l1:
    eor #$07
    sta game_tmp2 ;
    pla
l_test:
    and #ACT_MOVE_UP_OR_DOWN    ; new direction is a turn
    bne l_up_or_down          ; so we have to test with the current direction (orthogonal)

l_left_or_right:
    lda actors+actor::sp_x,x
    jmp l_compare

l_up_or_down:
    lda actors+actor::sp_y,x

l_compare:
    eor game_tmp2
    and #$07
    cmp #$04   ; 0100 - center pos, <0100 pre-turn, >0100 post-turn
    rts

;     A - bit 0-1 the direction
actor_center:
    pha
    lda #0
    sta game_tmp2
    pla
    eor #ACT_MOVE_UP_OR_DOWN
    jmp l_test

actor_move:
    lda actors+actor::turn,x
    bpl actor_move_dir      ; turning?
    jsr actor_center
    bne @actor_turn_soft      ;
    lda actors+actor::turn,x  ;
    and #<~ACT_TURN
    sta actors+actor::turn,x
@actor_turn_soft:
    lda actors+actor::turn,x
    jsr actor_move_sprite

actor_move_dir:
    lda actors+actor::move,x
    bpl :+
    jsr actor_strategy
:    jmp pacman_collect

pacman_move:
    jsr actor_center      ; center reached?
    bne actor_move_soft    ; no, move soft

    lda actors+actor::move,x
    and #ACT_DIR
    jsr actor_can_move_to_direction
    bcc actor_move_soft  ; C=0 - can move to

    lda actors+actor::move,x  ;otherwise stop move
    and #<~ACT_MOVE
    sta actors+actor::move,x
    and #ACT_NEXT_DIR      ;set shape of next direction
    sta actors+actor::shape,x
    rts

actor_move_soft:
    jsr pacman_shape_move
    lda actors+actor::move,x
actor_move_sprite:
    bpl @exit
    and #ACT_DIR
    asl
    tay
    pha
    lda _vectors+0,y
;    clc
    adc actors+actor::sp_x,x
    sta actors+actor::sp_x,x
    pla
    tay
    lda _vectors+1,y
    sta game_tmp
@y_add:  ; skip the sprite off position
    clc
    adc actors+actor::sp_y,x
    cmp #Maze_Tunnel
    bne @y_sta
    lda game_tmp
    eor #$10
    jmp @y_add
@y_sta:
    sta actors+actor::sp_y,x
@exit: rts

pacman_shape_move:
    lda game_state+GameState::frames
    lsr
    and #$03
    jmp actor_update_shape

actor_shape_move:
    lda game_state+GameState::frames
    lsr
    lsr
    lsr
    and #$01
    ora #$10    ;sprite shape table offset ghosts
actor_update_shape:
    sta game_tmp
    lda actors+actor::move,x
    and #ACT_DIR
    asl
    asl
    adc game_tmp
    sta actors+actor::shape,x
    rts

pacman_collect:
              lda actors+actor::xpos,x
              ldy actors+actor::ypos,x
              jsr lda_maze_ptr_ay
              cmp #Char_Superfood
              bne :+
              lda #Points_Superfood
              bne @erase_and_score
:             cmp #Char_Food
              bne @exit
              lda #Points_Food
@erase_and_score:
              pha
              dec actors+actor::dots,x
              lda actors+actor::xpos,x
              sta sys_crs_x
              lda actors+actor::ypos,x
              sta sys_crs_y
              lda #Char_Blank
              ldy #0
              sta (p_maze),y
              jsr gfx_charout
              pla
              sta points+3  ; high to low
              jsr add_scores
              jmp draw_scores
@exit:        rts



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

              ldx #ACTOR_PACMAN
              lda actors+actor::dots,x   ; all dots collected ?
              bne @exit

          ;    lda #
              ;sta sprite_tab_attr+SPRITE_NR_PACMAN+SpriteTab::shape
              ; sta actors+actor::shape,x
              ; TODO sprite off screen gfx_xxx
              ; lda #Maze_Tunnel
              ; sta sprite_tab_attr+SPRITE_NR_GHOST+SpriteTab::ypos
              ; jsr gfx_sprites_off
              lda #STATE_LEVEL_CLEARED
              jmp game_set_state
@exit: rts

game_set_state:
    sta game_state+GameState::state
    lda #1
    sta game_state+GameState::frames
    ;inc game_state+GameState::frames ; otherwise ready frames are skipped immediuately
    rts

game_level_cleared:
    lda game_state+GameState::state
    cmp #STATE_LEVEL_CLEARED
    bne @exit

    lda game_state+GameState::frames
    cmp #$88
    bne @rotate
    lda #STATE_INIT
    jsr game_set_state
@rotate:
    lsr
    lsr
    lsr
    and #$03
    tay
    jsr gfx_rotate_pal
@exit: rts

add_scores:
              jsr @select_player_score
              sed
              clc
              ldy #3
:             lda game_state+GameState::score_1up,x
              adc points,y
              sta game_state+GameState::score_1up,y
              dex
              dey
              bpl :-
              cld

              ldy #0
              inx ; x+1 from dex above
@cmp:         lda game_state+GameState::highscore,y
              cmp game_state+GameState::score_1up,x
              bcc @copy ; highscore < score ?
              bne @exit
              inx
              iny
              cpy #4
              bne @cmp
@exit:         rts

@copy:        jsr @select_player_score
              ldy #3
:             lda game_state+GameState::score_1up,x
              sta game_state+GameState::highscore,y
              dex
              dey
              bpl :-
              rts
@select_player_score:
              lda game_state+GameState::active_up
              tax
              inx
              inx
              inx
              rts


draw_scores:  ldx game_state+GameState::active_up ; TODO

              ldx #0
              ldy #21
              jsr _draw_score
              ldx #0
              ldy #8
draw_highscore:
              setPtr (game_state+GameState::highscore), p_game
_draw_score:
              stx sys_crs_x
              sty sys_crs_y
              lda #Color_Text
              sta text_color
              ldy #0
@skip_zeros:
              lda (p_game),y
              beq @skip ;00 ?
              and #$f0  ;0? ?
              bne @digits
              dec sys_crs_y ;output the 0-9 only
              lda (p_game),y
              jsr out_digit
              jmp @digits_inc
@skip:
              dec sys_crs_y ;skip digits
              dec sys_crs_y
              iny
              cpy #04
              bne @skip_zeros
              rts
@digits:
              lda (p_game),y
              jsr out_digits
@digits_inc:
              iny
              cpy #04
              bne @digits
              rts


animate_screen:
              jsr animate_up
animate_superfood:
              ldy #Color_Food
              lda game_state+GameState::frames
              and #$08
              bne draw_superfood
              tay
draw_superfood:
              sty text_color
              ldx #3
@l0:          lda superfood_x,x
              sta sys_crs_x
              ldy superfood_y,x
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
              beq @init
              rts
@init:        jsr gfx_sprites_off

              lda #0
              ldy #3
              sty game_state+GameState::lives_1up
              sty game_state+GameState::lives_2up

:             sta points+0,y
              sta game_state+GameState::score_1up+0,y
              sta game_state+GameState::score_2up+0,y
              dey
              bpl :-

              jsr sound_init_game_start

              ldx #3
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

              jsr gfx_display_maze

              lda #MAX_DOTS
              ldx #ACTOR_PACMAN
              sta actors+actor::dots,x

              draw_text _ready, Color_Yellow

              draw_text _ready_player_one, Color_Cyan
              lda game_state+GameState::players
              beq :+
              draw_text _ready_player_two
:
              lda #STATE_READY
              jmp game_set_state

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
    jsr animate_ghosts

    ldx #ACTOR_PACMAN
    jsr game_init_actor
    lda #2
    sta actors+actor::shape,x

    jmp gfx_sprites_on

game_init_actor:
    lda actor_init_x,y
    sta actors+actor::sp_x,x
    lda actor_init_y,y
    sta actors+actor::sp_y,x
    lda actor_init_d,y
    sta actors+actor::move,x
    iny
    rts


actor_init_x: ; sprite pos x of b,p,i,c,p
    .byte 100,124,124,124,196
actor_init_y:
    .byte 112,128,112,96,112
actor_init_d:
    .byte ACT_MOVE|ACT_LEFT, ACT_MOVE|ACT_UP, ACT_MOVE|ACT_DOWN, ACT_MOVE|ACT_UP, ACT_MOVE|ACT_LEFT<<2 | ACT_LEFT

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


ai_ghost:
    tya
    tax
    jsr actor_center
    bne @soft    ; center reached?

    lda actors+actor::move,x
    and #ACT_DIR
    jsr actor_can_move_to_direction
    bcc @soft  ; C=0, can move to

    lda actors+actor::move,x
    eor #ACT_DIR ;? inverse
:      sta game_tmp
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

actor_strategy:
    cpx #ACTOR_PACMAN
    bne @ghost
    jsr pacman_move
    rts
@ghost:
    rts ; TODO FIXME
;    jmp ai_ghost

.data

maze:
  .include "pacman.maze.inc"

superfood_x:
   .byte 4,24,4,24
superfood_y:
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

_ready_player_one:
    .byte 12,18, "PLAYER ONE",0
_ready_player_two:
    .byte 12,11, "TWO",0
_ready:
    .byte 18,16, "READY!"
    .byte 0
_text_game_over:
    .byte 18,18, "GAME  OVER",0

.export game_maze
.export actors

.bss
  save_irq:         .res 2
  points:           .res 4
  input_direction:  .res 1
  keyboard_input:   .res 1
  actors:           .res 5*.sizeof(actor)
  game_maze=((__BSS_RUN__+__BSS_SIZE__) & $ff00)+$100  ; put at the end which is __BSS_SIZE__ and align $100
