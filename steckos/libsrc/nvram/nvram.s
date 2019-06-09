.export read_nvram
.import spi_rw_byte, print_crlf, primm
.import nvram_defaults
.import crc7
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
    lda (ptr1),y
	cmp #nvram_signature
	beq @crc

    jsr primm
    .byte "NVRAM: Invalid signature.", KEY_LF, 0
    bra @copy_defaults

@crc:
    lda ptr1
    ldy ptr1+1
    ldx #.sizeof(nvram)-1
    jsr crc7

    ldy #nvram::crc7
    cmp (ptr1),y
    beq @exit

    jsr primm
    .byte "NVRAM: CRC error.", KEY_LF, 0

@copy_defaults:
    ldy #.sizeof(nvram)
@lp1:
    lda nvram_defaults,y
    sta (ptr1),y
    dey
    bpl @lp1



@exit:
	restore
	rts
