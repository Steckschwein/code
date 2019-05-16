      .pc02
      
      .include "common.inc"
      .include "kernel_jumptable.inc"
      .include "joystick.inc"
      .include "keyboard.inc"
      .include "vdp.inc"
      
      .include "pacman.inc"

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

;sprite_pattern=ADDRESS_GFX3_SPRITE_PATTERN
;sprite_color  =ADDRESS_GFX3_SPRITE_COLOR
VRAM_SPRITE_PATTERN =ADDRESS_GFX3_SPRITE_PATTERN
VRAM_SPRITE_COLOR   =ADDRESS_GFX3_SPRITE_COLOR
VRAM_SPRITE_ATTR    =ADDRESS_GFX3_SPRITE
VRAM_PATTERN        =ADDRESS_GFX3_PATTERN
VRAM_SCREEN         =ADDRESS_GFX3_SCREEN
