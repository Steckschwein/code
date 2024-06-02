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
;@module: sdcard

; enable debug for this module
.ifdef DEBUG_SDCARD
  debug_enabled=1
.endif

.include "system.inc"
.include "common.inc"
.include "zeropage.inc"
.include "errno.inc"
.include "sdcard.inc"
.include "spi65.inc"
.include "via.inc"
.include "debug.inc"

SD_STUFF_BYTE = $ff 


.code
.import spi65_tx_byte, spi65_select_device, spi65_deselect

.export sdcard_init, sdcard_detect
.export sd_select_card, sd_deselect_card
.export sd_read_block, sd_cmd, sd_cmd_lba
.export sd_busy_wait

.export _sd_fullblock

.ifdef MULTIBLOCK_WRITE
.export sd_write_multiblock
.endif


;  out:
;    Z=1 sd card available, Z=0 otherwise A=ENODEV
sdcard_detect:
    lda #0
    rts


;---------------------------------------------------------------------
;@name: "_sdcard_spi_mode"
;@clobbers: A,X,Y
;@desc: "initialize sd card in SPI mode by sending 80 clock cycles to the deselcted card with MOSI=1"
_sdcard_spi_mode:
;     ; 74 SPI clock cycles - !!!Note: spi clock cycle should be in range 100-400Khz!!!
;       ldx #74

;       ; set ALL CS lines and DO to HIGH
;       lda #%11111110
;       tay
;       iny
; init_clk:
;       sta via1portb
;       jsr _sys_delay_4us ; 4µs delay => 250Khz
;       sty via1portb
;       jsr _sys_delay_4us
;       dex
;       bne init_clk
      jsr     spi65_deselect
      ldy     #10
:  
      phy
      lda     #SD_STUFF_BYTE
      jsr     spi65_tx_byte
      ply
      dey
      bne :-
      rts

;---------------------------------------------------------------------
;@name: "_sdcard_reset"
;@clobbers: A,X,Y
;@desc: "reset SD card by sending CMD0"
;@out: C,"0 on success, 1 on error"
_sdcard_reset:
      jsr sd_param_init

      ; CMD0 needs CRC7 checksum to be correct
      lda #$95
      sta sd_cmd_chksum

      ldy #sd_cmd_response_retries
@lcmd:
      dey
      bne @l2
      debug "sd_i_cmd0_max_retries"
      sec
      rts
@l2:
      ; send CMD0 - init SD card to SPI mode
      lda #cmd0
      phy
      jsr sd_cmd
      ply
;      debug "CMD0"
      cmp #$01
      bne @lcmd

      clc
      rts


;---------------------------------------------------------------------
;@name: "_sdcard_check_v2"
;@clobbers: A,X,Y
;@desc: "check voltage range of sd card by sending CMD8"
;@out: C,"0 on success, 1 on error"
;@out: A,"$AA on success"
_sdcard_check_v2:
      jsr sd_param_init
      
      lda #$01
      sta sd_cmd_param+2
      lda #$aa
      sta sd_cmd_param+3
      lda #$87
      sta sd_cmd_chksum

      lda #cmd8
      jsr sd_cmd
      debug32 "CMD8", sd_cmd_param

      cmp #$01
      bne @error
      ; Invalid Card (or card we can't handle yet)
      ; card must respond with $000001aa, otherwise we can't use it
      ;
      ; screw this
      lda     #SD_STUFF_BYTE
      jsr     spi65_tx_byte
      ; and that
      lda     #SD_STUFF_BYTE
      jsr     spi65_tx_byte

      ; is this $01? we're done if not
      lda     #SD_STUFF_BYTE
      jsr     spi65_tx_byte
      cmp #$01
      bne @error
@l3:
;      bne @exit
      ; is this $aa? we're done if not
      lda     #SD_STUFF_BYTE
      jsr     spi65_tx_byte

      cmp #$aa
      bne @error
      clc 
      rts
@error:
      sec 
      rts 

;---------------------------------------------------------------------
;@name: "_sdcard_init_acmd41"
;@clobbers: A,X,Y
;@desc: "initiate sd card init process using ACMD41"
;@out: C,"0 on success, 1 on error"
;@out: A,"$00 on success"
_sdcard_init_acmd41:
      jsr sd_param_init

      ; try to init card using ACMD41 and parameter $40000000
      ; assuming we are dealing with a modern V2 SD card
      lda #$40
      sta sd_cmd_param
@send_acmd41:
      lda #cmd55
      jsr sd_cmd

      cmp #$01
      bne @error
      ; Init failed

      lda #acmd41
      jsr sd_cmd
      debug32 "ACMD41", sd_cmd_param

      ; R1 response == $00? we are successful
      cmp #$00
      beq @ok
      
      ; R1 response == $01? then repeat
      cmp #$01
      beq @send_acmd41

      ; something else happened. maybe old V1 sd card?
      ; retry ACMD41 with $00000000
      jsr sd_param_init
      bra @send_acmd41

@error:
      sec
      rts
@ok:
      lda #0
      clc 
      rts

;---------------------------------------------------------------------
;@name: "_sdcard_check_sdhc"
;@clobbers: A,X,Y
;@desc: "read SD card OCR register and check for bit 30"
;@out: C,"0 on success, 1 on error"
;@out: A,"$00 if SDHC, $01 if not sdhc"
_sdcard_check_sdhc:
      jsr sd_param_init

      lda #cmd58
      jsr sd_cmd
      ;debug "CMD58"
      ; read result. we need to check bit 30 of a 32bit result
      lda #SD_STUFF_BYTE
      jsr spi65_tx_byte

      and #%01000000
      bne @is_sdhc 
      beq @not_sdhc

      sec 
      rts

@not_sdhc:
      lda #1
      clc 
      rts

@is_sdhc:
      lda #0
      clc 
      rts 

;---------------------------------------------------------------------
;@name: "_sdcard_set_blocksize"
;@clobbers: A,X,Y
;@desc: "set card to 512byte block size. not needed on SDHC cards and above"
;@out: C,"0 on success, 1 on error"
;@out: A,"$00 on success"
_sdcard_set_blocksize:
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
      clc
      rts


;---------------------------------------------------------------------
; Init SD Card
; Destructive: A, X, Y
;
;  out:  Z=1 on success, Z=0 otherwise and A=<error>
;---------------------------------------------------------------------
;@name: "sdcard_init"
;@out: Z,"1 on success, 0 on error"
;@out: A, "error code"
;@clobbers: A,X,Y
;@desc: "initialize sd card in SPI mode"
sdcard_init:
      
      php
      sei

      jsr _sdcard_spi_mode

      jsr sd_select_card
      bcs @exit

      jsr _sdcard_reset
      bcs @exit


      jsr _sdcard_check_v2
      bcs @exit 

      jsr _sdcard_init_acmd41
      bcs @exit 

      jsr _sdcard_check_sdhc
      ; not an SDHC card? then skip setting sector size
      beq @exit
      bcs @exit

      jsr _sdcard_set_blocksize
      bcs @exit

      lda #0

@exit:
      plp
      jmp sd_deselect_card


;---------------------------------------------------------------------
; Send SD Card Command
; in:
;   A - cmd byte
;   sd_cmd_param - parameters
; out:
;  A - SD Card R1 status byte in
;---------------------------------------------------------------------
;@name: "sd_cmd"
;@in: A, "command byte"
;@in: sd_cmd_param, "command parameters"
;@out: A, "SD Card R1 status byte"
;@clobbers: A,X,Y
;@desc: "send command to sd card"
sd_cmd:
      pha
      jsr sd_busy_wait
      pla
      debug "sd_cmd"
      ;bcs sd_exit ; from sd_busy_wait
      ; transfer command byte
      jsr spi65_tx_byte

      ; transfer parameter buffer
      ldx #$00
@l1:  lda sd_cmd_param,x
      phx
      jsr spi65_tx_byte
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
@l:   dey
      beq sd_block_cmd_timeout ; y already 0? then invalid response or timeout
      lda #$ff
      jsr spi65_tx_byte
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
;  C = 0 on success, C = 1 and A=<error code> otherwise
;---------------------------------------------------------------------
;@name: "sd_read_block"
;@in: lba_addr, "LBA address of block"
;@in: sd_blkptr, "target adress for the block data to be read"
;@out: A, "error code"
;@out: C, "0 - success, 1 - error"
;@clobbers: A,X,Y
;@desc: "Read block from SD Card"
sd_read_block:
      php
      sei

      jsr sd_select_card

      jsr sd_cmd_lba
 
      lda #cmd17
      jsr sd_cmd
      bne @exit
 
      jsr _sd_fullblock
 @exit:
      plp ; restore IRQ bit

;---------------------------------------------------------------------
; deselect sd card, puSH CS line to HI and generate few clock cycles
; to allow card to deinit
; in:
;   A = return code
; out:
;   C = 0 on success, C = 1 on error with A =<error code>
;---------------------------------------------------------------------
;@name: "sd_deselect_card"
;@out: A, "error code"
;@out: C, "0 - success, 1 - error"
;@clobbers: X
;@desc: "Read block from SD Card"
sd_deselect_card:
      pha
      phy

      jsr spi65_deselect

      ldy #clockspeed<<1 ; faster system, longer de-select
@l1:  jsr spi65_tx_byte
      dey
      bne @l1

      ply
      pla

      cmp #0
      bne @error
      clc
      rts
@error:
      debug "sd_des err"
      sec
      rts


_sd_fullblock:
      ; wait for sd card data token
      jsr sd_wait
      bcs @exit
      
      ; lda #FRX
      ; ora spi65_status
      ; sta spi65_ctrl
 

      ldy #$00     
      jsr halfblock
      inc sd_blkptr+1

      jsr halfblock
      dec sd_blkptr+1

      ; lda #<~FRX
      ; and spi65_status
      ; sta spi65_ctrl

      lda #$ff
      jsr spi65_tx_byte    ; Read 2 CRC bytes
      lda #$ff
      jsr spi65_tx_byte

 
      lda #0
@exit:
      rts

halfblock:
@l:   
      lda #$ff
      jsr spi65_tx_byte
      sta (sd_blkptr),y
      iny
      bne @l

      rts

;---------------------------------------------------------------------
; wait for sd card whatever
; in: A - value to wait for
; out: C = 0 on success, C = 1 and A = error (timeout) otherwise
;---------------------------------------------------------------------

sd_wait:
      ldy #sd_data_token_retries
      ldx #0
@l1:
      phx
      lda #$ff
      jsr spi65_tx_byte
      plx
      cmp #sd_data_token
      beq @l2
      dex
      bne @l1
      dey
      bne @l1

      lda #sd_card_error_timeout
      sec
      rts
@l2:  clc
      rts


;---------------------------------------------------------------------
; select sd card, pull CS line to low with busy wait
; out:
;   see below
;---------------------------------------------------------------------
;@name: "sd_select_card"
;@out: C, "C = 0 on success, C = 1 on error (timeout)"
;@clobbers: A,X,Y
;@desc: "select sd card, pull CS line to low with busy wait"
sd_select_card:
      lda #spi65_device_sdcard
      jsr spi65_select_device
      ;TODO FIXME race condition here!

; fall through to sd_busy_wait
;---------------------------------------------------------------------
; wait while sd card is busy
; C = 0 on success, C = 1 on error (timeout)
;---------------------------------------------------------------------
;@name: "sd_busy_wait"
;@out: C, "C = 0 on success, C = 1 on error (timeout)"
;@clobbers: A,X,Y
;@desc: "wait while sd card is busy"
sd_busy_wait:
      ldx #$ff
@l1:  lda #$ff
      dex
      beq @err

      phx
      jsr spi65_tx_byte
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
