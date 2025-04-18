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

.include "pacman.inc"
.include "vdp.inc"
.include "assertions.inc"

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
