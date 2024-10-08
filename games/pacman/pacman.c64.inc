.p02
.include "c64.inc"
.include "cbm_kernal.inc"
.include "pacman.inc"
.autoimport

BANK                = $4000
BANK_GHOSTBYTE      = BANK+$3fff

VRAM_SCREEN         = $0400
VRAM_PATTERN        = $3800
VRAM_SPRITE_PATTERN = $1000
VRAM_COLOR          = $d800
VRAM_SPRITE_POINTER = VRAM_SCREEN+$3f8

COLOR_BLACK             = $00
COLOR_WHITE             = $01
COLOR_RED               = $02
COLOR_CYAN              = $03
COLOR_VIOLET            = $04
COLOR_PURPLE            = COLOR_VIOLET
COLOR_GREEN             = $05
COLOR_BLUE              = $06
COLOR_YELLOW            = $07
COLOR_ORANGE            = $08
COLOR_BROWN             = $09
COLOR_LIGHTRED          = $0A
COLOR_GRAY1             = $0B
COLOR_GRAY2             = $0C
COLOR_LIGHTGREEN        = $0D
COLOR_LIGHTBLUE         = $0E
COLOR_GRAY3             = $0F

HLine_Border=250  ; bottom border raster line
HLine_Border_Before=HLine_Border-2

HLine_Last=32 ; $ff

.assert __BSS_RUN__ < BANK+VRAM_SPRITE_PATTERN, error, "bss overflow!"

;just to fulfill the linker contract of the ld65 target -t c64
.segment "EXEHDR"
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
