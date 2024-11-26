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

; extern unsigned char __fastcall__ xmodem_upload(void* fn_receive);
.proc _xmodem_upload
              sta xmodem_recv_cb          ; init jsr with callback address
              stx xmodem_recv_cb+1

              lda #<xmodem_upload_cb
              ldx #>xmodem_upload_cb      ; call xmodem with our callback
              jsr xmodem_upload_callback
              lda #0
              bcc :+
              lda #$ff
:             tax
              rts
.endproc

xmodem_upload_cb:
              save

              lda #<xmodem_buffer
              ldx #>xmodem_buffer
              jsr @call_cb

              restore
              rts
@call_cb:     jmp (xmodem_recv_cb)

.bss
  xmodem_recv_cb: .res 2
  xmodem_buffer:  .res 132
  xmodem_crc16_l: .res 256
  xmodem_crc16_h: .res 256
