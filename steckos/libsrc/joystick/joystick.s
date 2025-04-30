.include "joystick.inc"
.include "uart.inc"
.include "via.inc"

.export read_joystick
.export joystick_read
.export joystick_on
.export joystick_off
.export joystick_detect

;@module: joystick
;
;  in:
;     A - joystick to read either JOY_PORT1 or JOY_PORT2
;        @see joystick.inc
;  out:
;     A - joystick buttons - bit 0-4
;@name: "joystick_read"
;in: A, "joystick to read, JOY_PORT1 or JOY_PORT2, see joystick.inc"
;@out: A, "joystick button state - bit 0-4"
;@desc: "read state of specified joystick"
joystick_read:
read_joystick:
      and #$80        ;select joy port
_read:
      sta via1porta
      lda via1porta    ;read port input
      and #%00011111
      rts

;@name: "joystick_on"
;@desc: joystick on - set via ports and enables joystick on uart port
joystick_on:
      lda #<~(uart_mcr_out1)
      and uart1+uart_mcr
      sta uart1+uart_mcr
      ;Port A directions
      lda #%11000000     ; via port A - set PA7,6 to output (joystick port select), PA1-5 to input (directions)
      sta via1ddra
      rts

;@name: "joystick_off"
;@desc: joystick off - reset via ports and disables joystick enable on uart port
;
joystick_off:
      lda #uart_mcr_out1
      and uart1+uart_mcr
      sta uart1+uart_mcr
      lda #%11111111     ; via port A - set PA7,6 to output (joystick port select), PA1-5 to input (directions)
      sta via1ddra
      rts


;  in: -
;  out:
;     .A - Z=1 no joystick detected, Z=0 and A=JOY_PORT1 joystick port 1 or A=JOY_PORT2 joystick port 2

;@name: "joystick_detect"
;@out: C, "C=1 no joystick detected, C=0 joystick detected, port in A"
;@out: A, "detected joystick port, JOY_PORT1 or JOY_PORT2"
;@desc: "detect joystick"
joystick_detect:
      lda #JOY_PORT1
      jsr _detect
      bcs @detect_port2
      lda #JOY_PORT1
      rts
@detect_port2:
      lda #JOY_PORT2
      jsr _detect
      bcs @exit
      lda #JOY_PORT2
@exit:
      rts

_detect:
      sta  via1porta
      lda  via1porta       ;read port input
      and #(JOY_UP | JOY_DOWN | JOY_LEFT | JOY_RIGHT | JOY_FIRE)
      cmp #(JOY_UP | JOY_DOWN | JOY_LEFT | JOY_RIGHT | JOY_FIRE)
      rts
