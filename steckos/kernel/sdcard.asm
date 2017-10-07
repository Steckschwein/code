; enable debug for this module
.ifdef DEBUG_SDCARD
	debug_enabled=1
.endif

.include "common.inc"
.include "kernel.inc"
.include "sdcard.inc"
.include "via.inc"
.segment "KERNEL"
.import spi_rw_byte, spi_r_byte
.export init_sdcard, sd_read_block, sd_read_multiblock, sd_write_block, sd_select_card, sd_deselect_card
.ifdef MULTIBLOCK_WRITE
.export sd_write_multiblock
.endif


;---------------------------------------------------------------------
; Init SD Card
; Destructive: A, X, Y
;---------------------------------------------------------------------
init_sdcard:
	; 80 Taktzyklen
	ldx #74

	; set ALL CS lines and DO to HIGH
	lda #%11111110
	sta via1portb

	tay
	iny

@l1:	sty via1portb
	sta via1portb
	dex
	bne @l1

	jsr sd_select_card

	jsr sd_param_init

	; CMD0 needs CRC7 checksum to be correct
	lda #$95
	sta sd_cmd_chksum

	; send CMD0 - init SD card to SPI mode
	lda #cmd0
	jsr sd_cmd
.ifdef DEBUG_SD_INIT
	debug "CMD0"
.endif
	cmp #$01
	beq @l3

	jmp sd_deselect_card
;	rts

@l3:
	lda #$01
	sta sd_cmd_param+2
	lda #$aa
	sta sd_cmd_param+3
	lda #$87
	sta sd_cmd_chksum


	lda #cmd8
	jsr sd_cmd
.ifdef DEBUG_SD_INIT
	debug "CMD8"
.endif

	cmp #$01
	beq @l5

	; Invalid Card (or card we can't handle yet)
	jmp sd_deselect_card
;	rts

@l5:
	jsr sd_param_init
	lda #cmd55
	jsr sd_cmd

	cmp #$01
	beq @l6

	; Init failed
	jmp sd_deselect_card
;	rts

@l6:

	lda #$40
	sta sd_cmd_param

	lda #acmd41
	jsr sd_cmd
.ifdef DEBUG_SD_INIT
	debug "ACMD41"
.endif

	cmp #$00
	beq @l7

	cmp #$01
	beq @l5

	rts
@l7:

	stz sd_cmd_param

	lda #cmd58
	jsr sd_cmd
.ifdef DEBUG_SD_INIT
	debug "CMD58"
.endif
	; read result. we need to check bit 30 of a 32bit result
	jsr spi_r_byte
;	sta krn_tmp
	;pha
	; read the other 3 bytes and trash them
;	jsr spi_r_byte
;	jsr spi_r_byte
;	jsr spi_r_byte
	; or don't read them at all. the next busy_wait will take care of everything

;@l8:
;	phx
;	jsr spi_r_byte
;	plx
;	sta sd_cmd_result,x
;	inx
;	cpx #$04
;	bne @l8
.import krn_hexout
	jsr krn_hexout
	;pla
	and #%01000000
	bne @l9
;	bit sd_cmd_result+1
;	bit krn_tmp
;	bvs @l9

	jsr sd_param_init

	; Set block size to 512 bytes
	lda #$02
	sta sd_cmd_param+2

	lda #cmd16
	jsr sd_cmd
.ifdef DEBUG_SD_INIT
	debug "CMD16"
.endif

@l9:
	; SD card init successful
	lda #$00
	rts


;---------------------------------------------------------------------
; Send SD Card Command
; in:
; 	A - cmd byte
; 	sd_cmd_param - parameters
; out:
;   A - SD Card R1 status byte in
;---------------------------------------------------------------------
sd_cmd:
		pha
		jsr sd_busy_wait
		pla
		; transfer command byte
		jsr spi_rw_byte

		; transfer parameter buffer
		ldx #$00
@l1: 	lda sd_cmd_param,x
		phx
		jsr spi_rw_byte
		plx
		inx
		cpx #$05
		bne @l1

sd_cmd_response_wait:
		ldy #$08
@l:		dey
		beq sd_block_cmd_timeout ; y already 0? then invalid response or timeout
		jsr spi_r_byte
		bit #80	; bit 7 clear
		bne @l  ; no, next byte
		cmp #$00 ; got cmd response, check if $00 to set z flag accordingly
		rts
sd_block_cmd_timeout:
		lda #$1f ; make up error code distinct from possible sd card responses to mark timeout
		rts


;---------------------------------------------------------------------
; Read block from SD Card
;in:
;	A - sd card cmd byte (cmd17, cmd18, cmd24, cmd25)
;   block lba in lba_addr
;
;out:
;	A - A = 0 on success, error code otherwise
;---------------------------------------------------------------------
sd_read_block:
		jsr sd_select_card

		jsr sd_cmd_lba
		lda #cmd17
		jsr sd_cmd

       	bne @exit
@l1:


		jsr fullblock

@exit: ; fall through to sd_deselect_card

		;---------------------------------------------------------------------
		; deselect sd card, puSH CS line to HI and generate few clock cycles
		; to allow card to deinit
		;---------------------------------------------------------------------
sd_deselect_card:
			pha
			phx
			; set CS line to HI
			lda #%01111110
			sta via1portb

			ldx #$04
@l1:
			phx
			jsr spi_r_byte
			plx
			dex
			bne @l1
			plx
			pla

			rts

fullblock:
		; wait for sd card data token
		lda #sd_data_token
		jsr sd_wait
		bne @exit

		ldy #$00
		jsr halfblock

		inc read_blkptr+1
		jsr halfblock

		jsr spi_r_byte		; Read 2 CRC bytes
		jsr spi_r_byte
		lda #$00
@exit:
		rts

halfblock:
@l:
		jsr spi_r_byte
		sta (read_blkptr),y
		iny
		bne @l
		rts

;---------------------------------------------------------------------
; Read multiple blocks from SD Card
;in:
;	A - sd card cmd byte (cmd17, cmd18, cmd24, cmd25)
;   block lba in lba_addr
;   block count in blocks
;
;out:
;	A - A = 0 on success, error code otherwise
;---------------------------------------------------------------------
sd_read_multiblock:
		phx
		phy

		jsr sd_select_card

		jsr sd_cmd_lba
		lda #cmd18	; Send CMD18 command byte
		jsr sd_cmd
		bne @exit
@l1:

		jsr fullblock
		bne @exit
		inc read_blkptr+1

		dec blocks
		bne @l1

        ; all blocks read, send cmd12 to end transmission
        ; jsr sd_param_init
        lda #cmd12
        jsr sd_cmd

@exit:
        ply
		plx
        jmp sd_deselect_card

;---------------------------------------------------------------------
; Write block to SD Card
;in:
;	A - sd card cmd byte (cmd17, cmd18, cmd24, cmd25)
;   block lba in lba_addr
;
;out:
;	A - A = 0 on success, error code otherwise
;---------------------------------------------------------------------

sd_write_block:
		phx
		phy
		jsr sd_select_card

		jsr sd_cmd_lba
		lda #cmd24
		jsr sd_cmd
	    bne @exit

		lda #sd_data_token
		jsr spi_rw_byte

		ldy #$00
@l2:	lda (write_blkptr),y
		phy
		jsr spi_rw_byte
		ply
		iny
		bne @l2

		inc write_blkptr+1

		ldy #$00
@l3:	lda (write_blkptr),y
		phy
		jsr spi_rw_byte
		ply
		iny
		bne @l3



		; Send fake CRC bytes
		lda #$00
		jsr spi_rw_byte
		lda #$00
		jsr spi_rw_byte
		inc write_blkptr+1
		lda #$00

@exit:
		ply
		plx
        jmp sd_deselect_card

;---------------------------------------------------------------------
; Write multiple blocks to SD Card
;---------------------------------------------------------------------#
.ifdef MULTIBLOCK_WRITE
sd_write_multiblock:
		save

		; TODO
		; 1. make this work
		; 2. use SET_WR_BLOCK_ERASE_COUNT (ACMD23) to pre-erase number of blocks

		jsr sd_select_card

		jsr sd_cmd_lba
		lda #cmd25	; Send CMD25 command byte
		jsr sd_cmd

		; wait for command response.
		lda #$00
		jsr sd_wait
		;jsr sd_wait_timeout
       	bne @exit

@block:
		lda #sd_data_token
		jsr spi_rw_byte

		ldy #$00
@l2:	lda (write_blkptr),y
		phy
		jsr spi_rw_byte
		ply
		iny
		bne @l2

		inc 	write_blkptr+1

		ldy #$00
@l3:	lda (write_blkptr),y
		phy
		jsr spi_rw_byte
		ply
		iny
		bne @l3

		; Send fake CRC bytes
		lda #$00
		jsr spi_rw_byte
		lda #$00
		jsr spi_rw_byte

		inc write_blkptr+1


		dec blocks
		bne @block

        ; all blocks read, send cmd12 to end transmission
        ; jsr sd_param_init
        lda #cmd12
        jsr sd_cmd

;        jsr sd_busy_wait

@exit:
		restore
		jmp sd_deselect_card
.endif

;---------------------------------------------------------------------
; wait for sd card whatever
; in: A - value to wait for
; out: Z = 1, A = 1 when error (timeout)
;---------------------------------------------------------------------
sd_wait:
		sta sd_tmp
		ldy #sd_data_token_retries
		stz	krn_tmp				; use krn_tmp as loop var, not needed here
@l1:
		jsr spi_r_byte
		cmp sd_tmp
		beq @l2
		dec	krn_tmp
		bne	@l1
		dey
		bne @l1

		lda #$01
		rts
@l2:	lda #$00
		rts


;---------------------------------------------------------------------
; select sd card, pull CS line to low
;---------------------------------------------------------------------
sd_select_card:
		lda #sd_card_sel
		sta via1portb
; fall through to sd_busy_wait
;---------------------------------------------------------------------
; wait while sd card is busy
; Z = 1, A = 1 when error (timeout)
;---------------------------------------------------------------------
sd_busy_wait:
@l1:    lda #$ff
        jsr spi_rw_byte
        cmp #$ff
        bne @l1

		lda #$01
		rts
@l2:	lda #$00
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
;	lba_addr - LBA address
; out:
;   sd_cmd_param
;---------------------------------------------------------------------
sd_cmd_lba:
		ldx #$03
		ldy #$00
@l:
		debug "cmd_lba"
		lda lba_addr,x
		sta sd_cmd_param,y
		iny
		dex
		bpl @l
		rts
