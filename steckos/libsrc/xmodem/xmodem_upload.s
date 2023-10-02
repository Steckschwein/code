.include "zeropage.inc"
.include "system.inc"
.include "keyboard.inc"

.export xmodem_upload_callback

.import uart_tx
.import uart_rx_nowait
.import crc16_init
.import crc16_lo, crc16_hi
.import primm
.import xmodem_rcvbuffer
.import xmodem_startaddress

; XMODEM/CRC Receiver for the 65C02
;
; By Daryl Rictor & Ross Archer  Aug 2002
;
; 21st century code for 20th century CPUs (tm?)
;
; A simple file transfer program to allow upload from a console device
; to the SBC utilizing the x-modem/CRC transfer protocol.  Requires just
; under 1k of either RAM or ROM, 132 bytes of RAM for the receive buffer,
; and 8 bytes of zero page RAM for variable storage.
;
;**************************************************************************
; This implementation of XMODEM/CRC does NOT conform strictly to the
; XMODEM protocol standard in that it (1) does not accurately time character
; reception or (2) fall back to the Checksum mode.

; (1) For timing, it uses a crude timing loop to provide approximate
; delays.  These have been calibrated against a 1MHz CPU clock.  I have
; found that CPU clock speed of up to 5MHz also work but may not in
; every case.  Windows HyperTerminal worked quite well at both speeds!
;
; (2) Most modern terminal programs support XMODEM/CRC which can detect a
; wider range of transmission errors so the fallback to the simple checksum
; calculation was not implemented to save space.
;**************************************************************************
;
; Files uploaded via XMODEM-CRC must be
; in .o64 format -- the first two bytes are the load address in
; little-endian format:
;  FIRST BLOCK
;     offset(0) = lo(load start address),
;     offset(1) = hi(load start address)
;     offset(2) = data byte (0)
;     offset(n) = data byte (n-2)
;
; Subsequent blocks
;     offset(n) = data byte (n)
;
; The TASS assembler and most Commodore 64-based tools generate this
; data format automatically and you can transfer their .obj/.o64 output
; file directly.
;
; The only time you need to do anything special is if you have
; a raw memory image file (say you want to load a data
; table into memory). For XMODEM you'll have to
; "insert" the start address bytes to the front of the file.
; Otherwise, XMODEM would have no idea where to start putting
; the data.

;-------------------------- The Code ----------------------------
;
; zero page variables (adjust these to suit your needs)
;
;
.zeropage
crc:  .res 2  ; CRC lo byte  (two byte variable)
crch  = crc+1  ; CRC hi byte

blkno:  .res 1 ; block number
retry:  .res 1 ; retry counter
retry2:  .res 1 ; 2nd counter

block_rx: .res 2 ;

;
;
;
; non-zero page variables and buffers
;
;
Rbuff=xmodem_rcvbuffer      ; temp 132 byte receive buffer ;(place anywhere, page aligned)
;
;
;  tables and constants
;
;
; The crclo & crchi labels are used to point to a lookup table to calculate
; the CRC for the 128 byte data blocks.  There are two implementations of these
; tables.  One is to use the tables included (defined towards the end of this
; file) and the other is to build them at run-time.  If building at run-time,
; then these two labels will need to be un-commented and declared in RAM.
;
;crclo  = $7D00       ; Two 256-byte tables for quick lookup
;crchi  =  $7E00       ; (should be page-aligned for speed)
;
;
;
; XMODEM Control Character Constants
SOH  = $01  ; start block
EOT  = $04  ; end of text marker
ACK  = $06  ; good block acknowledged
NAK  = $15  ; bad block acknowledged
CAN  = $18  ; cancel (not standard, not supported)
CR  = $0d  ; carriage return
LF  = $0a  ; line feed
ESC  = $1b  ; ESC to exit

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
;   .A/.X pointer to block rcv callback
; out:
;  C=0 on success, C=1 on any i/o or protocoll related error
.proc xmodem_upload_callback
          sta block_rx+0
          stx block_rx+1

          jsr crc16_init

          jsr primm
          .byte "XMODEM upload... ", 0

          lda #$01
          sta blkno    ; set block # to 1
StartCrc: lda #'C' ; "C" start with CRC mode
          jsr Put_Chr  ; send it
          lda #$FF
          sta retry2  ; set loop counter for ~3 sec delay
          stz crc
          stz crch      ; init CRC value
          jsr GetByte   ; wait for input
          bcs GotByte   ; byte received, process it
          bcc StartCrc  ; resend "C"

StartBlk:lda #$FF ;
          sta retry2   ; set loop counter for ~3 sec delay
          stz crc      ;
          stz crch     ; init CRC value
          jsr GetByte  ; get first byte of block
          bcc StartBlk ; timed out, keep waiting...
GotByte:
          cmp #SOH    ; start of block?
          beq BegBlk  ; yes
          cmp #EOT    ;
          bne BadCrc  ; Not SOH or EOT, so flush buffer & send NAK
Done:                 ; EOT - all done!
          lda #ACK      ; last block, send ACK and exit.
          jsr Put_Chr   ;
          jmp Flush     ; get leftover characters, if any
          ; exit, C=0
BegBlk:   ldx #$00
GetBlk:   lda #$ff    ; 3 sec window to receive characters
          sta retry2  ;
GetBlk1:  jsr GetByte  ; get next character
          bcc BadCrc  ; chr rcv error, flush and send NAK
GetBlk2:  sta Rbuff,x  ; good char, save it in the rcv buffer
          inx        ; inc buffer pointer
          cpx #$84    ; <01> <FE> <128 bytes> <CRCH> <CRCL>
          bne GetBlk  ; get 132 characters
          ldx #$00    ;
          lda Rbuff,x  ; get block # from buffer
          cmp blkno    ; compare to expected block #
          beq GoodBlk1  ; matched!
err_exit:
          jsr Flush  ; mismatched - flush buffer and then exit
          ; unexpected block # - fatal error - RTS
          ; lda #$FD ; put error code in "A" if desired
          sec
          rts

GoodBlk1: eor #$ff    ; 1's comp of block #
          inx        ;
          cmp Rbuff,x  ; compare with expected 1's comp of block #
          bne err_exit  ; err, no match!

GoodBlk2: ldy #$02  ;
CalcCrc:  lda Rbuff,y  ; calculate the CRC for the 128 bytes of data

UpdCrc:  eor  crc+1  ; Quick CRC computation with lookup tables
          tax        ; updates the two bytes at crc & crc+1
          lda  crc   ; with the byte send in the "A" register
          eor  crc16_hi,x
          sta  crc+1
          lda  crc16_lo,x
          sta  crc

          iny        ;
          cpy #$80+2  ; 2+128 bytes
          bne CalcCrc  ;
          lda Rbuff,y  ; get hi CRC from buffer
          cmp crch  ; compare to calculated hi CRC
          bne BadCrc  ; bad crc, send NAK
          iny   ;
          lda Rbuff,y  ; get lo CRC from buffer
          cmp crc   ; compare to calculated lo CRC
          beq GoodCrc  ; good CRC
BadCrc:   jsr Flush  ; flush the input port
          lda #NAK  ;
          jsr Put_Chr  ; send NAK to resend block
          bra StartBlk ; start over, get the block again
GoodCrc:  ldx #$02  ;
          lda blkno  ; get the block number
          jsr _block_rx
IncBlk:   inc blkno  ; done.  Inc the block #
          lda #ACK  ; send ACK
          jsr Put_Chr  ;
          jmp StartBlk ; get next block
_block_rx:
          jmp (block_rx)
.endproc

;
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;
; subroutines
;
;
Flush:    lda #$70  ; flush receive buffer
          sta retry2  ; flush until empty for ~1 sec.
          jsr GetByte  ; read the port
          bcs Flush  ; if chr recvd, wait for another
          rts    ; else done

GetByte: stz retry  ; set low value of timing loop
StartCrcLp:
          jsr Get_Chr  ; get chr from serial port, don't wait
          bcs exit  ; got one, so exit
          dec retry  ; no character received, so dec counter
          bne StartCrcLp ;
          dec retry2  ; dec hi byte of counter
          bne StartCrcLp ; look for character again
          clc    ; if loop times out, CLC, else SEC and return
exit:     rts    ; with character in "A"

;
;======================================================================
;  I/O Device Specific Routines
;
;  Two routines are used to communicate with the I/O device.
;
; "Get_Chr" routine will scan the input port for a character.  It will
; return without waiting with the Carry flag CLEAR if no character is
; present or return with the Carry flag SET and the character in the "A"
; register if one was present.
;
; "Put_Chr" routine will write one byte to the output port.  Its alright
; if this routine waits for the port to be ready.  its assumed that the
; character was send upon return from this routine.
;
;
Get_Chr=uart_rx_nowait
;
;
; output to OutPut Port
;
Put_Chr=uart_tx
;
;
; End of File
;
