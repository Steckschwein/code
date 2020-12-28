		.include "bios.inc"
		.include "sdcard.inc"
		.include "fat32.inc"
		.include "fcntl.inc"
		.include "nvram.inc"
		.include "spi.inc"
		.include "system.inc"

		.import uart_init, upload
		.import init_via1
		.import hexout, primm
		.import vdp_init, _vdp_chrout, vdp_detect
		.import sdcard_init
		.import sdcard_detect
		.import fat_open
		.import fat_mount, fat_open, fat_read, fat_close
		.import read_nvram
		.import sd_read_block, sd_write_block
		.import spi_select_device
		.import spi_deselect
		.import spi_rw_byte
		.import spi_r_byte

		.export vdp_chrout
		.export krn_chrout=vdp_chrout
		.export read_block=sd_read_block
		.export char_out=_vdp_chrout

		.exportzp startaddr, endaddr

.zeropage
	ptr1: .res 2
	startaddr: .res 2
	endaddr: .res 2

.code

; bios does not support fat write, so we export a dummy function for write which is not used anyway since we call with O_RDONLY
			.export __fat_write_dir_entry=fat_write_dir_entry
fat_write_dir_entry:
			rts

.macro set_ctrlport
			jsr _set_ctrlport
.endmacro

_set_ctrlport:
			pha
			lda ctrl_port
			lsr
			lda ctrl_port
			and #$fe
			rol
			sta ctrl_port
			pla
			rts

_keyboard_write:
	sys_delay_us 75
	jsr spi_rw_byte
	cmp #KBD_RET_ACK
	rts

;	requires nvram init beforehand
keyboard_init:
	jsr primm
	.byte "Keyboard init ", 0

	sys_delay_ms 750 ; wait until keyboard reset sequence has finished

	lda #spi_device_keyboard
	jsr spi_select_device
	bne _fail

	lda #KBD_CMD_TYPEMATIC
	jsr _keyboard_write
	bne _fail

	lda nvram+nvram::keyboard_tm ; typematic settings
	jsr _keyboard_write
	bne _fail
_ok:
	jsr primm
	.byte "OK", CODE_LF, 0
	jmp spi_deselect
_fail:
	jsr primm
	.byte "FAIL", CODE_LF, 0
	jmp spi_deselect

do_reset:
			; disable interrupt
			sei
			; clear decimal flag
			cld

			; init stack pointer
			ldx #$ff
			txs

			lda ctrl_port
			ora #%11111000
			sta ctrl_port

			; Check zeropage and Memory
check_zp:
			; Start at $ff
			ldy #$ff
			; Start with pattern $03 : $ff
@l2:		ldx #num_patterns
@l1:		lda pattern,x
			sta $00,y
			cmp $00,y
			bne zp_broken

			dex
			bne @l1

			dey
			bne @l2

check_stack:
			;check stack
			ldy #$ff
@l2:		ldx #num_patterns
@l1:		lda pattern,x
			sta $0100,y
			cmp $0100,y
			bne stack_broken

			dex
			bne @l1

			dey
			bne @l2

check_memory:
			lda #>start_check
			sta ptr1+1
			ldy #<start_check
			stz ptr1

@l2:		ldx #num_patterns  ; 2 cycles
@l1:		lda pattern,x      ; 4 cycles
	  		sta (ptr1),y   ; 6 cycles
			cmp (ptr1),y   ; 5 cycles
			bne @l3				  ; 2 cycles, 3 if taken

			dex  				  ; 2 cycles
			bne @l1			  ; 2 cycles, 3 if taken

			iny  				  ; 2 cycles
			bne @l2				  ; 2 cycles, 3 if taken

			; Stop at $e000 to prevent overwriting BIOS Code when ROMOFF
			ldx ptr1+1		  ; 3 cycles
			inx				  ; 2 cycles
			stx ptr1+1		  ; 3 cycles
			cpx #$e0			  ; 2 cycles

			bne @l2 			  ; 2 cycles, 3 if taken
@l3:  		sty ptr1		  ; 3 cycles

	  					  ; 42 cycles

	  		; save end address
	  		; lda ptr1l
	  		; sta ram_end_l
	  		; lda ptr1h
	  		; sta ram_end_h

			lda #$e0
			cmp ptr1+1
			bne mem_broken

			lda ptr1
			bne mem_broken

			bra mem_ok

mem_broken:
			lda #$80
			bra stop

zp_broken:
			lda #$40
			bra stop

stack_broken:
			lda #$20
stop:
			sta ctrl_port
@loop:	bra @loop

mem_ok:
			set_ctrlport

			jsr vdp_init

			set_ctrlport

			jsr primm
			.byte "steckOS BIOS   "
			.include "version.inc"
			.byte $0a,0

			print "Memcheck $"
			lda ptr1+1
			jsr hexout
			lda ptr1
			jsr hexout
			println ""

			jsr vdp_detect

			set_ctrlport
			jsr init_via1

         lda #<nvram
         ldy #>nvram
			jsr read_nvram
         set_ctrlport

			jsr uart_init
         set_ctrlport

			jsr keyboard_init

			jsr sdcard_detect
         beq @sdcard_init
			println "No SD card"
			cli

			jmp do_upload
@sdcard_init:
         jsr sdcard_init
         beq boot_from_card
			println "SD card init failed"
			jmp do_upload

boot_from_card:
			print "Boot from SD card."
         jsr fat_mount
			beq @findfile
			pha
			print " mount error "
			pla
			jsr hexout
			println ""
			bra do_upload

@findfile:
			print_dot
			lda #(<nvram)+nvram::filename
			ldx #>nvram
			ldy #O_RDONLY
         jsr fat_open
			beq @loadfile

			ldy #0
@loop:	lda nvram+nvram::filename,y
			beq @loop_end
			jsr vdp_chrout
			iny
			bne @loop
@loop_end:
			println " not found."
			jmp do_upload

@loadfile:
	print_dot
	SetVector steckos_start, startaddr
	SetVector steckos_start, read_blkptr
	jsr fat_read
	jsr fat_close
	bne @load_error
	println "OK"
	bra startup

@load_error:
	jsr hexout
	println " read error"
do_upload:
	jsr upload
startup:
	; re-init stack pointer
	ldx #$ff
	txs
	; jump to new code
	jmp (startaddr)

bios_irq:
	rti

num_patterns = $02
pattern:
	.byte $aa,$55,$00

.segment "VECTORS"
vdp_chrout:
	jmp _vdp_chrout
;----------------------------------------------------------------------------------------------
; Interrupt vectors
;----------------------------------------------------------------------------------------------
; $FFFA/$FFFB NMI Vector
.word mem_ok
; $FFFC/$FFFD reset vector
;*= $fffc
.word do_reset
; $FFFE/$FFFF IRQ vector
;*= $fffe
.word bios_irq
