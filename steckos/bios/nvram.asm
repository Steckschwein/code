.export read_nvram
.import spi_rw_byte, print_crlf, primm
.import param_defaults
.include "bios.inc"
.include "nvram.inc"
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
	println "NVRAM: Invalid signature."
    ldy #.sizeof(nvram)
@lp1:
    lda param_defaults,y
    sta (ptr1),y
    dey
    bpl @lp1

@exit:
	restore
	rts
