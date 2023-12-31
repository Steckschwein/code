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

;----------------------------------------------------------------------------
; time struct with date set to 1970-01-01
.struct time_t
		  tm_sec	.byte		  ;0-59
		  tm_min	.byte		  ;0-59
		  tm_hour	.byte		  ;0-23
		  tm_mday	.byte		  ;1-31
		  tm_mon	.byte		  ;0-11 0-jan, 11-dec
		  tm_year	.word     ;years since 1900
		  tm_wday	.byte		  ;
 ;		 tm_yday
  ;		tm_isdst
.endstruct

;----------------------------------------------------------------------------
; last known timestamp with date set to 1970-01-01
rtc_systime_t = $02a0

; read rtc
rtc_read = 0
rtc_write = $80

rtc_reg_alm_mask  = 1<<7
rtc_reg_alm0_s = $07
rtc_reg_alm0_m = $08
rtc_reg_alm0_h = $09
rtc_reg_alm0_d = $0a

rtc_reg_ctrl    = $0f
rtc_reg_status  = $10
rtc_ctrl_wp     = 1<<6  ; write protect
rtc_ctrl_aie0   = 1<<0  ; alarm 0 interrupt enable

rtc_status_irq0 = 1<<0  ; alarm 0 interrupt request

.if .VERSION = (2*$100+17*$10+0)
.global				 _clock_gettime
;------------------------------------------------------------------------------
; Struct timespec - must match the struct defined in time.h
.struct timespec
		  tv_sec  .dword
		  tv_nsec .dword
.endstruct
.endif
