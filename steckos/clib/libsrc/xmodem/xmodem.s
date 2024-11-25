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

.include "asminc/common.inc"
.include "kernel/kernel_jumptable.inc"

.export _xmodem_upload

.export xmodem_rcvbuffer= xmodem_buffer
.export crc16_init      = crc16_table_init
.export crc16_lo        = xmodem_crc16_l
.export crc16_hi        = xmodem_crc16_h

.export char_out=putchar ; TODO FIXME xmodem requires this. get rid of. introduce stdin

.import putchar
.import xmodem_upload_callback
.import crc16_table_init

.autoimport

.importzp ptr1

; extern void __fastcall__ xmodem_upload(void* fn_receive);
.proc _xmodem_upload
              sta xmodem_recv_cb+1        ; init jsr with callback address
              stx xmodem_recv_cb+2

              lda #<xmodem_upload_cb
              ldx #>xmodem_upload_cb      ; call xmodem with our callback
              jmp xmodem_upload_callback
.endproc

xmodem_upload_cb:
              save

              jsr pusha
              lda #<xmodem_buffer
              ldx #>xmodem_buffer
xmodem_recv_cb:
              jsr 0000

              restore
              rts

.bss
  xmodem_buffer:  .res 132
  xmodem_crc16_l: .res 256
  xmodem_crc16_h: .res 256
