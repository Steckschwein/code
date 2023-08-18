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
.include "appstart.inc"
.include "uart.inc"
.include "keyboard.inc"

.autoimport

.export char_out=$8D2E

appstart $1000

.code
      sei
      jsr primm
      .byte KEY_LF,"steckschwein 2.0 rom test", KEY_LF, 0

      jsr primm
      .byte "read", 0
      jsr dump

      jsr primm
      .byte KEY_LF,"write", KEY_LF,0

      lda #31
      ldx #01
      ldy #00
      jsr rom_write_byte_protected

      jsr primm
      .byte KEY_LF,"read back", 0
      jsr dump

@exit:
     bra @exit

dump:
      ldx #0
@l:
      txa
      and #$07
      bne :+
      lda #KEY_LF
      jsr char_out
:
      lda $4000,x
      phx
      jsr hexout_s
      lda #' '
      jsr char_out
      plx
      inx
      cpx #$10
      bne @l
      rts


.bss
rom_poll: