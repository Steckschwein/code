;
.include "pacman.inc"
.include "vdp.inc"

.include "assertions.inc"

.setcpu "6502"

VDP_Color_Bg          = $00
VDP_Color_Red         = $01
VDP_Color_Pink        = $03
VDP_Color_Cyan        = $05
VDP_Color_Light_Blue  = $06
VDP_Color_Orange      = $07
VDP_Color_Yellow      = $09
VDP_Color_Dark_Pink   = $0b ; 1011
VDP_Color_Dark_Cyan   = $0d
VDP_Color_Blue        = $0e ; 1110
VDP_Color_Gray        = $0f

VDP_Color_Food        = VDP_Color_Dark_Pink
VDP_Color_Border      = VDP_Color_Blue
VDP_Color_Blinky      = VDP_Color_Red
VDP_Color_Inky        = VDP_Color_Cyan
VDP_Color_Clyde       = VDP_Color_Orange
VDP_Color_Pinky       = VDP_Color_Pink

VRAM_SPRITE_PATTERN   = ADDRESS_GFX4_SPRITE_PATTERN
VRAM_SPRITE_COLOR     = ADDRESS_GFX4_SPRITE_COLOR
VRAM_SPRITE_ATTR      = ADDRESS_GFX4_SPRITE
VRAM_SCREEN           = ADDRESS_GFX4_SCREEN
