
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/via.inc"
.include "../steckos/asminc/common.inc"
.include "../steckos/asminc/joystick.inc"

.include "../steckos/asminc/appstart.inc"

.include "lcd.inc"



.import hexout

	appstart $1000


	jsr lcd_init_4bit

	ldx #$00
@l:
	lda chars,x
	beq @next
	jsr lcd_send_byte
	jsr delay_40us
	inx
	bne @l

@next:
	; set address to next row
	clear_bit LCD_RS, via1porta
	lda #$c0
	jsr lcd_send_byte
	set_bit LCD_RS, via1porta
	jsr delay_40us

	ldx #$0f
@l2:
	lda chars,x
	beq @end
	jsr lcd_send_byte
	jsr delay_40us
	dex
	bpl @l2


@end:
	;jmp (retvec)
	jmp krn_upload

chars:
	.byte "1234567812345678",$00


; init lcd to 4bit mode
lcd_init_4bit:

	joy_off

	lda #$ff
	sta via1ddra

	lda #$00
	sta via1porta

	ldx #$00
@l:
	lda @init_bytes,x
	beq @part2
	sta via1porta
	jsr pulse_clock
	jsr delay_40us
	inx
	bne @l

@part2:

	ldx #$00
@l2:
	lda @init_bytes2,x
	beq @end
	jsr lcd_send_byte
	jsr delay_40us
	inx
	bne @l2

@end:
	set_bit LCD_RS, via1porta
	jmp delay
	;rts

@init_bytes:
	.byte $30, $30, $30, $20, $00
@init_bytes2:
	.byte $28, $0e, $80, $01, $00


lcd_send_byte:
	phx
	tax

	lda via1porta
	and #$0f
	sta via1porta

	txa
	and #$f0
	ora via1porta
	sta via1porta
	jsr pulse_clock

	lda via1porta
	and #$0f
	sta via1porta



	txa

	asl
	asl
	asl
	asl

	ora via1porta
	sta via1porta
	jsr pulse_clock
	plx
	rts

pulse_clock:
	inc via1porta
	nop
	nop
	dec via1porta

	rts

delay_40us:

	ldy #40
@l:
			; 1cl = 125ns
	nop 	;2cl = 250ns
	nop 	;2cl = 250ns
	dey 	;2cl = 250ns
	bne @l
			;2cl = 250ns
			;      1000ns = 1us
	rts

delay:
	phy
	phx
	ldy #4
@loop2:
	ldx #250
@loop1:
	.repeat 5
	nop
	.endrepeat

	dex
	bne @loop1
	dey
	bne @loop2
	plx
	ply
	rts
