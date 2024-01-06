
.export b2ad
.import char_out

.code
; A to 2 digit ASCII
b2ad:		
		phx
		ldx #$00
@c10:		
		cmp #10
		bcc @out2
		sbc #10
		inx
		bra @c10
@out2:
		pha
		txa
		adc #$30
		jsr char_out
		pla
		clc
		adc #$30
		jsr char_out
		plx
		rts