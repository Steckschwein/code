; enable debug for this module
.ifdef DEBUG_SDCARD
    debug_enabled=1
.endif

.include "common.inc"
.include "zeropage.inc"
.include "errno.inc"
.include "sdcard.inc"
.include "spi.inc"
.include "via.inc"
.include "debug.inc"
.code
.import spi_rw_byte, spi_r_byte, spi_select_device, spi_deselect

.import sd_select_card, sd_deselect_card

.ifdef MULTIBLOCK_WRITE
.export sd_write_multiblock
.endif


;---------------------------------------------------------------------
; Write multiple blocks to SD Card
;---------------------------------------------------------------------#
.ifdef MULTIBLOCK_WRITE
sd_write_multiblock:
      save

      ; TODO
      ; 1. make this work
      ; 2. use SET_WR_BLOCK_ERASE_COUNT (ACMD23) to pre-erase number of blocks

      jsr sd_select_card
      bne @exit

      jsr sd_cmd_lba
      lda #cmd25  ; Send CMD25 command byte
      jsr sd_cmd

      ; wait for command response.
      lda #$00
      jsr sd_wait
      bne @exit

@block:
      lda #sd_data_token
      jsr spi_rw_byte

      ldy #$00
@l2:  lda (sd_blkptr),y
      phy
      jsr spi_rw_byte
      ply
      iny
      bne @l2

      inc sd_blkptr+1

      ldy #$00
@l3:  lda (sd_blkptr),y
      phy
      jsr spi_rw_byte
      ply
      iny
      bne @l3

      ; Send fake CRC bytes
      lda #$00
      jsr spi_rw_byte
      lda #$00
      jsr spi_rw_byte

      inc sd_blkptr+1

      dec blocks
      bne @block

      ; all blocks read, send cmd12 to end transmission
      ; jsr sd_param_init
      lda #cmd12
      jsr sd_cmd

@exit:
      restore
      jmp sd_deselect_card
.endif
