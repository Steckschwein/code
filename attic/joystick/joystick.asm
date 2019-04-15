
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "via.inc"
.include "common.inc"
.include "joystick.inc"

.include "appstart.inc"

.import joystick_read
.import joystick_on
.import hexout

.export char_out=krn_chrout

appstart

main:
  jsr joystick_on

	jsr krn_primm
	.byte "x to disable joystick ports",$0a,"y to enable",$0a,$00

loop:

	jsr krn_primm
	.asciiz "j1: "


  lda #JOY_PORT1
  jsr joystick_read
	and	#%00111111
	jsr	hexout

	jsr krn_primm
	.asciiz " j2: "

	lda	#JOY_PORT2		;port 1
  jsr joystick_read
	and	#%00111111
	jsr	hexout

	ldx #$00
	ldy crs_y
	jsr krn_textui_crsxy

	jsr krn_getkey
	bcc loop
	cmp #'x'
	bne @l
	; joysticks off
	joy_off
	bra loop
@l:	cmp #'y'
	bne @l1
	; joysticks on
	joy_on
	bra loop
@l1:
	cmp #$03
	bne loop
	jmp (retvec)
