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

.ifndef _KEYBOARD_INC_
  _KEYBOARD_INC_ = 1

KEY_ENCODED			= $80

KEY_LF            = $0a
KEY_CR            = $0d
KEY_RETURN        = $0d
KEY_BACKSPACE     = $08
KEY_TAB           = $09


KEY_CTRL_C        = $03

KEY_CRSR_UP       = $1e  ;1 11 10
KEY_CRSR_DOWN     = $1d  ;1 11 11
KEY_CRSR_RIGHT    = $10  ;1 00 00
KEY_CRSR_LEFT     = $11  ;1 00 01

KEY_PGUP          = $4b
KEY_PGDOWN        = $4e
KEY_POS1          = $4a
KEY_END           = $4d



KEY_ESCAPE        = 27

KEY_FN1           = $f1
KEY_FN2           = $f2
KEY_FN3           = $f3

KEY_FN12          = $fc


KBD_CMD_LEDS      = $ed
KBD_CMD_TYPEMATIC = $f3
KBD_CMD_RESET     = $ff

KBD_RET_ACK       = $fa

KBD_HOST_CMD_PENDING    = $ff
KBD_HOST_CMD_STATUS_EOT = $aa
KBD_HOST_CMD_KBD_STATUS = $01
KBD_HOST_CMD_CMD_STATUS = $02

.endif