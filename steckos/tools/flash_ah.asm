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
.include "zeropage.inc"
.include "steckos.inc"

.autoimport

.export char_out=krn_chrout

.export crc16_hi = BUFFER_0
.export crc16_lo = BUFFER_1
.export crc16_init = crc16_table_init
.export xmodem_rcvbuffer = BUFFER_2

.zeropage

;tmp1:   .res 1
;tmp2:   .res 1
;ptr1:   .res 2
;ptr2:   .res 2
p_src:  .res 2
p_rom:  .res 2

appstart $1000
      print "Rom: "
      jsr rom_print_device_id
      println " detected."

      jsr rom_write
      tya
      jsr hexout_s
      jsr _ok

      jmp (retvec)

      jsr _set_pointer

      print "BIOS "
      lda #<handle_block
      ldx #>handle_block
      jsr xmodem_upload_callback
      jsr _ok


      println "Write ROM image ..."
      jsr _write_image
      bcc :+
      println " FAILED! check write protection."
      jmp @halt
:     jsr _ok

      println "Verify ROM ..."
      jsr _verify_image
      bcc :+
      pha
      println " FAILED! byte/address "
      pla
      jsr hexout_s
      jsr _update_status

      jmp @halt
:     jsr _ok

      println "Software Data Protection Enable ... "
      ;jsr rom_sdp_enable
      jsr _ok

      jsr primm
      .asciiz "Reset ..."
@reset:
      jsr _rom_on
      jmp (SYS_VECTOR_RESET)  ; reset
@halt:
      ;jsr rom_sdp_enable
:     bra :-
_ok:
      jsr primm
      .byte "OK.      ", CODE_LF, 0
      rts

_rom_off:
      ldx #$02
      stx slot2_ctrl
      ldx #$03
      stx slot3_ctrl
      rts

_rom_on:
      ldx #$80
      stx slot2_ctrl
      ldx #$81
      stx slot3_ctrl
      rts

_verify_image:
      jsr _set_pointer
@loop:
      jsr _update_status

:     jsr _rom_off
      lda (p_src)     ; read byte of bios image from RAM

      jsr _rom_on
      cmp (p_src)     ; compare with byte in ROM
      bne @error_exit

      inc p_src
      inc p_rom       ; for status update
      bne :-
      inc p_rom+1
      inc p_src+1     ; until overflow $0000
      bne @loop
      clc
      rts
@error_exit:
      sec
      rts

_write_image:
      jsr _set_pointer
@loop:
      jsr _update_status
:     lda (p_src) ; load byte to write from RAM
      ldx p_rom   ; set rom address
      ldy p_rom+1
      jsr rom_write_byte
      bcs @exit
      inc p_rom
      inc p_src
      bne :-
      inc p_rom+1
      inc p_src+1
      lda p_src+1
      cmp #$89
      bne @loop ; until overflow $0000
      clc
@exit:
      rts

_update_status:
      lda crs_x
      pha
      lda #' '
      jsr char_out
      lda p_rom+1
      jsr hexout_s
      lda p_rom+0
      jsr hexout
      pla
      sta crs_x
      rts

_set_pointer:
      lda #<slot1
      sta p_src
      lda #>slot1
      sta p_src+1
      stz p_rom
      stz p_rom+1 ; rom address $0000
      rts

handle_block:
      ldy crs_x ; save crs x
      phy
      pha       ; save block nr
@copy:
      lda xmodem_rcvbuffer,x
      sta (p_src)
      inc p_src
      bne :+
      inc p_src+1
:     inx
      cpx #XMODEM_DATA_END
      bne @copy

      pla
      jsr hexout_s
      inc crs_x
      lda p_src+1
      jsr hexout_s
      lda p_src
      jsr hexout
      pla
      sta crs_x
      rts
