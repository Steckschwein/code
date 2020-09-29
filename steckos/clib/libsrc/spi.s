
.import popa
.import spi_select_device

;
; extern unsigned char __fastcall__ spi_select(SpiDevice d);
;
_spi_select:
;	stp
	lda #%00011010
	;0001 110 0
	;0001 101 0
	;0001 011 0
	jmp spi_select_device

;
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
		  ;pha
 ;		 jsr krn_hexout
 ;		 pla
		  ldx #$00
		  rts

_spi_write:
		  jsr krn_spi_rw_byte
		  ldx #$00				  ; low byte in A, clean high byte
		  pha
;		  jsr krn_hexout
		  pla
		  rts
