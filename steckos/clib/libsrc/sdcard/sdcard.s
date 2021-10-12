;
;
;  unsigned char __fastcall__ read_block(unsigned char *address, SpiDevice device);
;
;
.include "zeropage.inc"
.include "asminc/spi.inc"

.import _spi_select, spi_select_device_n
.import sd_read_block
.import popax

.importzp read_blkptr

.export _read_block

.proc _read_block

    lda #spi_device_sdcard
    jsr _spi_select ; A - enum
    bne @exit

    jsr popax
    sta read_blkptr
    stx read_blkptr+1
    jsr sd_read_block
@exit:
    ldx #0
    rts
.endproc

