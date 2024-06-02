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

.include "spi65.inc"
.include "errno.inc"

.importzp spi_sr

.export spi65_tx_byte
;@module: spi
.code
;----------------------------------------------------------------------------------------------
; Transmit byte VIA SPI
; Byte to transmit in A, received byte in A at exit
; Destructive: A,X,Y
;----------------------------------------------------------------------------------------------
;@name: "spi_rw_byte"
;@in: A, "byte to transmit"
;@out: A, "received byte"
;@clobbers: A
;@desc: "transmit byte via SPI"
spi65_tx_byte:
    ; phx

;     bit spi65_status
;     bpl :+
;     ldx spi65_data
; :
    sta spi65_data

    ; wait for shift to finish
@wait:
    bit spi65_status
    bpl @wait

    lda spi65_data
    
    ; plx
    rts
