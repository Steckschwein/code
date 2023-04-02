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

.ifdef DEBUG_RTC; enable debug for this module
	debug_enabled=1
.endif

.include "kernel.inc"
.include "rtc.inc"
.include "spi.inc"
.include "via.inc"
.import spi_rw_byte, spi_r_byte, spi_deselect, spi_select_device
.import rtc_systime_update

.export init_rtc

.code

init_rtc:
	; disable RTC interrupts
	; Select SPI SS for RTC
	lda #spi_device_rtc
	sta via1portb
	lda #rtc_write | rtc_reg_ctrl
	jsr spi_rw_byte
	lda #$00 ; disable INT0, INT1, WP (Write Protect)
	jsr spi_rw_byte
	jmp spi_deselect
