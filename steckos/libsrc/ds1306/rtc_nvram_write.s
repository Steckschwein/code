.export rtc_nvram_write
.import spi_rw_byte
.import spi_deselect
.importzp __volatile_tmp
.importzp __volatile_ptr

.include "system.inc"
.include "common.inc"
.include "spi.inc"
.include "nvram.inc"
.include "via.inc"
.include "errno.inc"


.code
;---------------------------------------------------------------------
; write .X bytes to RTC nvram
; A/Y - source address
; X - size of bytes to write
; C=0 ok, C=1 on error
;---------------------------------------------------------------------
rtc_nvram_write:
    save
    cpx #96+1 ; max bytes
    bne :+
    lda #EINVAL
    rts
:
    stx __volatile_tmp
    sta __volatile_ptr
    sty __volatile_ptr+1
    ; select RTC
	  lda #spi_device_rtc
	  sta via1portb

	  lda #(nvram_write|nvram_start)
  	jsr spi_rw_byte

    ldy #0
:   lda (__volatile_ptr),y
    phy
    jsr spi_rw_byte
    ply
    iny
    cpy __volatile_tmp
    bne :-
@exit:
    jsr spi_deselect
    restore
    clc
    rts