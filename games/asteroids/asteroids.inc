.setcpu "65C02"

.autoimport

;.include "zeropage.inc"
.include "joystick.inc"
.include "fat32.inc"
.include "system.inc"
.include "steckos.inc"
.include "vdp.inc"
.include "via.inc"


seed=123
stars_layer_size=40
stars_per_layer=3
stars_nr_layers=4

JOY_PORT=JOY_PORT1		;port 1

MAX_X	= 25*8-16
MAX_Y	= $bf

SPEED_ASTEROID=2
SPEED_ASTEROID_MAX=4
SPEED_SHIP=1

COLOR_STARS=Dark_Yellow
COLOR_ROCK=Gray
COLOR_ROCK2=Dark_Yellow
COLOR_SHOT=Light_Green
COLOR_SHIP=Light_Blue
COLOR_SHIP2=Light_Red

COLOR_BONUS_B=Dark_Yellow
;invincibility
COLOR_BONUS_I=Light_Blue
;shot or fire bonus
COLOR_BONUS_F=Medium_Red
;speed bonus
COLOR_BONUS_S=Magenta

SHIP_X	= MAX_X>>1
SHIP_Y	= SPRITE_INVISIBLE-16

SHIP_FIRE=1<<0

ROCK_Y  = 15

SPNR_SHIP=0
SPNR_SHOT=2
