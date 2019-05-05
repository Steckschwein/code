      .setcpu "65c02"

      .include "system.inc"
      .include "zeropage.inc"
      
      .include "common.inc"
      .include "keyboard.inc"
      .include "via.inc"
      .include "vdp.inc"
    
      .importzp tmp1,tmp2
      .importzp ptr1,ptr2,ptr3
      
ptr1l=ptr1+0
ptr1h=ptr1+1
ptr2l=ptr2+0
ptr2h=ptr2+1
DPL=ptr3+0
DPH=ptr3+1

BIOS_COLOR=Gray<<4|Black  ; gray text, black backdrop/border

; start memcheck here
start_check = $0300
ram_end 			= $0288
ram_end_l   		= ram_end
ram_end_h   		= ram_end+1

; Address pointers for serial upload
startaddr	= ptr1
endaddr		= ptr2
length		= $e0

errno	 	= $0300
nvram		= $1000

;dirptr 		= $f4 ; 2 byte
paramvec	= $f8

; pointer for string output functions
sd_blktarget 		= $0400
steckos_start		= $1000

param_sig		= $00 ; 1  byte  - parameter array signature byte. must be $42
param_version	= $01 ; 1  byte  - version number. initially zero
param_filename	= $02 ; 11 bytes - file to boot. example "LOADER  BIN"
param_uart_div	= $0d ; 2  bytes  - baudrate divisor value
param_lsr       = $0f ; 1  byte  - uart lcr value , default %00000011 (8N1)
param_checksum  = $5f ; checksum


.macro	println text
			jsr primm
			.byte text, KEY_LF, 0
.endmacro

.macro	print text
			jsr primm
			.asciiz text
.endmacro
