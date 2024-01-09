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
.include "fcntl.inc"
.include "steckos.inc"

.autoimport

.export char_out=krn_chrout

.export crc16_hi = crc16_h
.export crc16_lo = crc16_l
.export crc16_init = crc16_table_init
.export xmodem_rcvbuffer = xmbuffer

.zeropage

appstart $1000

      bra @start
      lda (paramptr)
      bne :+
      jsr primm
      .byte "too few arguments",CODE_LF
      .byte "usage: stecklnk FILE", CODE_LF
      .byte 0
      bra @l_exit

:     lda paramptr
      ldx paramptr+1
@file: .asciiz "foo.txt"
@start:
      lda #<@file
      ldx #>@file
      ldy #O_CREAT
      jsr krn_open
      bcs @l_exit_err
      stx fd

      stz status
      jsr primm
      .byte "Stecklink ", 0

      lda #<handle_block
      ldx #>handle_block
      jsr ymodem_upload_callback
      bcc :+
      pha
      jsr primm
      .byte "ymodem i/o error",0
      pla
      jsr hexout_s

:     ldx fd
      jsr krn_close

@l_exit:
      jmp (retvec)

@l_exit_err:
      pha
      jsr primm
      .asciiz "Error: "
      pla
      jsr hexout_s
      bra @l_exit


; xmodem callback
; in:
;   A - block number
;   X - offset in data recv buffer until XMODEM_DATA_END
handle_block:

      cmp #0
      bne @data_block
      ldy status
      bne @data_block
      inc status

      ; 7a 6d 6f 64 65 6d 2e 74 78 74 00
      jsr primm
      .byte CODE_LF, "file: ",0
:     lda xmodem_rcvbuffer,x
      beq @l_fsize
      jsr char_out
      inx
      cpx #XMODEM_DATA_END
      bne :-
      bra @l_exit
@l_fsize:
      ; 31 33 20
      jsr primm
      .byte CODE_LF,"size: ",0
      inx
      jsr parseOctal
      bcs @l_exit
@l_modts:
      ; 31 34 35 34 37 30 31 37 35 34 33 20
      jsr primm
      .byte CODE_LF,"modify: ",0
      jsr parseOctal
      lda #CODE_LF
      jsr char_out
      bra @l_exit

@data_block:
      ldy crs_x ; save crs x
      phy
@copy:
      phx
      lda xmodem_rcvbuffer,x
      ldx fd
      jsr krn_write_byte
      bcs @l_exit
      _inc32 bytes
      plx
      inx
      cpx #XMODEM_DATA_END
      bne @copy

      jsr primm
      .byte "bytes: ", 0

      lda bytes+3
      jsr hexout_s
      lda bytes+2
      jsr hexout
      lda bytes+1
      jsr hexout
      lda bytes+0
      jsr hexout

      pla
      sta crs_x
      jmp krn_textui_update_crs_ptr
@l_exit:
      rts

parseOctal:
:     lda xmodem_rcvbuffer,x
      inx
      cmp #$20
      beq :+
      jsr char_out
      cpx #XMODEM_DATA_END
      bne :-
      rts
:     clc
      rts

.data
  bytes: .res 4, 0

.bss
  status: .res 1
  fd: .res 1
  crc16_l: .res 256
  crc16_h: .res 256
  xmbuffer: .res XMODEM_RECV_BUFFER_SIZE
