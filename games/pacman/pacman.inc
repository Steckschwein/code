      .setcpu "65c02"

      .include "zeropage.inc"
      .include "common.inc"
      .include "keyboard.inc"
      .include "vdp.inc"
      .include "ym3812.inc"
      .include "kernel_jumptable.inc"
      
      .import vdp_bgcolor
      .import vdp_fill,vdp_fills
      .import vdp_memcpy,vdp_memcpys
      .import opl2_init
      .import opl2_reg_write
      .importzp ptr1,ptr2
      .importzp tmp1,tmp2,tmp3
        
.define DEBUG 0

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
p_game1=ptr3
p_game2=ptr4
game_tmp=tmp3

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
Char_Superfood      = $ce   ;1100 1110
Char_Blank          = $c7   ;1100 0111
Char_Bg             = $cf   ;1100 1111

.define Char_Pts $2a,$2b,$2c

FRAMES_DELAY = $0f
WAIT=$01
WAIT2=$02

STATE_INIT          = 0
STATE_READY         = 1
STATE_READY_WAIT    = 1
STATE_PLAYING       = 2
STATE_GAMEOVER      = 3
;STATE_


.struct GameState
  state       .byte
  credit      .byte
  frames      .byte
  score       .res 7
  highscore   .res 7
.endstruct

.struct actor ; corresponds with sprite tab structure - FTW
  ypos  .byte
  xpos  .byte
  state .byte   ; bit 1-0 direction
  res   .byte
.endstruct

.macro draw_text _p
      SetVector _p, ptr1
      jsr gfx_text
.endmacro
