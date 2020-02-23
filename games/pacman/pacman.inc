      .include "zeropage.inc"
;      .smart
      .autoimport

        Color_Blinky  = Color_Red
        Color_Inky    = Color_Cyan
        Color_Clyde   = Color_Orange
        Color_Pinky   = Color_Pink
        Color_Food    = Color_Dark_Pink
        Color_Border  = Color_Blue
        Color_Text    = Color_Gray

        KEY_EXIT = 27
        MAX_DOTS=226+4  ; food + superfood

.globalzp p_maze
.globalzp p_game
.globalzp p_tmp
.globalzp p_text
.globalzp p_sound



.code
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

Sprite_Pattern_Pacman = $18*4     ; pacman shape filled circle (game init)

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

.macro setIRQ irq, irq_save
      copyPtr $fffe, irq_save
      setPtr irq, $fffe
.endmacro

.macro restoreIRQ irq_save
      sei
      copyPtr irq_save, $fffe
      cli
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

.macro bgcolor color
  .ifdef __DEBUG
    .import gfx_bordercolor
    lda color
    jsr gfx_bordercolor
  .endif
.endmacro

.macro draw_text _p, color
      .if .paramcount > 1
        lda color
        sta text_color
      .endif
      setPtr _p, p_text
      .import out_text
      jsr out_text
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

.struct SpriteTab
  ypos    .byte
  xpos    .byte
  shape   .byte
  color   .byte
.endstruct

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
;    dot_limit .byte   ; ghost leave house, deactivate counter, pinky limit 0, inky limit 30/0 (level1/2..), clyde limit 60/50/0 (level1/2/3..)
.endstruct

ACTOR_PACMAN  = 0*.sizeof(actor)
ACTOR_BLINKY  = 1*.sizeof(actor)
ACTOR_INKY    = 2*.sizeof(actor)
ACTOR_PINKY   = 3*.sizeof(actor)
ACTOR_CLYDE   = 4*.sizeof(actor)
