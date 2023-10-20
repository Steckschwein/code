.include "asminc/spi.inc"
.include "errno.inc"

.import spi_select_device

;
; extern unsigned char __fastcall__ spi_select(SpiDevice d);
;
; select spi device upon ordinal number given in A
;	in:
;		A = [0..2]
;		 0 - SDCARD
;		 1 - KEYBOARD
;		 2 - RTC
;	out:
;		@see spi_select_device below
device_n:
	.byte spi_device_sdcard
	.byte spi_device_keyboard
	.byte spi_device_rtc
spi_select_device_n:
		and #$03
		cmp #3
		bne :+
		lda #EINVAL
		rts
:		phx
		tax
		lda device_n,x
		plx
		jmp spi_select_device

_spi_select=spi_select_device_n
_spi_deselect = krn_spi_deselect

;
;
; unsigned char _spi_read ();
;
		  .export			_spi_read
		  .export			_spi_write
		  .export			_spi_deselect
		  .export			_spi_select

		  .include		"kernel/kernel_jumptable.inc"

_spi_read:
		  jsr krn_spi_r_byte
		  ldx #$00
		  rts

_spi_write:
		  jsr krn_spi_rw_byte
		  ldx #$00				  ; low byte in A, clean high byte
		  rts
