.export read_nvram
.import spi_rw_byte, print_crlf, primm
.import nvram_defaults
.import crc7
.include "system.inc"
.include "common.inc"
.include "nvram.inc"
.include "via.inc"
.include "keyboard.inc"
.importzp __volatile_ptr

.code
;---------------------------------------------------------------------
; read sizeof(struct nvram) bytes from RTC as parameter buffer
; copy defaults if nvram signature fail or crc error
; A/Y - destination address
;---------------------------------------------------------------------
read_nvram:
	save
 	sta __volatile_ptr
 	sty __volatile_ptr+1
	; select RTC
	lda #%01110110
	sta via1portb

	lda #nvram_start
	jsr spi_rw_byte

	ldy #$00
@l1:
	phy
	lda #$ff
	jsr spi_rw_byte
	ply
	sta (__volatile_ptr),y
	iny
	cpy #nvram_size
	bne @l1

	; deselect all SPI devices
	lda #%01111110
	sta via1portb

	 lda __volatile_ptr
	 ldy __volatile_ptr+1
	 ldx #.sizeof(nvram)-1
	 jsr crc7

	 cmp#0
	 beq @copy_defaults

	 ldy #nvram::crc7
	 cmp (__volatile_ptr),y
	 beq @exit

	 jsr primm
	 .byte "NVRAM: CRC error.", KEY_LF, 0

@copy_defaults:
	 ldy #.sizeof(nvram)-1
@lp1:
	 lda nvram_defaults,y
	 sta (__volatile_ptr),y
	 dey
	 bpl @lp1

@exit:
	restore
	rts
