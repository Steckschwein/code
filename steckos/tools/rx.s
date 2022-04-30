.include "steckos.inc"
.include "zeropage.inc"
.import hexout
.import xmodem_upload
.import crc16_table_init

.export char_out=krn_chrout
.export crc16_lo=BUFFER_0
.export crc16_hi=BUFFER_1
.export crc16_init=crc16_table_init
.export xmodem_rcvbuffer=BUFFER_2
.export xmodem_startaddress=startaddr

appstart $c000

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

.code
XModem:
			jsr krn_primm
Msg:		.byte	"Begin XMODEM/CRC transfer.", CODE_LF, 0

			jsr xmodem_upload
			bcs Print_Err
			jmp (startaddr)

			; no check (carry) required, if we return here then "something" went wrong
Print_Err:	jsr krn_primm
ErrMsg:		.byte 	"Upload Error!", CODE_LF, 0
			jmp (retvec)
			
.bss
startaddr:	.res 2