.setcpu "65c02"

.include "joystick.inc"
.include "common.inc"
.include "keyboard.inc"
.include "appstart.inc"
.include "kernel_jumptable.inc"

.autoimport

.export char_out=krn_chrout

appstart $1000
    jsr joystick_on

loop:
    jsr krn_getkey
    cmp #KEY_ESCAPE
    beq exit
		jsr joystick_detect
		sta joystick_port
		jsr joystick_read
		and #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP | JOY_FIRE)
		cmp #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP | JOY_FIRE)
		beq out; nothing pressed
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
		bne loop
    lda #$f
    bra out
@u:	lda #1
		bra out
@r:	lda #2
		bra out
@l:	lda #3
		bra out
@d:	lda #4
out:
		jsr hexout_s
    ldx #0
    ldy #0
    jsr krn_textui_crsxy
    bra loop
exit:
		jmp (retvec)

.bss
joystick_port: .res 1