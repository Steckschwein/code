.include "zeropage.inc"

.autoimport

KEY_EXIT = 27
MAX_DOTS=240+4  ; food + superfood

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

Char_Food           = $cc   ;1100 1100
                            ;1100 1101
Char_Superfood      = $ce   ;1100 1110 $cd/$ce
;                   = $c6   ;1100 0110
Char_Blank          = $c7   ;1100 0111
Char_Bg             = $cf   ;1100 1111
Char_Quote          = $22

; scoring
Points_Food         = $10 ;BCD values
Points_Superfood    = $50 ;

.define Char_Pts $2a,$2b,$2c

FRAMES_DELAY = $0f
TXT_WAIT  =$01
TXT_WAIT2 =$02
TXT_GHOST =$03
TXT_CRS_XY=$04
TXT_COLOR =$05

STATE_INIT          = $10
STATE_READY         = $11
STATE_READY_PLAYER  = $12
STATE_READY_WAIT    = $13
STATE_PLAYING       = $14
STATE_DYING         = $15
STATE_LEVEL_CLEARED = $16
STATE_GAME_OVER     = $17
STATE_INTRO         = $18
STATE_PAUSE         = 1<<6
STATE_EXIT          = 1<<7


SPRITE_NR_PACMAN  = 8*4
SPRITE_NR_GHOST   = 0*4
SPRITE_ADJUST     = $08

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
GHOST_SCATTER     = 1
; Ghosts enter frightened mode whenever Pac-Man eats one of the four energizers located in the far corners of the maze. During the early levels, the ghosts will all turn dark blue (meaning they
; are vulnerable) and aimlessly wander the maze for a few seconds. They will flash moments before returning to their previous mode of behavior.
GHOST_FRIGHTENED  = 3;

ACT_MOVE          = 1<<7
ACT_RIGHT         = 0 ;00
ACT_LEFT          = 1 ;01
ACT_UP            = 2 ;10
ACT_DOWN          = 3 ;11
ACT_MOVE_UP_OR_DOWN     = $02 ; 1X
ACT_MOVE_INVERSE        = $01 ;eor bit 1-0

ACT_TURN          = 1<<7
ACT_NEXT_DIR      = 1<<3|1<<2
ACT_DIR           = 1<<1|1<<0

;CORNERING

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
    lda #color
    jsr gfx_bgcolor
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
  state       .byte
  frames      .byte

  credit      .byte
  players     .byte   ; active players
  active_up   .byte   ; current player
  lives_1up   .byte
  lives_2up   .byte
  score_1up   .dword
  score_2up   .dword
  highscore   .dword
.endstruct

  ; dots    0 after pacman dead, pinky 7, inky 17, clyde 32
  ; dot timer 4s, 3s (level5)
.struct actor ;
    xpos        .byte    ; character x pos - 0..31
    ypos        .byte    ; character y pos - 0..28
    sp_x        .byte    ; sprite x
    sp_y        .byte    ; sprite y
    shape       .byte    ; shape
    move        .byte    ; bit 7 move, bit 3-2 next direction (ACT_NEXT_DIR mask), bit 1-0 current direction (ACT_DIR mask)
    turn        .byte    ; bit 7 turn, bit 1-0 turn direction

    dots        .byte   ; 0 at start, one counter active at once and only if ghost within the house, pinky, inky, clyde   => max. 227 + 4 super food
;    dot_limit .byte   ; ghost leave house, deactivate counter, pinky limit 0, inky limit 30/0 (level1/2..), clyde limit 60/50/0 (level1/2/3..)
.endstruct

SHAPE_IX_INVISIBLE = 43

Maze_Tunnel=$e0

; table offsets
ACTOR_BLINKY  = 0*.sizeof(actor)
ACTOR_INKY    = 1*.sizeof(actor)
ACTOR_PINKY   = 2*.sizeof(actor)
ACTOR_CLYDE   = 3*.sizeof(actor)
ACTOR_PACMAN  = 4*.sizeof(actor)
