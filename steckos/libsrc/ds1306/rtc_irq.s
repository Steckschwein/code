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

.ifdef DEBUG_DS1306 ; debug switch for this module
	debug_enabled=1
.endif

.include "debug.inc"
.include "rtc.inc"
.include "spi.inc"

.import spi_select_device
.import spi_deselect
.import spi_r_byte
.import spi_rw_byte

.export rtc_irq0_ack
.export rtc_irq0


.code
;
; out:
;   C=1 if alarm interrupt 0 occured and could be acknowledged, C=0 otherwise
rtc_irq0_ack:
	    lda #spi_device_rtc
	    jsr spi_select_device
	    beq :+
      clc
	    rts
:     lda #(rtc_read | rtc_reg_status)
      jsr spi_rw_byte
      jsr spi_r_byte
      clc
      and #rtc_sats_irq0
      beq @exit
      lda #(rtc_read | rtc_reg_alm0_s)
      jsr spi_rw_byte
      jsr spi_r_byte
      sec
@exit:
      jmp spi_deselect

;in:
;out:
;	C=1 IRQF0 (bit 0) is set in DS1306 control register, C=0 on error, A=<error> .e.g EBUSY
rtc_irq0:
      lda #spi_device_rtc
      jsr spi_select_device
      beq :+
      clc
      rts
:     ; set mask to "once per second"
      lda #rtc_write | rtc_reg_alm0_s
      jsr spi_rw_byte
      lda #rtc_reg_alm_mask
      jsr spi_rw_byte
      jsr spi_rw_byte
      jsr spi_rw_byte
      jsr spi_rw_byte

      ; enable alarm 0 int
      lda #(rtc_write | rtc_reg_ctrl)
      jsr spi_rw_byte
      lda #rtc_ctrl_aie0
      jsr spi_rw_byte
      sec
      jmp spi_deselect
