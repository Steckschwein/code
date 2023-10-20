.setcpu "65c02"

.include "system.inc"
.include "zeropage.inc"
.include "common.inc"
.include "keyboard.inc"
.include "via.inc"
.include "vdp.inc"
.include "debug.inc"
.include "sdcard.inc"
.include "fat32.inc"
.include "fcntl.inc"
.include "nvram.inc"
.include "spi.inc"
.include "ym3812.inc"

BIOS_COLOR=Gray<<4|Black  ; gray text, black backdrop/border

; start memcheck here
start_check		= $0300
nvram				  = $1000

.macro	print_dot
	lda #'.'
	jsr char_out
.endmacro

.macro	println text
	jsr primm
	.byte text, CODE_LF, 0
.endmacro

.macro	print text
	jsr primm
	.asciiz text
.endmacro
