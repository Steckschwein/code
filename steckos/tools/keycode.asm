.include	"common.inc"
.include	"keyboard.inc"
.include	"zeropage.inc"
.include	"kernel_jumptable.inc"

.include 	"appstart.inc"
appstart $1000

.import hexout

.export char_out=krn_chrout

main:
@0:
	jsr krn_getkey
  bcc @0
	pha
	jsr krn_primm
	.byte $0a,"0x",0
	pla
	jsr	hexout
  cmp #KEY_ESCAPE
  bne @0
	jmp (retvec)
