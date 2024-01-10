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

      stz status
      stz fd

      jsr primm
      .byte "Stecklink ", 0

      lda #<handle_block
      ldx #>handle_block
      jsr ymodem_upload_callback
      bcc :+
      pha
      jsr primm
      .byte CODE_LF, "y-modem i/o error: ", 0
      pla
      jsr hexout_s

:     ldx fd
      jsr krn_close

quit:
      jmp (retvec)

; xmodem callback
; in:
;   A - block number
;   X - offset in data recv buffer until XMODEM_DATA_END
handle_block:

      cmp #0
      bne data_block

      ldy status        ; header block 0 received?
      bne data_block
      inc status
      bra header_block

data_block:
      ldy crs_x ; save crs x
      phy

      lda fd
      beq @l_exit    ; no fd was reserved. an error occured, skip further writes
      jsr write_bytes

      jsr primm
      .byte "bytes: ", 0

      lda bytes+1
      jsr hexout_s
      lda bytes+0
      jsr hexout
 @l_exit:
      pla
      sta crs_x
      jmp krn_textui_update_crs_ptr

header_block:
      ; 7a 6d 6f 64 65 6d 2e 74 78 74 00
      jsr primm
      .byte CODE_LF, "file: ",0
      ldy #0
:     lda xmodem_rcvbuffer,x
      sta fname,y
      beq :+
      jsr char_out
      iny
      inx
      cpx #XMODEM_DATA_END
      bne :-
      bra @l_exit

:     phx         ; save x receive buffer
      lda #<fname
      ldx #>fname
      ldy #O_CREAT
      jsr krn_open
      bcc :+
      pha
      jsr primm
      .byte CODE_LF, "i/o error: ", 0
      pla
      jsr hexout_s
      bra @l_exit
 :    stx fd
      plx
@l_fsize:
      ; 31 33 20
      stz fsize+0
      stz fsize+1
      jsr primm
      .byte CODE_LF,"size: ",0
      inx
      jsr parseFsize
      bcs @l_exit
      lda #' '
      jsr char_out
      lda fsize+1
      jsr hexout_s
      lda fsize+0
      jsr hexout
@l_modts:
      ; 31 34 35 34 37 30 31 37 35 34 33 20
      jsr primm
      .byte CODE_LF,"modified: ",0
      inx
      jsr parseOctal

      lda #CODE_LF
      jsr char_out
@l_exit:
      rts

write_bytes:
      cmp16 fsize, bytes, :+
      rts
:     phx
      lda xmodem_rcvbuffer,x
      ldx fd
      jsr krn_write_byte
      bcs @l_exit
      _inc32 bytes
      plx
      inx
      cpx #XMODEM_DATA_END
      bne write_bytes
@l_exit:
      rts

parseFsize:
:     lda xmodem_rcvbuffer,x
      cmp #$20
      beq :+
      jsr @dec2hex
      inx
      cpx #XMODEM_DATA_END
      bne :-
      rts
:     clc
      rts
@dec2hex:
      pha
      jsr @mul_10   ; fsize * 10
      pla
      and #$0f
      clc
      adc fsize+0
      sta fsize+0
      lda fsize+1
      adc #0
      sta fsize+1
      rts
@mul_10:    ;
      lda fsize+0
      ldy fsize+1
      asl           ; *2
      rol fsize+1
      asl           ; *4
      rol fsize+1
      clc
      adc fsize+0   ; +1 (*5)
      sta fsize+0
      tya
      adc fsize+1
      asl fsize+0   ; *2 (*10)
      rol
      sta fsize+1
      rts


parseOctal:
parseNumber:
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
  bytes: .res 2, 0

.bss
  fname:  .res 32
  fsize:  .res 2
  status: .res 1
  fd: .res 1
  crc16_l: .res 256
  crc16_h: .res 256
  xmbuffer: .res XMODEM_RECV_BUFFER_SIZE
