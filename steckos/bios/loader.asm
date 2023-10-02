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

.include "common.inc"
.include "system.inc"
.include "keyboard.inc"
.include "zeropage.inc"
.include "appstart.inc"

.autoimport

.export char_out=vdp_charout

.export crc16_hi = BUFFER_0
.export crc16_lo = BUFFER_1
.export crc16_init = crc16_table_init
.export xmodem_rcvbuffer = BUFFER_2

.zeropage
p_tgt:		.res 2

appstart $1000

      ; enable RAM to load bios into
      lda #$02
      sta bank2
      lda #$03
      sta bank3

      lda #<bios_start
      sta p_tgt
      lda #>bios_start
      sta p_tgt+1

      lda #<handle_block
      ldx #>handle_block
      jsr xmodem_upload_callback

      jsr primm
      .asciiz " OK "

      jmp (SYS_VECTOR_RESET)

handle_block:
      ldx crs_x
      phx
      pha
      ldx #0
:     lda xmodem_rcvbuffer,x
      sta (p_tgt)
      inc p_tgt
      bne :+
      inc p_tgt+1
:     inx
      cpx #$80
      bne :-

      pla
      jsr hexout_s
      inc crs_x
      lda p_tgt+1
      jsr hexout_s
      lda p_tgt
      jsr hexout
      pla
      sta crs_x
      rts
