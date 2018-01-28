
.include "common.inc"
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "fat32.inc"
.include "appstart.inc"
.include "tools.inc"
.export cnt, files, dirs
.import dir_show_entry, pagecnt, entries_per_page, dir_attrib_mask
.import b2ad2

appstart $1000
main:

		; lda #$04
		; sta cnt
l1:
		crlf
		SetVector pattern, filenameptr

		lda (paramptr)
		beq @l2
		copypointer paramptr, filenameptr

@l2:
		ldx #FD_INDEX_CURRENT_DIR
		jsr krn_find_first
		bcs @l2_1

		printstring "i/o error"
		jmp (retvec)

@l2_1:	bcs @l4
		bra @l5
		; jsr .dir_show_entry
@l3:
		ldx #FD_INDEX_CURRENT_DIR
		jsr krn_find_next
		bcc @l5
@l4:
		lda (dirptr)
		cmp #$e5
		beq @l3

		ldy #F32DirEntry::Attr
		lda (dirptr),y

		bit dir_attrib_mask ; Hidden attribute set, skip
		bne @l3


		jsr dir_show_entry

		dec pagecnt
		bne @l
		keyin
		cmp #13 ; enter pages line by line
		beq @lx
		cmp #$03 ; CTRL-C
		beq @l5

		lda entries_per_page
		sta pagecnt
		bra @l
@lx:
		lda #1
		sta pagecnt

@l:

		jsr krn_getkey
		cmp #$03 ; CTRL-C?
		beq @l5
		bra @l3
@l5:

		lda files
		beq @dirs
		jsr b2ad2
		jsr krn_primm
		.byte " file(s)",$0a,$00
@dirs:
		lda dirs
		beq @end
		jsr b2ad2
		jsr krn_primm
		.byte " dir(s)",$0a,$00

@end:

		jmp (retvec)






pattern:			.byte "*.*",$00
cnt: 	.byte $04
dirs:	.byte $00
files:	.byte $00
