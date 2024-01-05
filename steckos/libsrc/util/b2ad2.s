
.export b2ad, b2ad2
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
		jsr putout
		clc
		adc #$30
		jsr char_out
		plx
		rts

putout:
		pha
		txa
		adc #$30
		jsr char_out
		pla
		rts

; A to 3 digit ASCII
b2ad2:
		phx
		ldx #$00
@c100:
		cmp #100
		bcc @out1
		sbc #100
		inx
		bra @c100
@out1:
		jsr putout
		ldx #$00
@c10:		
		cmp #10
		bcc @out2
		sbc #10
		inx
		bra @c10
@out2:	
		jsr putout
		clc
		adc #$30
		jsr char_out
		plx
		rts