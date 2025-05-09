; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
.ifndef _PACMAN_INC_
  _PACMAN_INC_ = 1

.include "zeropage.inc"

.autoimport

KEY_EXIT = 27
MAX_DOTS=240+4  ; food + superfood
MAX_LIVES=5

Dot_Cnt_Enabled=1<<7

Elroy_Suspended=1<<7

.globalzp p_maze
.globalzp p_game
.globalzp p_tmp
.globalzp p_text
.globalzp p_sound
.globalzp p_video

.globalzp video_tmp
.globalzp sound_tmp
.globalzp text_color

.globalzp _i
.globalzp _j
.globalzp _k

IRQ_VEC = $fffe

;                   = $c6   ;1100 0110
Char_Blank          = $c7   ;1100 0111
Char_Dot            = $cc   ;1100 1100
                            ;1100 1101
Char_Bonus          = $cd
Char_Energizer      = $ce   ;1100 1110 $ce
Char_Base           = $cf   ;1100 1111
Char_Quote          = $22

Char_Maze_Blank     = $f4

.define Char_Pts $2a,$2b,$2c

.ifdef __DEVMODE
  FRAMES_DELAY = $0
.else
  FRAMES_DELAY = $0f
.endif

INTRO_TUNNEL_X=19

BORDER_RIGHT_Y=28

TXT_WAIT  =$01
TXT_WAIT2 =$02
TXT_GHOST =$03
TXT_CRS_XY=$04
TXT_COLOR =$05

DIP_COINAGE_0       =1<<0   ; 00 - free play
DIP_COINAGE_1       =1<<1   ; 01 - 1 coin, 2 credits | 02 - 1 coin, 1 credit | 11 - 2 coins, 1 credit
DIP_LIVES_0         =1<<2   ; lives 00 - 1, 01 - 2, 10 - 3, 11 - 5
DIP_LIVES_1         =1<<3
DIP_BONUS_LIFE_0    =1<<4   ; bonus life at 00 - 10.000, 01 - 15.000, 10 - 20.000, 11 - None
DIP_BONUS_LIFE_1    =1<<5
DIP_DIFFICULTY      =1<<6
DIP_GHOSTNAMES      =1<<7

FN_STATE_NOOP           = $00
FN_STATE_INIT           = $02
FN_STATE_LEVEL_INIT     = $04
FN_STATE_READY          = $06
FN_STATE_DELAY          = $08
FN_STATE_READY_WAIT     = $0a
FN_STATE_PLAYING        = $0c
FN_STATE_PACMAN_DYING   = $0e
FN_STATE_LEVEL_CLEARED  = $10
FN_STATE_GAME_OVER      = $12
FN_STATE_GHOST_CATCHED  = $14
FN_STATE_INTERLUDE_INIT = $16
FN_STATE_INTERLUDE      = $18
FN_STATE_DEMO_INIT      = $1a
FN_STATE_DEMO_PLAYING   = $1c
FN_STATE_INTRO          = $1e
FN_STATE_INTRO_GHOSTS   = $20
FN_STATE_INTRO_GHOST_CATCHED  = $22
FN_STATE_INTRO_SELECT_PLAYER  = $24


STATE_PAUSE         = 1<<5
STATE_DEMO          = 1<<6  ; demo flag
STATE_INTRO         = 1<<7

GHOST_STATE_BASE    = 0
GHOST_STATE_RETURN  = 1
GHOST_STATE_LEAVE   = 2
GHOST_STATE_TARGET  = 3
GHOST_STATE_ENTER   = 4
GHOST_STATE_STOP    = 5

ACTOR_MODE_NORM     = 0
ACTOR_MODE_CATCHED  = 1 ; ghosts only
ACTOR_MODE_FRIGHT   = 2
ACTOR_MODE_BONUS    = 3 ; ghosts only
ACTOR_MODE_BIGMAN   = 4 ; ghosts only

Shape_Mask_Norm       = $7f
Shape_Mask_Small      = $73 ; only 4 patterns (bit 1,0)

Shape_Offset_Norm     = $10
Shape_Offset_Catched  = $20
Shape_Offset_Fright   = $30
Shape_Offset_Bonus    = $40
Shape_Offset_Bigman   = $44

Shape_Ix_Pacman       = 2   ; "filled circle"
Shape_Ix_Dying        = $34
Shape_Ix_Invisible    = $3f ; empty sprite

; Every time Pac-Man eats a regular dot, he stops moving for one frame (1/60th of a second), slowing his progress by roughly ten percent—just enough for a following ghost to overtake him.
; Eating an energizer dot causes Pac-Man to stop moving for three frames.
Delay_Dot           = 1 ; 1 penalty frame
Delay_Energizer     = 3

Bonus_Dots_Trig1    = 70
Bonus_Dots_Trig2    = 170
Bonus_Time          = 150 ; count down every 4 frames gives ~9-10s
Bonus_Pts_Time      = 24  ; ~2s display bonus points

Bonus_Clear       = 0 ;
Bonus_Cherry      = 1 ; level 1       100pts
Bonus_Strawberry  = 2 ; level 2       300pts
Bonus_Orange      = 3 ; level 3,4     500pts
Bonus_Apple       = 4 ; level 5,6     700pts
Bonus_Grapes      = 5 ; level 7,8   1.000pts
Bonus_Galaxian    = 6 ; level 9,10  2.000pts
Bonus_Bell        = 7 ; level 11,12 3.000pts
Bonus_Key         = 8 ; level 13-   5.000pts
Bonus1_Triggered  = 1<<6  ; mark whether bonus was triggered
Bonus2_Triggered  = 1<<7

Color_Bg          = $0  ; black
Color_Red         = $1  ; "shadow" / "Blinky"
Color_Brown       = $2  ; orange top, cherry stem
Color_Pink        = $3  ; "speedy" / Pinky

Color_Cyan        = $5  ; "bashful" / Inky, color of bonus pts catched ghost
Color_Light_Blue  = $6  ;
Color_Orange      = $7  ; "pokey" / Clyde

Color_Yellow      = $9  ; "pacman"

Color_Dark_Pink   = $b  ; "food", "super food" (1011)
Color_Green       = $c  ; Melon, strawberry top, orange leaf (1100)
Color_Dark_Cyan   = $d  ; dark cyan - Melon wrinkles and stem
Color_Blue        = $e  ; blue => ghosts "frightened", ghost pupil, maze wall (1110)
Color_Gray        = $f  ; gray => ghosts "frightened", ghost eyes, text (1111)

Color_Blinky  = Color_Red
Color_Inky    = Color_Cyan
Color_Clyde   = Color_Orange
Color_Pinky   = Color_Pink
Color_Pacman  = Color_Yellow
Color_Food    = Color_Dark_Pink
Color_Maze    = Color_Blue
Color_Text    = Color_Gray

ACT_MOVE          = 1<<7
ACT_RIGHT         = 0 ;00
ACT_DOWN          = 1 ;01
ACT_LEFT          = 2 ;10
ACT_UP            = 3 ;11
ACT_MOVE_UP_OR_DOWN     = %00000001
ACT_MOVE_REVERSE        = %00000010   ;eor bit 1
ACT_MOVE_REVERSE_NEXT   = %00001000

ACT_TURN          = 1<<7
ACT_NEXT_DIR      = 1<<3|1<<2
ACT_DIR           = 1<<1|1<<0

.macro setIRQ irq_vec
      copyPtr irq_vec, save_irq
      setPtr sys_isr, irq_vec
.endmacro

.macro restoreIRQ irq_vec
      copyPtr save_irq, irq_vec
.endmacro

.macro setPtr addr, ptr
      lda #<addr
      sta ptr
      lda #>addr
      sta ptr+1
.endmacro

.macro copyPtr src, dest
      lda src
      sta dest
      lda src+1
      sta dest+1
.endmacro

.macro border_color color
   .ifdef __DEBUG
    pha
    lda #color
    jsr gfx_bordercolor
    pla
   .endif
.endmacro

.macro bgcolor color
  .ifdef __DEBUG
    pha
    lda #color
    jsr gfx_bgcolor
    pla
  .endif
.endmacro

.macro draw_text _p, color
      setPtr _p, p_text
      .if .paramcount > 1
      lda #color
      jsr out_text_color
      .else
      jsr out_text
      .endif
.endmacro

.macro push_axy
      pha
      txa
      pha
      tya
      pha
.endmacro

.macro pop_axy
      pla
      tay
      pla
      tax
      pla
.endmacro

.struct GameState
  dip_switches      .byte

  state             .byte
  state_frames      .byte   ; frame counter per state, will be reset after each state change
  fn_state          .addr   ; state function address
  fn_state_next     .byte   ; index of next state function from delay

  frames            .byte   ; continuous frame counter
  vblank            .byte   ; v-blank

  credit            .byte

  players           .byte   ; active players
  active_up         .byte   ; current player

  lives             .byte   ; lives current player
  score             .res 3  ; BCD score current player

  level             .byte   ; the current level

  dots              .byte   ; remaining dots count down - MAX_DOTS at start
  dot_cnt           .byte   ; level dot counter - set/reset if a life is lost
  dot_cnt_state     .byte   ; bit 7 dot_cnt enabled/disabled
  dot_timer         .byte   ; nothing eaten timer, 4s or 3s (level 5+) hence either count down to zero from $f0 or $b4 each frame
  dot_cnt_elroy     .byte   ; amount of dots remaining in the maze in order to trigger elroy 1/2 mode

  bonus             .byte   ; bonus of current level
  bonus_cnt         .byte   ; bonus available (frame) counter
  bonus_life        .word   ; trigger for next bonus life (BCD) - TT T digit

  highscore         .res 3

  ; game related
  rng               .word   ; PRNG index

  ;speed control
  speed_cnt_init    .res 6  ; speed counter init values in order pacman normal, ghost normal, pacman frightened, ghost frightened, elroy 1, elroy 2

  frghtd_timer      .word   ; frightened mode timer in secs * frames
  sctchs_mode       .byte   ; scatter or chase mode. alternate 10101010 => shift right, carry denotes mode
  sctchs_ix         .byte   ; scatter/chase timings table index
  sctchs_timer      .word   ; current mode count down secs * frames - e.g. 1s => 60

  ghsts_all_cnt     .byte   ; counter how often ALL ghosts where catched during a frightened phase
  ghsts_to_catch    .byte   ; ghosts to catch during a frightened phase, starts with 3
  ghst_catched      .byte   ; ghost index/offset - e.g. ACTOR_BLINKY, ACTOR_PINKY ...

.ifdef __DEVMODE
  debug             .byte   ; debug flag/toggle bits for demo purpose
.endif

.endstruct

; table offsets
ACTOR_BLINKY  = 0
ACTOR_PINKY   = 1
ACTOR_INKY    = 2
ACTOR_CLYDE   = 3
ACTOR_PACMAN  = 4

; fuses
  .assert ACTOR_MODE_NORM = 0, error, "change const. value ACTOR_MODE_NORM!"
  .assert GHOST_STATE_BASE = 0, error, "change const. value GHOST_STATE_BASE!"

.endif ;  _PACMAN_INC_