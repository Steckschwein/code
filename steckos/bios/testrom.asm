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
.include "zeropage.inc"

.autoimport

.export char_out=vdp_charout

.zeropage
tmp1:   .res 1
tmp2:   .res 1
ptr1:   .res 2
ptr2:   .res 2

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

      jsr rom_sdp_disable
      lda #$76
      ldx #0
      ldy #0
      jsr rom_write_byte_protected
      bcc :+
      jsr primm
      .asciiz "failed!"
      bra @sdp_enable

:     jsr hexout_s
      tya
      jsr hexout_s
      lda __volatile_ptr+1
      jsr hexout_s
      lda __volatile_ptr
      jsr hexout

      lda #$45
      ldx #1
      ldy #0
      jsr rom_write_byte_protected
      bcc :+
      jsr primm
      .asciiz "failed!"
:     jsr hexout_s
      tya
      jsr hexout_s
      lda __volatile_ptr+1
      jsr hexout_s
      lda __volatile_ptr
      jsr hexout

@sdp_enable:
      jsr rom_sdp_enable

      jsr primm
      .byte KEY_LF,"read back", 0
      jsr dump

@exit:
     bra @exit

dump:
      lda bank1
      pha
      lda #$80
      sta bank1
      ldx #0
@l:
      txa
      and #$0f
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
      cpx #$20
      bne @l

      pla
      sta bank1

      rts


.bss
rom_poll: