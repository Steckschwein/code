.setcpu "65c02"
.include "pacman.inc"


; Der  Vektor in FFFE/F ruft erst mal im original Junior Monitor einen indirekten Sprung zu IRQVECT = 1A7E/F auf.
; Da liegt der 1/60 Sekunden Interrupt. Von hier aus wird dann erst IRQUSR aufgerufen. Wenn du es schnell brauchst, dann ersetzt du also IRQVECT.
; Der original Vektor sollte nach Beendigung von Pacman aber wieder hergestellt werden.
;
IRQVECT         = $1a7e
;IRQVECT         = $1f32

TAPE_OFF        = $EFCC

FGC_BASE        = $1000
VPU_BASE        = FGC_BASE + $08            ; VPU access starts from FGBASE + offset $08


; Video Processing Unit Ports

VPU_PORT0       =     VPU_BASE
VPU_PORT1       =     VPU_BASE+1
VPU_PORT2       =     VPU_BASE+2
VPU_PORT3       =     VPU_BASE+3

; **** Read Joystick Port ******************************************************
;
; Output: A - button state (Bit 0 = Button 1, Bit 1 = Button 2, Bit 2 = Button 3)
;         X - horizontal joystick position 0 = Center, -1 ($FF) = Left, 1 = Right
;         Y - vertical joystick position 0 = Center, -1 ($FF) = Up, 1 = Down
;         C - 0 = No joystick port available; 1 = Joystick port available
;
; ******************************************************************************

READ_JOYSTICK	=	$E1B9

KEY_CRSR_RIGHT=0 ; TODO
KEY_CRSR_LEFT=0 ; TODO
KEY_CRSR_DOWN=0 ; TODO
KEY_CRSR_UP=0 ; TODO