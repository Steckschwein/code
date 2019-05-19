      .pc02
      
      .include "common.inc"
      .include "kernel_jumptable.inc"
      .include "joystick.inc"
      .include "keyboard.inc"
      .include "vdp.inc"
      
      .include "pacman.inc"

VDP_Color_Bg          = $00
VDP_Color_Red         = $01
VDP_Color_Pink        = $03
VDP_Color_Cyan        = $05
VDP_Color_Light_Blue  = $06
VDP_Color_Orange      = $07
VDP_Color_Yellow      = $09
VDP_Color_Dark_Pink   = $0b
VDP_Color_Dark_Cyan   = $0d
VDP_Color_Blue        = $0e
VDP_Color_Gray        = $0f

VDP_Color_Food        = VDP_Color_Dark_Pink
VDP_Color_Border      = VDP_Color_Blue
VDP_Color_Blinky      = VDP_Color_Red
VDP_Color_Inky        = VDP_Color_Cyan
VDP_Color_Clyde       = VDP_Color_Orange
VDP_Color_Pinky       = VDP_Color_Pink

;sprite_pattern=ADDRESS_GFX3_SPRITE_PATTERN
;sprite_color  =ADDRESS_GFX3_SPRITE_COLOR
VRAM_SPRITE_PATTERN =ADDRESS_GFX3_SPRITE_PATTERN
VRAM_SPRITE_COLOR   =ADDRESS_GFX3_SPRITE_COLOR
VRAM_SPRITE_ATTR    =ADDRESS_GFX3_SPRITE
VRAM_PATTERN        =ADDRESS_GFX3_PATTERN
VRAM_COLOR          =ADDRESS_GFX3_COLOR

VRAM_SCREEN         =ADDRESS_GFX3_SCREEN
