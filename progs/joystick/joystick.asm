.setcpu "65c02"

.include "joystick.inc"
.include "keyboard.inc"
.include "system.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"

.autoimport

.export char_out=krn_chrout

appstart $1000

    jsr primm
    .byte 27,"[2JESC to Quit",CODE_LF,0

    jsr joystick_on
none:
    jsr primm
    .byte "         ",0
setcrs:
    jsr primm
    .byte 27,"[9C",0
loop:
    jsr krn_getkey
    cmp #KEY_ESCAPE
    beq exit
		jsr joystick_detect
		sta joystick_port
		jsr joystick_read
		and #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP | JOY_FIRE)
		cmp #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP | JOY_FIRE)
		beq none ; nothing pressed
		sec
		bit #JOY_RIGHT
		beq @r
		bit #JOY_LEFT
		beq @l
		bit #JOY_DOWN
		beq @d
		bit #JOY_UP
		beq @u
		bit #JOY_FIRE
		bne none
    lda #'F'
    bra out
@u:	lda #KEY_CRSR_UP
		bra out
@r:	lda #KEY_CRSR_RIGHT
		bra out
@l:	lda #KEY_CRSR_LEFT
		bra out
@d:	lda #KEY_CRSR_DOWN
out:
		jsr char_out
    jsr primm
    .byte " PORT: ",0

    lda #0
    rol joystick_port
    adc #'1'
    jsr char_out

		bra setcrs
exit:
		jmp (retvec)

.bss
joystick_port: .res 1