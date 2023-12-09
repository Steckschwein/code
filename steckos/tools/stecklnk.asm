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

.autoimport

.export char_out=krn_chrout

.export crc16_hi = BUFFER_0
.export crc16_lo = BUFFER_1
.export crc16_init = crc16_table_init
.export xmodem_rcvbuffer = sd_block

.zeropage
ptr1:   .res 2
ptr2:   .res 2
p_tgt:  .res 2

appstart $1000

      lda #<sd_block
      sta p_tgt
      lda #>sd_block
      sta p_tgt+1
      lda #4
      sta bcnt

      stz lba_addr+0
      stz lba_addr+1
      stz lba_addr+2
      stz lba_addr+3

      jsr primm
      .asciiz "SD Init ... "
      jsr sdcard_init
      beq :+
      pha
      jsr primm
      .asciiz "Error "
      pla
      jsr hexout_s
      jmp (retvec)

:     jsr primm
      .byte "OK", KEY_LF

      jsr primm
      .asciiz "SD Image "

;      sei
      lda #<handle_block
      ldx #>handle_block
      jsr xmodem_upload_callback

      jsr primm
      .asciiz " OK. Reset..."

      jmp (SYS_VECTOR_RESET)  ; reset

handle_block:
      ldy crs_x ; save crs x
      phy
      pha
@copy:
      lda xmodem_rcvbuffer,x
      sta (p_tgt)
      inc p_tgt
      bne :+
      inc p_tgt+1
:     inx
      cpx #XMODEM_DATA_END
      bne @copy

      dec bcnt
      bne @l_exit

      lda #<sd_block
      sta p_tgt
      lda #>sd_block
      sta p_tgt+1
      lda #4
      sta bcnt

      pla
      lda lba_addr+3
      jsr hexout_s
      lda lba_addr+2
      jsr hexout
      lda lba_addr+1
      jsr hexout
      lda lba_addr+0
      jsr hexout
      pla
      sta crs_x

      SetVector sd_block, write_blkptr
      jsr sd_write_block

      _inc32 lba_addr

@l_exit:
      rts

.bss
  bcnt: .res 1
  sd_block: .res 512