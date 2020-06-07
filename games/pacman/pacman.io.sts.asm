;i/o
		.include "pacman.sts.inc"

		.export io_init
		.export io_detect_joystick
		.export io_joystick_read
		.export io_exit
		.export io_getkey
		.export io_player_direction
		.export io_irq
		.export io_irq_on

		.import joystick_on
		.import joystick_detect
		.import joystick_read

appstart $1000	;

io_init:
		jsr krn_textui_disable

		jsr joystick_on

		;TODO ...
		rts

io_irq:
		bit	a_vreg
		rts

io_irq_on:	; nothing todo here on sts hw
		rts

io_detect_joystick:
		jsr joystick_detect
		beq @rts
		sta joystick_port
@rts: rts

io_joystick_read:
		  lda joystick_port
		  jmp joystick_read

io_getkey=krn_getkey

io_player_direction:
		beq @joystick
		cmp #KEY_CRSR_RIGHT
		beq @r
		cmp #KEY_CRSR_LEFT
		beq @l
		cmp #KEY_CRSR_DOWN
		beq @d
		cmp #KEY_CRSR_UP
		bne @joystick
@u:	lda #ACT_UP
		rts
@r:	lda #ACT_RIGHT
		rts
@l:	lda #ACT_LEFT
		rts
@d:	lda #ACT_DOWN
		rts
@joystick:
		jsr io_joystick_read
		and #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP)
		cmp #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP)
		beq @rts; nothing pressed
		sec
		bit #JOY_RIGHT
		beq @r
		bit #JOY_LEFT
		beq @l
		bit #JOY_DOWN
		beq @d
		bit #JOY_UP
		beq @u
@rts:
		clc
		rts

io_exit:
		jmp (retvec)

.data
		joystick_port:  .res 1, JOY_PORT1
