;i/o
		.include "pacman.c64.inc"

		.export io_init
		.export io_detect_joystick
		.export io_joystick_read
		.export io_player_direction
		.export io_getkey
		.export io_isr
		.export io_irq_on
		.export io_exit

.code
io_init:
		rts

io_irq_on:
		lda #LORAM | IOEN ;disable kernel rom to setup irq
		sta $01			  	;PLA

		lda #%01111111
		sta CIA1_ICR
		and VIC_CTRL1	; clear bit 7 (high byte raster line)
		sta VIC_CTRL1	; $d011
		lda #%00000001
		sta VIC_IMR
		lda #250			;
		sta VIC_HLINE	; Raster-IRQ at bottom border
		rts

io_exit:
		rts

io_isr:
		lda VIC_IRR	; vic irq ?
		bpl @rts
		inc VIC_IRR
		lda CIA1_ICR
		lda #$80	 ;bit 7 to signal video irq
@rts:
		rts


io_player_direction:
		rts

io_getkey:
		;map c64 keys to ascii

		rts

io_detect_joystick:
		lda #2
		rts

io_joystick_read:
		rts
