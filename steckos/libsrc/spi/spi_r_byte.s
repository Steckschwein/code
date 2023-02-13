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

.include "via.inc"
.include "spi.inc"
.include "errno.inc"

.zeropage
.code
.export spi_r_byte

;----------------------------------------------------------------------------------------------
; Receive byte VIA SPI
; Received byte in A at exit, Z, N flags set accordingly to A
; Destructive: A,X
;----------------------------------------------------------------------------------------------
_spi_delay:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rts

spi_r_byte:
		lda via1portb	; Port laden
		AND #$fe		  ; Takt ausschalten
		TAX				 		; aufheben
		INC

    jsr _spi_delay
		STA via1portb ; Takt An 1
    jsr _spi_delay
		STX via1portb ; Takt aus
    jsr _spi_delay
		STA via1portb ; Takt An 2
    jsr _spi_delay
		STX via1portb ; Takt aus
    jsr _spi_delay
		STA via1portb ; Takt An 3
    jsr _spi_delay
		STX via1portb ; Takt aus
    jsr _spi_delay
		STA via1portb ; Takt An 4
    jsr _spi_delay
		STX via1portb ; Takt aus
    jsr _spi_delay
		STA via1portb ; Takt An 5
    jsr _spi_delay
		STX via1portb ; Takt aus
    jsr _spi_delay
		STA via1portb ; Takt An 6
    jsr _spi_delay
		STX via1portb ; Takt aus
    jsr _spi_delay
		STA via1portb ; Takt An 7
    jsr _spi_delay
		STX via1portb ; Takt aus
    jsr _spi_delay
		STA via1portb ; Takt An 8
    jsr _spi_delay
		STX via1portb ; Takt aus
    jsr _spi_delay

		lda via1sr
		rts
