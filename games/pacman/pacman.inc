      .setcpu "65c02"

      .include "zeropage.inc"
      .include "common.inc"
      .include "keyboard.inc"
      .include "joystick.inc"
      .include "vdp.inc"
      .include "ym3812.inc"
      .include "kernel_jumptable.inc"
      
      .import __RAM_LAST__
      ;i/o
      .import joystick_on
      .import joystick_detect
      .import joystick_read
      ;vdp
      .import vdp_bgcolor
      .import vdp_fill,vdp_fills
      .import vdp_memcpy,vdp_memcpys
      ;sound
      .import opl2_init
      .import opl2_reg_write
      .importzp ptr1,ptr2,ptr3
      .importzp tmp1,tmp2,tmp3,tmp4,tmp5
        
.define DEBUG 1

.macro bgcolor color
  .if DEBUG
    lda #color
    jsr vdp_bgcolor
  .endif
.endmacro


p_video=ptr1
video_tmp=tmp1
p_sound=ptr2
sound_tmp=tmp2

p_game=ptr4
p_maze=ptr3

game_tmp=tmp3
game_tmp2=tmp4
game_tmp3=tmp4

sprite_pattern=ADDRESS_GFX3_SPRITE_PATTERN
sprite_color  =ADDRESS_GFX3_SPRITE_COLOR
sprite_attr   =ADDRESS_GFX3_SPRITE

    
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
STATE_READY_WAIT    = 1
STATE_PLAYING       = 2
STATE_DIED          = 3
STATE_LEVEL_CLEARED = 4
STATE_GAME_OVER     = 5
STATE_EXIT          = $80

SPRITE_NR_PACMAN    = 0*4
SPRITE_ADJUST     = $08

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

.macro draw_text _p
      SetVector _p, ptr1
      jsr gfx_text
.endmacro

game_maze=(__RAM_LAST__+$100) & $ff00
actors=game_maze+$0400
sprite_tab_attr=actors+5*.sizeof(actor)
sprite_tab_attr_end=sprite_tab_attr+5*4*2