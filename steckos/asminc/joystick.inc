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

;
; bits are set per default (pull-up) and cleaned if fire or direction is pressed
;
JOY_PORT1         = 1<<7
JOY_PORT2         = !JOY_PORT1

JOY_UP            = 1<<0  ;000f rldu
JOY_DOWN          = 1<<1
JOY_LEFT          = 1<<2
JOY_RIGHT         = 1<<3
JOY_FIRE          = 1<<4

.macro joy_off
  lda #uart_mcr_out1
  ora uart1+uart_mcr
  sta uart1+uart_mcr
.endmacro

.macro joy_on ; joysticks on
  jsr joystick_on
.endmacro
