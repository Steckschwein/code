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


; enable debug for this module
.ifdef DEBUG_SDCARD
  debug_enabled=1
.endif

.include "system.inc"
.include "common.inc"
.include "zeropage.inc"
.include "errno.inc"
.include "sdcard.inc"
.include "spi.inc"
.include "via.inc"
.include "debug.inc"
.code
.import spi_rw_byte, spi_r_byte, spi_select_device, spi_deselect

.export sdcard_init, sdcard_detect
.export sd_select_card, sd_deselect_card
.export sd_read_block, sd_cmd, sd_cmd_lba
.export fullblock
.export sd_busy_wait

.ifdef MULTIBLOCK_WRITE
.export sd_write_multiblock
.endif


;  out:
;    Z=1 sd card available, Z=0 otherwise A=ENODEV
sdcard_detect:
    lda via1portb
    and #SDCARD_DETECT
    rts

;---------------------------------------------------------------------
; Init SD Card
; Destructive: A, X, Y
;
;  out:  Z=1 on success, Z=0 otherwise and A=<error>
;---------------------------------------------------------------------
sdcard_init:
      lda #spi_device_sdcard
      jsr spi_select_device
      beq @init
      rts
@init:
      php
      sei

    ; 74 SPI clock cycles - !!!Note: spi clock cycle should be in range 100-400Khz!!!
      ldx #74

      ; set ALL CS lines and DO to HIGH
      lda #%11111110
      tay
      iny
init_clk:
      sta via1portb
      jsr _sys_delay_4us ; 4µs delay => 250Khz
      sty via1portb
      jsr _sys_delay_4us
      dex
      bne init_clk

      jsr sd_select_card
      bcc @next
      jmp @exit
@next:
      jsr sd_param_init

      ; CMD0 needs CRC7 checksum to be correct
      lda #$95
      sta sd_cmd_chksum

      ldy #sd_cmd_response_retries
@lcmd:
      dey
      bne @l2
      debug "sd_i_cmd0_max_retries"
      jmp @exit
@l2:
      ; send CMD0 - init SD card to SPI mode
      lda #cmd0
      phy
      jsr sd_cmd
      ply
;      debug "CMD0"
:      cmp #$01
      bne @lcmd

      lda #$01
      sta sd_cmd_param+2
      lda #$aa
      sta sd_cmd_param+3
      lda #$87
      sta sd_cmd_chksum


      lda #cmd8
      jsr sd_cmd
      debug32 "CMD8", sd_cmd_param

      jsr sd_param_init
      cmp #$01
      bne @l5
      ; Invalid Card (or card we can't handle yet)
      ; card must respond with $000001aa, otherwise we can't use it
      ;
      ; screw this
      jsr spi_r_byte
      ; and that
      jsr spi_r_byte

      ; is this $01? we're done if not
      jsr spi_r_byte
      cmp #$01
      beq @l3
      jmp @exit
@l3:
;      bne @exit
      ; is this $aa? we're done if not
      jsr spi_r_byte
      cmp #$aa
      bne @exit

      ; init card using ACMD41 and parameter $40000000
      lda #$40
      sta sd_cmd_param
@l5:
      lda #cmd55
      jsr sd_cmd

      cmp #$01
      bne @exit
      ; Init failed

      lda #acmd41
      jsr sd_cmd
      debug32 "ACMD41", sd_cmd_param

      cmp #$00
      beq @l7

      cmp #$01
      beq @l5

      cmp sd_cmd_param
      beq @exit    ; acmd41 with $40000000 and $00000000 failed, TODO: try CMD1

      jsr sd_param_init
      bra @l5

@l7:
      cmp sd_cmd_param
      beq @cmd16    ; acmd41 with $40000000 and $00000000 failed, TODO: try CMD1

      stz sd_cmd_param

      lda #cmd58
      jsr sd_cmd
      ;debug "CMD58"
      ; read result. we need to check bit 30 of a 32bit result
      jsr spi_r_byte
      ;debug "CMD58_r"
    ;  sta krn_tmp
      ;pha
      ; read the other 3 bytes and trash them
    ;  jsr spi_r_byte
    ;  jsr spi_r_byte
    ;  jsr spi_r_byte
      ; or don't read them at all. the next busy_wait will take care of everything

      ;pla
      and #%01000000
      bne @exit_ok
@cmd16:
      jsr sd_param_init

      ; Set block size to 512 bytes
      lda #$02
      sta sd_cmd_param+2

      debug32 "cmd16p", sd_cmd_param

      lda #cmd16
      jsr sd_cmd
      ;debug "CMD16"
@exit_ok:
      lda #0      ; SD card init successful
@exit:
      plp
      cmp #0
      jmp sd_deselect_card

_sys_delay_4us:
      sys_delay_us 4
      rts

;---------------------------------------------------------------------
; Send SD Card Command
; in:
;   A - cmd byte
;   sd_cmd_param - parameters
; out:
;  A - SD Card R1 status byte in
;---------------------------------------------------------------------
sd_cmd:
      pha
      jsr sd_busy_wait
      pla
      debug "sd_cmd"
      ;bcs sd_exit ; from sd_busy_wait
      ; transfer command byte
      jsr spi_rw_byte

      ; transfer parameter buffer
      ldx #$00
@l1:  lda sd_cmd_param,x
      phx
      jsr spi_rw_byte
      plx
      inx
      cpx #$05
      bne @l1

;---------------------------------------------------------------------
; wait for card response for command
; read max. 8 bytes (The response is sent back within command response time (NCR), 0 to 8 bytes for SDC, 1 to 8 bytes for MMC. )
; http://elm-chan.org/docs/mmc/mmc_e.html
; out:
; A - response of card, for error codes see sdcard.inc. $1F if no valid response within NCR
; C = 0 on success, C = 1 on error, A = error code
;---------------------------------------------------------------------
sd_cmd_response_wait:
      ldy #sd_cmd_response_retries
@l:    dey
      beq sd_block_cmd_timeout ; y already 0? then invalid response or timeout
      jsr spi_r_byte
;      debug "sd_cm_wt"
      bmi @l
      debug "sd_cm_wt_e"
      clc
      rts
sd_block_cmd_timeout:
      debug "sd_cm_wtt"
      lda #sd_card_error_timeout_command ; make up error code distinct from possible sd card responses to mark timeout
      sec
sd_exit:
      rts


;---------------------------------------------------------------------
; Read block from SD Card
; in:
;   lba_addr set with lba address to read
;   sd_blkptr target adress for the block data to be read
;
;out:
;  C=1, A = 0 on success, C=0 and A=<error code> otherwise
;---------------------------------------------------------------------
sd_read_block:
      php
      sei

      jsr sd_select_card

      jsr sd_cmd_lba
      lda #cmd17
      jsr sd_cmd
      bne @exit
      jsr fullblock
      jsr sd_deselect_card
@exit:
      plp
      cmp #0
      rts

;---------------------------------------------------------------------
; deselect sd card, puSH CS line to HI and generate few clock cycles
; to allow card to deinit
;---------------------------------------------------------------------
sd_deselect_card:
      pha
      phy

      jsr spi_deselect

      ldy #$04
@l1:
      jsr spi_r_byte
      dey
      bne @l1

      ply
      pla

      rts

fullblock:
      ; wait for sd card data token
      jsr sd_wait
      bne @exit

      ldy #$00
      jsr halfblock
      inc sd_blkptr+1
      jsr halfblock

      jsr spi_r_byte    ; Read 2 CRC bytes
      jsr spi_r_byte
      lda #$00
@exit:
      rts

halfblock:
@l:   jsr spi_r_byte
      sta (sd_blkptr),y
      iny
      bne @l
      rts

;---------------------------------------------------------------------
; wait for sd card whatever
; in: A - value to wait for
; out: Z = 1, A = 0 on success, A = error (timeout) otherwise
;---------------------------------------------------------------------
sd_wait:
      ldy #sd_data_token_retries
      ldx #0
@l1:
      phx
      jsr spi_r_byte
      plx
      cmp #sd_data_token
      beq @l2
      dex
      bne @l1
      dey
      bne @l1

      lda #sd_card_error_timeout
      rts
@l2:  lda #0
      rts


;---------------------------------------------------------------------
; select sd card, pull CS line to low with busy wait
; out:
;   see below
;---------------------------------------------------------------------
sd_select_card:
      lda #spi_device_sdcard
      sta via1portb
      ;TODO FIXME race condition here!

; fall through to sd_busy_wait
;---------------------------------------------------------------------
; wait while sd card is busy
; C = 0 on success, C = 1 on error (timeout)
;---------------------------------------------------------------------
sd_busy_wait:
      ldx #$ff
@l1:  lda #$ff
      dex
      beq @err

      phx
      jsr spi_rw_byte
      plx
      cmp #$ff
      bne @l1
      clc
      rts
@err: lda #sd_card_error_timeout_busy
      sec
      rts

;---------------------------------------------------------------------
; clear sd card parameter buffer
;---------------------------------------------------------------------
sd_param_init:
      ldx #$03
@l:
      stz sd_cmd_param,x
      dex
      bpl @l
      lda #$01
      sta sd_cmd_chksum
      rts

;---------------------------------------------------------------------
; write lba_addr in correct order into sd_cmd_param
; in:
;  lba_addr - LBA address
; out:
;  sd_cmd_param
;---------------------------------------------------------------------
sd_cmd_lba:
      ldx #$03
      ldy #$00
@l:
      lda lba_addr,x
      sta sd_cmd_param,y
      iny
      dex
      bpl @l
      rts
