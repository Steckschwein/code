.export read_nvram
.import spi_rw_byte, print_crlf, primm, set_filenameptr
.include "bios.inc"
.include "nvram.inc"
.importzp ptr1

.code
;---------------------------------------------------------------------
; read sizeof(struct nvram) bytes from RTC as parameter buffer
; A/X - destination address
;---------------------------------------------------------------------
read_nvram:
	save
    sta ptr1
    stx ptr1+1
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
	bne @invalid_sig

	SetVector nvram, paramvec
	jsr set_filenameptr

@exit:
	restore
	rts
@invalid_sig:
	println "NVRAM: Invalid signature."
	bra @exit
; .nvram_crc_error
; 	+print .txt_nvram_crc_error
; 	bra -
