		.setcpu "65c02"

		.include "system.inc"
		.include "zeropage.inc"

		.include "common.inc"
		.include "keyboard.inc"
		.include "via.inc"
		.include "vdp.inc"

BIOS_COLOR=Gray<<4|Black  ; gray text, black backdrop/border

; start memcheck here
start_check		 	= $0300
ram_end 			= $0288
ram_end_l			= ram_end
ram_end_h			= ram_end+1

nvram		= $1000

steckos_start		= $1000

.macro	print_dot
			lda #'.'
			jsr vdp_chrout
.endmacro

.macro	println text
			jsr primm
			.byte text, KEY_LF, 0
.endmacro

.macro	print text
			jsr primm
			.asciiz text
.endmacro
