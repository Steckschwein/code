.include "zeropage.inc"
.include "system.inc"
.include "keyboard.inc"

.export xmodem_upload

.import xmodem_upload_callback
.import xmodem_startaddress

.import uart_tx
.import uart_rx_nowait
.import primm
.import hexout, hexout_s
.import xmodem_rcvbuffer

.zeropage
  ptr:  .res 2    ; data pointer (two byte variable)
  ptrh  = ptr+1   ;   "    "
  bflag:  .res 1 ; block flag

.code
;
;^^^^^^^^^^^^^^^^^^^^^^ Start of Program ^^^^^^^^^^^^^^^^^^^^^^
;
; Xmodem/CRC upload routine
; By Daryl Rictor, July 31, 2002
;
; v0.3  tested good minus CRC
; v0.4  CRC fixed!!! init to $0000 rather than $FFFF as stated
; v0.5  added CRC tables vs. generation at run time
; v 1.0 recode for use with SBC2
; v 1.1 added block 1 masking (block 257 would be corrupted)

; in
; out:
;  C=0 on success, C=1 on any i/o or protocoll related error
.proc xmodem_upload
          lda #1
          sta bflag    ; set flag to get address from block 1
          lda #<_block_rx_dflt
          ldx #>_block_rx_dflt
          jmp xmodem_upload_callback
.endproc


_block_rx_dflt:
          cmp #$01  ; 1st block?
          bne CopyBlk3  ; no, copy all 128 bytes
          lda bflag     ; is it really block 1, not block 257, 513 etc.
          beq CopyBlk3  ; no, copy all 128 bytes
          lda xmodem_rcvbuffer,x   ; get target address from 1st 2 bytes of blk 1
          sta ptr       ; save lo address
          sta xmodem_startaddress
          inx    ;
          lda xmodem_rcvbuffer,x  ; get hi address
          sta ptr+1  ; save it
          sta xmodem_startaddress+1
          jsr hexout_s
          lda xmodem_startaddress
          jsr hexout
          jsr primm
          .asciiz "...     "
          inx         ; point to first byte of data
          dec bflag   ; set the flag so we won't get another address
CopyBlk3: lda xmodem_rcvbuffer,x  ; get data byte from buffer
          sta (ptr)     ; save to target
          inc ptr       ; point to next address
          bne CopyBlk4  ; did it step over page boundary?
          inc ptr+1     ; adjust high address for page crossing
CopyBlk4: inx           ; point to next data byte
          cpx #$82      ; is it the last byte
          bne CopyBlk3  ; no, get the next one

          jsr primm
          .byte KEY_BACKSPACE, KEY_BACKSPACE, KEY_BACKSPACE, KEY_BACKSPACE, KEY_BACKSPACE, 0

          lda ptr+1
          jsr hexout_s
          lda ptr
          jmp hexout