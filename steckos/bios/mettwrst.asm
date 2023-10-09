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
.include "appstart.inc"
.include "xmodem.inc"
.include "vdp.inc"
.include "zeropage.inc"

.autoimport

.export char_out=vdp_charout

.export crc16_hi = BUFFER_0
.export crc16_lo = BUFFER_1
.export crc16_init = crc16_table_init
.export xmodem_rcvbuffer = BUFFER_2

.zeropage
tmp1:   .res 1
tmp2:   .res 1
ptr1:   .res 2
ptr2:   .res 2
p_tgt:  .res 2
p_rom:  .res 2

appstart $1000

      sei
      jsr primm
      .byte 1,2,3,4,5,6,7,8,9,$b,$c,$1d,$1e,CODE_LF,0

      jsr primm
      .asciiz "BIOS "

      jsr _rom_off        ; enable RAM to load bios image to bios_start
      jsr _set_pointer
      lda #<handle_block
      ldx #>handle_block
      jsr xmodem_upload_callback
      jsr _ok

      jsr primm
      .asciiz "Software Data Protection Disable ... "
      jsr rom_sdp_disable
      jsr _ok

      jsr primm
      .asciiz "Write ROM image ..."
      jsr _write_image
      bcc :+
      jsr primm
      .asciiz " FAILED! check write protection."
      jmp @halt
:     jsr _ok

      jsr primm
      .asciiz "Verify ROM ..."
      jsr _verify_image
      bcc :+
      pha
      jsr primm
      .asciiz " FAILED! byte/address "
      pla
      jsr hexout_s
      jsr _update_status

      jmp @halt
:     jsr _ok

      jsr primm
      .asciiz "Software Data Protection Enable ... "
      jsr rom_sdp_enable
      jsr _ok

      jsr primm
      .asciiz "Reset ..."
@reset:
      jsr _rom_on
      jmp (SYS_VECTOR_RESET)  ; reset
@halt:
      jsr rom_sdp_enable
:     bra :-
_ok:
      jsr primm
      .byte "OK.      ", CODE_LF, 0
      rts

_rom_off:
      ldx #$02
      stx bank2
      ldx #$03
      stx bank3
      rts

_rom_on:
      ldx #$80
      stx bank2
      ldx #$81
      stx bank3
      rts

_verify_image:
      jsr _set_pointer
@loop:
      jsr _update_status

:     jsr _rom_off
      lda (p_tgt)     ; read byte of bios image from RAM

      jsr _rom_on
      cmp (p_tgt)     ; compare with byte in ROM
      bne @error_exit

      inc p_tgt
      inc p_rom       ; for status update
      bne :-
      inc p_rom+1
      inc p_tgt+1     ; until overflow $0000
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
:     lda (p_tgt) ; load byte to write from RAM
      ldx p_rom   ; set rom address
      ldy p_rom+1
      jsr rom_write_byte
      bcs @exit
      inc p_rom
      inc p_tgt
      bne :-
      inc p_rom+1
      inc p_tgt+1
      lda p_tgt+1
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
      lda #<bios_start
      sta p_tgt
      lda #>bios_start
      sta p_tgt+1
      stz p_rom
      stz p_rom+1 ; rom address $0000
      rts

handle_block:
      ldy crs_x ; save crs x
      phy
      pha       ; save block nr
@copy:
      lda xmodem_rcvbuffer,x
      sta (p_tgt)
      inc p_tgt
      bne :+
      inc p_tgt+1
:     inx
      cpx #XMODEM_DATA_END
      bne @copy

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
