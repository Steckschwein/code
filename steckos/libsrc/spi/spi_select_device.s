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
.ifdef DEBUG_SPI; enable debug for this module
	debug_enabled=1
.endif

;.include "kernel.inc"
.include "via.inc"
.include "spi.inc"
.include "errno.inc"

.export spi_select_device
.export spi_set_device
.export spi_replace_device

.code
; select spi device given in A. the method is aware of the current processor state, especially the interrupt flag
; in:
;	A = spi device, one of devuces see spi.inc
; out:
;	Z = 1 spi for given device could be selected (not busy), Z=0 otherwise
spi_select_device:
		php
		sei ;critical section start
		pha

; check busy and select within sei => !ATTENTION! is busy check and spi device select must be "atomic", otherwise the spi state may change in between
; out:
;   Z=1 not busy, Z=0 spi is busy and A=#EBUSY
spi_isbusy:
		lda via1portb
    and #spi_device_deselect
    cmp #spi_device_deselect
		bne @l_exit		;busy, leave section, device could not be selected

		pla
		sta via1portb

		plp
		lda #EOK	;exit ok
		rts

@l_exit:
		pla
		plp				  ;restore P (interrupt flag)
		lda #EBUSY
		rts


; in:
;   A - device to select
; out:
;   X - previous selected device if any, the "deselect device" otherwise
spi_replace_device:
    pha
		lda via1portb
    and #spi_device_deselect
    tax
    pla
spi_set_device:
    and #spi_device_deselect
		sta via1portb
    rts