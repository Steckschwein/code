; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

;@module: sdcard

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

.import spi_rw_byte, spi_r_byte, spi_select_device, spi_deselect
.import sd_deselect_card, sd_select_card, sd_cmd, sd_cmd_lba

.export sd_write_block

; public bock api
; .export write_block=sd_write_block

.code
;---------------------------------------------------------------------
; Write block to SD Card
;in:
;  A - sd card cmd byte (cmd17, cmd18, cmd24, cmd25)
;  block lba in lba_addr
;  sd_blkptr - pointer to data
;out:
;  C = 0 on success, C = 1 on error and A =<error code> otherwise
;---------------------------------------------------------------------
;@name: "sd_read_block"
;@in: lba_addr, "LBA address of block"
;@in: sd_blkptr, "target adress for the block data to be read"
;@out: A, "error code"
;@out: C, "0 - success, 1 - error"
;@clobbers: A,X,Y
;@desc: "Write block to SD Card"
sd_write_block:
      phx
      phy
      jsr sd_select_card

      jsr sd_cmd_lba
      lda #cmd24
      jsr sd_cmd
      bne @exit

      lda #sd_data_token
      jsr spi_rw_byte

      ldy #0

      jsr __sd_write_block_halfblock
      inc sd_blkptr+1
      jsr __sd_write_block_halfblock
      dec sd_blkptr+1

      ; Send fake CRC bytes
      lda #$00
      jsr spi_rw_byte
      lda #$00
      jsr spi_rw_byte

      lda #$00  ; success
@exit:
      ply
      plx
      jmp sd_deselect_card

__sd_write_block_halfblock:
:     lda (sd_blkptr),y
      phy
      jsr spi_rw_byte
      ply
      iny
      bne :-
      rts
