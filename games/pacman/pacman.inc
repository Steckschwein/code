.include "zeropage.inc"

.autoimport

KEY_EXIT = 27
MAX_DOTS=240+4  ; food + superfood

MAX_LIVES=5

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

Char_Not_Up         = $06   ; blank not up

;                   = $c6   ;1100 0110
Char_Blank          = $c7   ;1100 0111

Char_Dot_Not_Up     = $4c   ; with Char_Maze_Mask
Char_Dot            = $cc   ;1100 1100
                            ;1100 1101
Char_Bonus          = $cd
Char_Energizer      = $ce   ;1100 1110 $ce
Char_Base           = $cf   ;1100 1111
Char_Quote          = $22

Char_Maze_Mask      = $80   ;

.define Char_Pts $2a,$2b,$2c

FRAMES_DELAY = 0 ;$0f

TXT_WAIT  =$01
TXT_WAIT2 =$02
TXT_GHOST =$03
TXT_CRS_XY=$04
TXT_COLOR =$05

DIP_COINAGE_0       =1<<0
DIP_COINAGE_1       =1<<1
DIP_LIVES_0         =1<<2   ; lives 00 - 1, 01 - 2, 10 - 3, 11 - 5
DIP_LIVES_1         =1<<3
DIP_BONUS_LIFE_0    =1<<4   ; bonus life at 00 - 10.000, 01 - 15.000, 10 - 20.000, 11 - None
DIP_BONUS_LIFE_1    =1<<5
DIP_DIFFICULTY      =1<<6
DIP_GHOSTNAMES      =1<<7

STATE_INIT          = $0
STATE_LEVEL_INIT    = $1
STATE_READY         = $2
STATE_DELAY         = $3
STATE_READY_WAIT    = $4
STATE_PLAYING       = $5
STATE_PACMAN_DYING  = $7
STATE_LEVEL_CLEARED = $8
STATE_GAME_OVER     = $9
STATE_INTRO         = 1<<5

STATE_PAUSE         = 1<<6
STATE_EXIT          = 1<<7

GHOST_STATE_BASE    = 0
GHOST_STATE_RETURN  = 1
GHOST_STATE_LEAVE   = 2
GHOST_STATE_CATCH   = 3

Delay_Dot           = 1 ; 1 penalty frame
Delay_Energizer     = 3

Bonus_Dots_Trig1    = 70
Bonus_Dots_Trig2    = 170
Bonus_Time          = 150 ; count down every 4 frames gives ~9-10s
Bonus_Pts_Time      = 24  ; ~2s

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
Color_Red         = $1  ; "shadow", "blinky" red
Color_Brown       = $2  ; orange top, cherry stem
Color_Pink        = $3  ; "speedy", "pinky" pink

Color_Cyan        = $5  ; "bashful", "inky" cyan
Color_Light_Blue  = $6  ; "ligth blue"
Color_Orange      = $7  ; "pokey", "Clyde" "orange"

Color_Yellow      = $9  ; "yellow", "pacman"
;Color_Indigo      = $b  ; Maze walls, flashing ghosts, ghost pupils
Color_Dark_Pink   = $b  ; "food", "super food"
Color_Green       = $c  ; Melon, strawberry top, orange leaf
Color_Dark_Cyan   = $d  ; dark cyan - Melon wrinkles and stem
Color_Blue        = $e  ; blue => ghosts "scared", ghost pupil
Color_Gray        = $f  ; gray => ghosts "scared", ghost eyes, text

Color_Blinky  = Color_Red
Color_Inky    = Color_Cyan
Color_Clyde   = Color_Orange
Color_Pinky   = Color_Pink
Color_Pacman  = Color_Yellow
Color_Food    = Color_Dark_Pink
Color_Border  = Color_Blue
Color_Text    = Color_Gray


; A ghost's objective in chase mode is to find and capture Pac-Man by hunting him down through the maze.
; Each ghost exhibits unique behavior when chasing Pac-Man, giving them their different personalities:
; Blinky (red) is very aggressive and hard to shake once he gets behind you,
; Pinky (pink) tends to get in front of you and cut you off,
; Inky (light blue) is the least predictable of the bunch, and
; Clyde (orange) seems to do his own thing and stay out of the way.
GHOST_CHASE       = 0
; In scatter mode, the ghosts give up the chase for a few seconds and head for their respective home corners. It is a welcome but brief rest-soon enough, they will revert to chase mode and be after Pac-Man again.
GHOST_SCATTER     = 1<<6
; Ghosts enter frightened mode whenever Pac-Man eats one of the four energizers located in the far corners of the maze. During the early levels, the ghosts will all turn dark blue (meaning they
; are vulnerable) and aimlessly wander the maze for a few seconds. They will flash moments before returning to their previous mode of behavior.
GHOST_FRIGHTENED  = 1<<7;

ACT_MOVE          = 1<<7
ACT_RIGHT         = 0 ;00
ACT_LEFT          = 1 ;01
ACT_UP            = 2 ;10
ACT_DOWN          = 3 ;11
ACT_MOVE_UP_OR_DOWN     = %00000010
ACT_MOVE_INVERSE        = %00000001   ;eor bit 1-0
ACT_MOVE_INVERSE_NEXT   = %00000100

ACT_TURN          = 1<<7
ACT_NEXT_DIR      = 1<<3|1<<2
ACT_DIR           = 1<<1|1<<0

.macro setIRQ irq, irq_save
      php
      sei
      copyPtr IRQ_VEC, irq_save
      setPtr irq, IRQ_VEC
      plp
.endmacro

.macro restoreIRQ irq_save
      php
      sei
      copyPtr irq_save, IRQ_VEC
      plp
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
     lda #color
     jsr gfx_bordercolor
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
  dip_switches  .byte

  fn            .addr
  state         .byte
  nextstate     .byte   ; next state from delay
  frames        .byte

  credit        .byte

  players       .byte   ; active players
  active_up     .byte   ; current player

  lives         .byte   ; lives current player
  score         .res 3  ; score current player

  level         .byte   ; the current level
  dots          .byte   ; remaining dots count down - MAX_DOTS at start
  dot_cnt       .byte   ; in level dot counter - set/reset if a life is lost
  bonus         .byte   ; bonus of current level
  bonus_cnt     .byte   ; frame counter
  bonus_life    .word   ; trigger for next bonus life (BCD) - TT T digit

  lives_1up     .byte
  lives_2up     .byte
  score_1up     .res 3
  score_2up     .res 3
  highscore     .res 3

  ; game related
  ;ghost_mode  .byte   ; chase, scatter, frightened
.endstruct

  ; dots    0 after pacman dead, pinky 7, inky 17, clyde 32
  ; dot timer 4s, 3s (level5)
.struct actor ;
    xpos          .byte   ; character x pos - 0..31
    ypos          .byte   ; character y pos - 0..28
    sp_x          .byte   ; sprite x
    sp_y          .byte   ; sprite y
    shape         .byte   ; shape
    move          .byte   ; bit 7 move, bit 3-2 next direction (ACT_NEXT_DIR mask), bit 1-0 current direction (ACT_DIR mask)
.endstruct

.struct ghost
    actor         .tag actor
    ; ghost related, maybe remove from actor struct
    mask_shape    .byte   ; shape mask - for normal, frightened or catched ghost

    strategy      .byte   ; ghost movement strategy - in base, leaving base, return to base, scatter, chase, frightend
    ;mask_visited  .byte   ; 10001111 blinky, 01001111 pinky, 00101111 inky, 00011111 clyde
    dot_cnt       .byte   ; 0 at start, one counter active at once and only if ghost within the house, pinky, inky, clyde => max. 240 + 4 super food
    dot_limit     .byte   ; ghost leave house, deactivate counter, pinky limit 0, inky limit 30/0 (level1/2..), clyde limit 60/50/0 (level1/2/3..)

    tgt_x         .byte   ; target x
    tgt_y         .byte   ; target y

    sct_x         .byte   ; scatter target x
    sct_y         .byte   ; scatter target y
.endstruct

.struct pacman
    actor         .tag actor
    turn          .byte   ; bit 7 turn, bit 1-0 turn direction
    delay         .byte   ; amount of frames to delay for various actions - 1 frame eating a dot, 10 frames eating an energizer
.endstruct

SHAPE_IX_DYING      = $34
SHAPE_IX_INVISIBLE  = $3f

; table offsets
ACTOR_BLINKY  = 0
ACTOR_PINKY   = ACTOR_BLINKY  + .sizeof(ghost)
ACTOR_INKY    = ACTOR_PINKY   + .sizeof(ghost)
ACTOR_CLYDE   = ACTOR_INKY    + .sizeof(ghost)
ACTOR_PACMAN  = ACTOR_CLYDE   + .sizeof(ghost)
