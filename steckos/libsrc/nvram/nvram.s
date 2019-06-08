.export read_nvram
.import spi_rw_byte, print_crlf, primm
.import nvram_defaults
.include "system.inc"
.include "common.inc"
.include "nvram.inc"
.include "via.inc"
.include "keyboard.inc"
.importzp ptr1

.code
;---------------------------------------------------------------------
; read sizeof(struct nvram) bytes from RTC as parameter buffer
; copy defaults if nvram signature fail or crc error
; A/Y - destination address
;---------------------------------------------------------------------
read_nvram:
	save
    sta ptr1
    sty ptr1+1
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
	sta (ptr1),y
	iny
	cpy #nvram_size
	bne @l1

	; deselect all SPI devices
	lda #%01111110
	sta via1portb


    ldy nvram::signature
	lda #$42
	cmp (ptr1),y
	beq @exit

    ; copy defaults
    jsr primm
    .byte "NVRAM: Invalid signature.", KEY_LF, 0

    ldy #.sizeof(nvram)
@lp1:
    lda nvram_defaults,y
    sta (ptr1),y
    dey
    bpl @lp1

@exit:
	restore
	rts
