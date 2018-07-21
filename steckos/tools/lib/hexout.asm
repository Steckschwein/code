;
;	hexout a binary number
;
.export hexout

.code

.import char_out

hexout:
		pha
		phx

		tax
		lsr
		lsr
		lsr
		lsr
		jsr hexdigit
		txa
		jsr hexdigit
		plx
		pla
		rts

hexdigit:
		and #%00001111      ;mask lsd for hex print
		ora #'0'            ;add "0"
		cmp #'9'+1          ;is it a decimal digit?
		bcc @l	            ;yes! output it
		adc #6              ;add offset for letter a-f
@l:
		jmp char_out