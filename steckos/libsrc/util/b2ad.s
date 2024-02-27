
.export b2ad
.import char_out
;@module: util
.code
; A to 2 digit ASCII
;@name: "b2ad"
;@in: A, "value to output"
;@desc: "output 8bit value as 2 digit decimal"
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