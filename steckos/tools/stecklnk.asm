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

.include "xmodem.inc"
.include "steckos.inc"
.include "fcntl.inc"

.autoimport

.export char_out=krn_chrout

.export crc16_hi = crc16_h
.export crc16_lo = crc16_l
.export crc16_init = crc16_table_init
.export xmodem_rcvbuffer = xmbuffer

.zeropage
ptr1:   .res 2
ptr2:   .res 2
p_tgt:  .res 2

appstart $1000


    	lda paramptr
    	ldx paramptr+1
      ldy #O_CREAT
      jsr krn_open
      bcs @l_exit_err
      stx fd

      jsr primm
      .byte KEY_LF, "Stecklink ", 0

      lda #<handle_block
      ldx #>handle_block
      jsr xmodem_upload_callback

      ldx fd
      jsr krn_close

@l_exit:
      jmp (retvec)

@l_exit_err:
      pha
      jsr primm
      .asciiz "Error "
      pla
      jsr hexout_s
      bra @l_exit



handle_block:
      ldy crs_x ; save crs x
      phy
      pha

@copy:
      lda xmodem_rcvbuffer,x
      phx
      ldx fd
      jsr krn_write_byte
      plx
      bcs @l_exit
      inx
      cpx #XMODEM_DATA_END
      bne @copy

@l_exit:

      pla
      pla
      sta crs_x
      rts

.bss
  fd: .res 1
  crc16_l: .res 256
  crc16_h: .res 256
  xmbuffer: .res XMODEM_RECV_BUFFER
