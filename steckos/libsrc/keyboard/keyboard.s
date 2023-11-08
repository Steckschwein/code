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

.include "zeropage.inc"
.include "spi.inc"

.import spi_r_byte
.import spi_deselect
.import spi_select_device
.import spi_replace_device
.import spi_set_device

.export getkey, fetchkey

.code
; Select Keyboard controller on SPI, read one byte
;	in: -
;	out:
;		C=1 key was fetched and A=<key code>, C=0 otherwise and A=<error / status code> e.g. #EBUSY
fetchkey:
		lda #spi_device_keyboard
		jsr spi_select_device
		bne exit

		phx

		jsr spi_r_byte
		jsr spi_deselect

		plx

		;  TODO FIXME - tradeoff here is that we override a possible previously stored key anyway
		sta key
    sec
		rts


; get byte from keyboard buffer
;	in: -
;	out:
;		C=1 key was pressed and A=<key code>, C=0 otherwise
getkey:
    lda key
    beq exit
    stz key
    sec
    rts
exit:
    clc
    rts
