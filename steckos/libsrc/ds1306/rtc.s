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

.importzp __volatile_ptr

.export rtc_systime
.export rtc_systime_update

.code

;in:
;	A/X pointer to a time_t struct @see asminc/rtc.inc
;out:
;	Z=0 ok, Z=1 and A with error
rtc_systime:
	sta __volatile_ptr		;safe pointer
	stx __volatile_ptr+1
	jsr rtc_systime_update
	ldy #.sizeof(time_t)
@cp:
	lda rtc_systime_t, y
	sta (__volatile_ptr), y
	dey
	bne @cp
	rts		;exit Z=0 here

;in:
;  -
;out:
;  - time_t struct at address rtc_systime_t updated - @see rtc.inc
rtc_systime_update:
	lda #spi_device_rtc
	jsr spi_select_device
	beq :+
	rts
:	debug "update systime"
	lda #0			  	    ;0 means rtc read, start from first address (seconds)
	jsr spi_rw_byte

	jsr spi_r_byte		  ;seconds
	jsr BCD2dec
	sta rtc_systime_t+time_t::tm_sec

	jsr spi_r_byte	  	;minute
	jsr BCD2dec
	sta rtc_systime_t+time_t::tm_min

	jsr spi_r_byte	  	;hour
	jsr BCD2dec
	sta rtc_systime_t+time_t::tm_hour

	jsr spi_r_byte	  	;week day
	sta rtc_systime_t+time_t::tm_wday

	jsr spi_r_byte	  	;day of month
	jsr BCD2dec
	sta rtc_systime_t+time_t::tm_mday

	jsr spi_r_byte	  	;month
	dec					;dc1306 gives 1-12, but 0-11 expected
	jsr BCD2dec
	sta rtc_systime_t+time_t::tm_mon

	jsr spi_r_byte		;year value - rtc year 2000+year register
	jsr BCD2dec
	clc
	adc #100			;time_t year starts from 1900
	sta rtc_systime_t+time_t::tm_year
	debug32 "rtc0", rtc_systime_t
	debug32 "rtc1", rtc_systime_t+4
	jsr spi_deselect
   sec
   rts

; dec = (((BCD>>4)*10) + (BCD&0xf))
BCD2dec:
	tax
	and #%00001111
	sta __volatile_ptr
	txa
	and #%11110000		; highbyte => 10a = 8a + 2a
	lsr					 ; 2a
	sta __volatile_ptr+1
	lsr					  ;
	lsr					  ; 8a
	adc __volatile_ptr+1; = *10
	adc __volatile_ptr
	rts
