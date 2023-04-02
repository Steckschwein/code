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

.export rtc_write_reg

.code

; useful for alarm registers where no burst mode is available
; in:
;   X - adress
;   A - value
rtc_write_reg:
      pha
      txa
      jsr spi_rw_byte
      pla
      jmp spi_rw_byte

