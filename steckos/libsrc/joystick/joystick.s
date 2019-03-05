.include "joystick.inc"
.include "via.inc"

.export read_joystick
.export joystick_read
.export joystick_on
.export joystick_detect


;
;   in:
;       .A - joystick to read either JOY_PORT1 or JOY_PORT2
;            @see use joystick.inc
;   out: 
;       .A - joystick buttons
;
joystick_read:
read_joystick:
        and #$80            ;select joy port
        sta	via1porta
        lda	via1porta		    ;read port input
        rts

joystick_on:
        lda #%11111011
        and uart1mcr
        sta uart1mcr
        ;Port A directions
        lda #%11000000 		; via port A - set PA7,6 to output (joystick port select), PA1-5 to input (directions)
        sta via1ddra
        rts
        
;   in: -
;   out:
;       .A - Z=0 no joystick detected, Z=1 and A=1 joystick port 1 or A=2 joystick port 2
joystick_detect:
        lda #JOY_PORT1
        jsr read_joystick
        