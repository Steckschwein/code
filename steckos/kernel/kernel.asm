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
.ifdef DEBUG_KERNEL ; debug switch for this module
	debug_enabled=1
.endif

.include "common.inc"
.include "kernel.inc"
.include "vdp.inc"
.include "via.inc"
.include "ym3812.inc"
.include "keyboard.inc"

.code

.autoimport

.export read_block=sd_read_block
.export write_block=sd_write_block
.export char_out=textui_chrout				 ; account for page crossing

.export crc16_lo=BUFFER_0
.export crc16_hi=BUFFER_1
.export crc16_init=crc16_table_init
.export xmodem_rcvbuffer=BUFFER_2
.export xmodem_startaddress=startaddr

.export debug_chrout=textui_chrout				 ; account for page crossing

nvram = $1000

kern_init:
		; copy trampolin code for ml monitor entry to ram
		ldx #$00
@copy:
		lda trampolin_code,x
		sta trampolin,x
		inx
		cpx #(trampolin_code_end - trampolin_code)
		bne @copy

		SetVector user_isr_default, user_isr
		jsr textui_init0

		jsr init_via1

    jsr init_rtc

		lda #<nvram
		ldy #>nvram
		jsr read_nvram

		jsr uart_init

		stz key
		stz flags

    jsr rtc_irq0

  	cli

.ifndef DISABLE_INTRO
		jsr primm
		.byte $d5,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$b8,$0a
		.byte $b3," steckOS kernel "
		.include "version.inc"
		.byte $20,$b3,$0a
		.byte $d4,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$be,$0a
		.byte $00
.else
        jsr primm
        .byte CODE_LF, "steckOS kernel "
		.include "version.inc"
        .byte CODE_LF, 0
.endif

		SetVector do_upload, retvec ; retvec per default to do_upload. end up in do_upload again, if a program exits safely
		jsr __automount_init
		bne do_upload

		lda #<filename
		ldx #>filename
		jsr execv

load_error:
		jsr hexout
		jsr primm
		.byte " read error", CODE_LF, 0
do_upload:
		jsr xmodem_upload_verbose
		bcs load_error

		jsr primm
		.byte " OK", CODE_LF, 0

		ldx #$ff
		txs

		jmp (startaddr); jump to start addr set by upload

;----------------------------------------------------------------------------------------------
; IO_IRQ Routine. Handle IRQ
;----------------------------------------------------------------------------------------------
do_irq:
; 	PHX							;
; 	PHA							;
; 	TSX							; get stack pointer
; 	LDA	$0103,X			  ; load INT-P Reg off stack
; 	AND	#$10				  ; mask BRK
; 	BNE	@BrkCmd			  ; BRK CMD
; 	PLA							;
; 	PLX							;
; 	;jmp	(INTvector)		 ; let user routine have it
; 	bra @irq
; @BrkCmd:
; 	pla							;
; 	plx							;
; 	jmp	do_nmi

; system interrupt handler
; handle keyboard input and text screen refresh
@irq:
    save

    cld ;clear decimal flag, maybe an app has modified it during execution
    jsr call_user_isr			; user isr first, maybe there are timing critical things

@check_vdp:
    bit a_vreg ; vdp irq ?
    bpl @check_via
    jsr textui_update_screen	; update text ui
    bra @check_spi_keyboard

@check_via:
    bit via1ifr		; Interrupt from VIA?
    bpl @check_opl
    ; via irq handling code
    bra @check_spi_keyboard

@check_opl:
    bit opl_stat  ; IRQ from OPL?
    bpl @check_spi_rtc
    lda #Light_Yellow<<4|Light_Yellow
    jsr vdp_bgcolor
    bra @check_spi_keyboard
    ; opl isr

@check_spi_rtc:
    jsr rtc_irq0_ack
    bcc @check_spi_keyboard
    lda #Cyan<<4|Cyan
    jsr vdp_bgcolor
;  sys_delay_ms 5

@check_spi_keyboard:
    jsr fetchkey        ; fetch key (to satisfy the IRQ of the avr)
    bcc @system
    cmp #KEY_CTRL_C 	  ; was it ctrl c?
    bne @system  ; no

    lda flags           ; it is ctrl c. set bit 7 of flags
    ora #$80
    sta flags

@system:
    dec frame
    lda frame
    and #$0f				  	; every 16 frames we try to update rtc, gives 320ms clock resolution
    bne @exit
    jsr rtc_systime_update	 	; update system time, read date time and store to rtc_systime_t (see rtc.inc)
    jsr __automount

@exit:
    lda #Medium_Green<<4|Black
    jsr vdp_bgcolor

  	restore
	  rti

call_user_isr:
  	jmp (user_isr)
user_isr_default:
	  rts

frame:
	 .res 1

;----------------------------------------------------------------------------------------------
; IO_NMI Routine. Handle NMI
;----------------------------------------------------------------------------------------------
ACC = $45
XREG = $46
YREG = $47
STATUS = $48
SPNT = $49

do_nmi:
	sta ACC
	stx XREG
	sty YREG
	pla
	sta STATUS
	tsx
	stx SPNT

	jmp trampolin


do_reset:
	; disable interrupt
	sei

	; clear decimal flag
	cld

	; init stack pointer
	ldx #$ff
	txs
	jmp kern_init


filename: .asciiz "steckos/shell.prg"

; trampolin code to enter ML monitor on NMI
; this code gets copied to $10 and executed there
trampolin_code:
	sei
	; switch to ROM bank 1
	lda #$02
	sta $0230
	; go!
	brk
	;jmp $f000
trampolin_code_end:

.segment "JUMPTABLE"		; "kernel" jumptable

.export krn_rmdir
krn_rmdir:							jmp fat_rmdir
.export krn_mkdir
krn_mkdir:							jmp fat_mkdir
.export krn_execv
krn_execv:							jmp execv

.export krn_uart_rx_nowait
krn_uart_rx_nowait:				jmp uart_rx_nowait

.export krn_mount
krn_mount: 					 		jmp fat_mount

.export krn_open
krn_open: 					 jmp fat_fopen

.export krn_chdir
krn_chdir: 					 jmp fat_chdir

.export krn_unlink
krn_unlink: 				jmp fat_unlink

.export krn_close
krn_close:						jmp fat_close
.export krn_close_all
krn_close_all:					jmp fat_close_all

.export krn_read
krn_read:						jmp fat_read

.export krn_fread
krn_fread:	 					jmp fat_fread

.export krn_find_first
krn_find_first:				jmp fat_find_first
.export krn_find_next
krn_find_next:					jmp fat_find_next
.export krn_textui_init
krn_textui_init:				jmp	textui_init
.export krn_textui_enable
krn_textui_enable:			jmp	textui_enable
.export krn_textui_disable
krn_textui_disable:			jmp textui_disable			;disable textui

.export krn_display_off
krn_display_off:				jmp vdp_display_off

.export krn_getkey
krn_getkey:						jmp getkey

.export krn_chrout
krn_chrout:						jmp textui_chrout
.export krn_putchar
krn_putchar:					jmp textui_put

.export krn_strout
krn_strout:						jmp strout

.export krn_textui_crsxy
krn_textui_crsxy:			  jmp textui_crsxy

.export krn_textui_update_crs_ptr
krn_textui_update_crs_ptr:  jmp textui_update_crs_ptr

.export krn_textui_clrscr_ptr
krn_textui_clrscr_ptr:		jmp textui_blank

;.export krn_fseek
;krn_fseek:						jmp fat_fseek
.export krn_textui_setmode
krn_textui_setmode:	  jmp textui_setmode

.export krn_textui_crs_onoff
krn_textui_crs_onoff:	jmp textui_cursor_onoff

.export krn_init_sdcard
krn_init_sdcard:		jmp sdcard_init

.export krn_upload
krn_upload:				jmp do_upload

; .export krn_spi_select_rtc
krn_spi_select_rtc:	  .res 3

.export krn_spi_deselect
krn_spi_deselect:		 jmp spi_deselect

.export krn_spi_rw_byte
krn_spi_rw_byte:		jmp spi_rw_byte

.export krn_spi_r_byte
krn_spi_r_byte:			jmp spi_r_byte

.export krn_uart_tx
krn_uart_tx:			jmp uart_tx

.export krn_uart_rx
krn_uart_rx:			jmp uart_rx

.export krn_primm
krn_primm:				jmp primm

.export krn_getcwd
krn_getcwd:				jmp fat_get_root_and_pwd

.export krn_spi_select_device
krn_spi_select_device:	  jmp spi_select_device

.export krn_write
krn_write:	 		jmp fat_write

.export krn_sd_write_block
krn_sd_write_block:	 	jmp sd_write_block

.export krn_sd_read_block
krn_sd_read_block:	 	jmp sd_read_block

.export krn_fread_byte
krn_fread_byte:         jmp fat_fread_byte

;.import uart_rx_nowait
;.export krn_uart_rx_nowait
;krn_uart_rx_nowait:	 	jmp uart_rx_nowait

.segment "VECTORS"
; $FFF8/$FFF9 RETVEC
.word 0
; ----------------------------------------------------------------------------------------------
; Interrupt vectors
; ----------------------------------------------------------------------------------------------
; $FFFA/$FFFB NMI Vector
.word do_nmi
; $FFFC/$FFFD reset vector
;*= $fffc
.word do_reset
; $FFFE/$FFFF IRQ vector
;*= $fffe
.word do_irq

.bss
startaddr:	.res 2