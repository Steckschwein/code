
.export crc16_table_init
.import crc16_lo, crc16_hi

; Alternate solution is to build the two lookup tables at run-time.  This might
; be desirable if the program is running from ram to reduce binary upload time.
; The following code generates the data for the lookup tables.  You would need to
; un-comment the variable declarations for crc16_lo & crc16_hi in the Tables and Constants
; section above and call this routine to build the tables before calling the
; "xmodem" routine.
;
crc16_table_init:
		ldx #$00
:		stz crc16_lo,x
		stz crc16_hi,x
		inx
		bne	:-
fetch:	txa
		eor	crc16_hi,x
		sta	crc16_hi,x
		ldy	#$08
fetch1:	asl	crc16_lo,x
		rol	crc16_hi,x
		bcc	fetch2
		lda	crc16_hi,x
		eor	#$10
		sta	crc16_hi,x
		lda	crc16_lo,x
		eor	#$21
		sta	crc16_lo,x
fetch2:	dey
		bne	fetch1
		inx
		bne	fetch
		rts