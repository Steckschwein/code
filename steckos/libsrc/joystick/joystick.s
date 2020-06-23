.include "joystick.inc"
.include "via.inc"

.export read_joystick
.export joystick_read
.export joystick_on
.export joystick_detect


;
;	in:
;		 A - joystick to read either JOY_PORT1 or JOY_PORT2
;				@see joystick.inc
;	out:
;		 A - joystick buttons
;
joystick_read:
read_joystick:
		  and #$80				;select joy port
_read:
		  sta via1porta
		  lda via1porta		;read port input
		  rts

;		 joystick on, set via ports and enables joystick via uart port
;
joystick_on:
		  lda #%11111011
		  and uart1mcr
		  sta uart1mcr
		  ;Port A directions
		  lda #%11000000 		; via port A - set PA7,6 to output (joystick port select), PA1-5 to input (directions)
		  sta via1ddra
		  rts

;	in: -
;	out:
;		 .A - Z=1 no joystick detected, Z=0 and A=JOY_PORT1 joystick port 1 or A=JOY_PORT2 joystick port 2
joystick_detect:
		  lda #JOY_PORT1
		  jsr _detect
		  beq @detect_port2
		  lda #JOY_PORT1
		  rts
@detect_port2:
		  lda #JOY_PORT2
		  jsr _detect
		  beq @exit
		  lda #JOY_PORT2
@exit:
		  rts

_detect:
		  sta	via1porta
		  lda	via1porta			 ;read port input
		  and #(JOY_UP | JOY_DOWN | JOY_LEFT | JOY_RIGHT | JOY_FIRE)
		  cmp #(JOY_UP | JOY_DOWN | JOY_LEFT | JOY_RIGHT | JOY_FIRE)
		  rts
