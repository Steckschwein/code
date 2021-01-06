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


; enable debug for this module
.ifdef DEBUG_SDCARD_READ_MULTIBLOCK
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
.import sd_select_card, sd_deselect_card, sd_cmd, sd_cmd_lba
.import sd_busy_wait
.import fullblock

.export sd_read_multiblock


;---------------------------------------------------------------------
; Read multiple blocks from SD Card
;in:
;	A - sd card cmd byte (cmd17, cmd18, cmd24, cmd25)
;	block lba in lba_addr
;	block count in blocks
;
;out:
;	A - A = 0 on success, error code otherwise
;---------------------------------------------------------------------
.code
sd_read_multiblock:
			phx
			phy

			jsr sd_select_card

			jsr sd_cmd_lba
			lda #cmd18	; Send CMD18 command byte
			jsr sd_cmd
			debug "sdm18"
			bne @exit
@l1:
			jsr fullblock
			bne @exit
			inc read_blkptr+1

			debug16 "sd_rm", blocks
			dec blocks
			bne @l1

			; all blocks read, send cmd12 to end transmission
			lda #cmd12
			jsr sd_cmd
			beq @exit			; no busy, already done
			jsr sd_busy_wait	; otherwise do a busy wait
			
@exit:
			ply
			plx
			jmp sd_deselect_card
