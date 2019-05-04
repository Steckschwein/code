      .setcpu "65c02"

      .importzp ptr1,ptr2,ptr3
      .importzp tmp1,tmp2,tmp3,tmp4,tmp5
        
      .import __BSS_RUN__

.if .defined (__C64__)
      .include "c64.inc"
.else
      .include "zeropage.inc"
      .include "common.inc"
      .include "kernel_jumptable.inc"
      .include "joystick.inc"
      .include "keyboard.inc"
      .include "vdp.inc"
      SpriteOff=SPRITE_OFF+$08 ; +8, 212 line mode

.endif

.define DEBUG 1
.define BOOT 0
.define INTRO 0

.macro bgcolor color
  .if DEBUG
    .import gfx_bgcolor
    lda #color
    jsr gfx_bgcolor
  .endif
.endmacro

.macro draw_text _p
      SetVector _p, ptr1
      jsr out_text
.endmacro

.macro push_axy
      pha
      tya
      pha
      txa
      pha
.endmacro
.macro pop_axy
      pla
      tax
      pla
      tay
      pla
.endmacro

.struct GameState
  state       .byte
  credit      .byte
  frames      .byte
  score       .res 4
  highscore   .res 4
.endstruct

  ; dots    0 after pacman dead, pinky 7, inky 17, clyde 32
  ; dot timer 4s, 3s (level5)
.struct actor ; !!! do not change order of attributes !!!
    xpos      .byte   ; character x pos - 0..31
    xpos_dir  .byte   ; character x pos direction
    ypos      .byte   ; character y pos - 0..25
    ypos_dir  .byte   ; character y pos direction
    
    move      .byte   ; bit 7 move, bit 3-2 next direction, bit 1-0 current direction
    turn      .byte   ; bit 7 turn, bit 1-0 turn direction
    sprite    .byte   ; sprite number, offset to sprite tab

    dots      .byte   ; 0 at start, one counter active at once and only if ghost within the house, pinky, inky, clyde   => max. 227 + 4 super food
;    dot_limit .byte   ; ghost leave house, deactivate counter, pinky limit 0, inky limit 30,0 (level1/2..), clyde limit 60/50/0 (level1/2/3..)
.endstruct

p_video=ptr1
video_tmp=tmp1
p_sound=ptr2
sound_tmp=tmp2

p_game=ptr4
p_maze=ptr3

game_tmp=tmp3
game_tmp2=tmp4
game_tmp3=tmp4

Color_Bg          = $00
Color_Red         = $01
Color_Pink        = $03
Color_Cyan        = $05
Color_Light_Blue  = $06
Color_Orange      = $07
Color_Yellow      = $09
Color_Dark_Cyan   = $0d
Color_Blue        = $0e
Color_Gray        = $0f

Color_Blinky  = Color_Red
Color_Inky    = Color_Cyan
Color_Clyde   = Color_Orange
Color_Pinky   = Color_Pink
Color_Food    = $0b
Color_Border  = Color_Blue


Char_Food           = $cc   ;1100 1100
                            ;1100 1101
Char_Superfood      = $ce   ;1100 1110 $cd/$ce

Char_Blank          = $c7   ;1100 0111
Char_Bg             = $cf   ;1100 1111

; scoring
Points_Food         = $10 ;BCD values
Points_Superfood    = $50 ;

.define Char_Pts $2a,$2b,$2c

FRAMES_DELAY = $0f
WAIT=$01
WAIT2=$02

STATE_INIT          = 0
STATE_READY         = 1
STATE_READY_WAIT    = 2
STATE_PLAYING       = 3
STATE_DIED          = 4
STATE_LEVEL_CLEARED = 5
STATE_GAME_OVER     = 6
STATE_PAUSE         = $08
STATE_EXIT          = $80

SPRITE_NR_PACMAN  = 0*4
SPRITE_NR_GHOST   = 1*4
SPRITE_ADJUST     = $08

;A ghost's objective in chase mode is to find and capture Pac-Man by hunting him down through the maze. Each ghost exhibits unique behavior when chasing Pac-Man, giving them their different personalities: Blinky (red) is very aggressive and hard to shake once he gets behind you, Pinky (pink) tends to get in front of you and cut you off, Inky (light blue) is the least predictable of the bunch, and Clyde (orange) seems to do his own thing and stay out of the way.
GHOST_CHASE       = 0
;In scatter mode, the ghosts give up the chase for a few seconds and head for their respective home corners. It is a welcome but brief rest-soon enough, they will revert to chase mode and be after Pac-Man again.
GHOST_SCATTER     = 1
; Ghosts enter frightened mode whenever Pac-Man eats one of the four energizers located in the far corners of the maze. During the early levels, the ghosts will all turn dark blue (meaning they 
; are vulnerable) and aimlessly wander the maze for a few seconds. They will flash moments before returning to their previous mode of behavior.
GHOST_FRIGHTENED  = 3;

Sprite_Pattern_Pacman = $18*4

ACTOR_BLINKY  = 1*.sizeof(actor)
ACTOR_INKY    = 2*.sizeof(actor)
ACTOR_PINKY   = 3*.sizeof(actor)
ACTOR_CLYDE   = 4*.sizeof(actor)

ACT_MOVE          = 1<<7
ACT_NEXT_DIR      = 1<<3|1<<2
ACT_RIGHT         = 0 ;00 
ACT_LEFT          = 1 ;01 
ACT_UP            = 2 ;10 
ACT_DOWN          = 3 ;11 
ACT_MOVE_UP_OR_DOWN    = $02 ; 1x
ACT_MOVE_INVERSE  = $01 ;eor bit 1-0

ACT_TURN          = 1<<7
ACT_DIR           = 1<<1|1<<0

game_maze=(__BSS_RUN__) & $ff00
actors=game_maze+$0400
sprite_tab_attr=actors+5*.sizeof(actor)
sprite_tab_attr_end=sprite_tab_attr+5*4*2