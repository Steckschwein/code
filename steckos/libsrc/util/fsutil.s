.include "fat32.inc"

.export print_filename, print_fat_date, print_fat_time, print_filesize

.importzp dirptr
.importzp tmp1, tmp2
.autoimport 
.segment "CODE"
print_filename:
		ldy #F32DirEntry::Name
@l1:	lda (dirptr),y
		jsr char_out
		iny
		cpy #$0b
		bne @l1
		rts

print_fat_date:
		ldy #F32DirEntry::WrtDate
		lda (dirptr),y
		and #%00011111
		jsr b2ad

		lda #'.'
		jsr char_out

		; month
		iny
		lda (dirptr),y
		lsr
		tax
		dey
		lda (dirptr),y
		ror
		lsr
		lsr
		lsr
		lsr

		jsr b2ad

		lda #'.'
		jsr char_out


		txa
		clc
		adc #80   	; add begin of msdos epoch (1980)
		cmp #100
		bcc @l6		; greater than 100 (post-2000)
		sec 		; yes, substract 100
		sbc #100
@l6:	jsr b2ad ; there we go

		rts

print_fat_time:
		ldy #F32DirEntry::WrtTime +1
		lda (dirptr),y
		tax
		lsr
		lsr
		lsr

		jsr b2ad

		lda #':'
		jsr char_out


		txa
		and #%00000111
		sta tmp1
		dey
		lda (dirptr),y

		.repeat 5
		lsr tmp1
		ror
		.endrepeat

		jsr b2ad

		lda #':'
		jsr char_out

		lda (dirptr),y
		and #%00011111

		jsr b2ad

		rts

print_filesize:
		lda #' '
		jsr char_out

		phy
		lda dirptr
	    clc
	    adc #F32DirEntry::FileSize
	    tax
	    lda dirptr +1
	    adc #0
	    tay

	    lda #' '
	    jsr dword2asc

 		stx $0a
		sty $0b

		sta tmp2
		lda #$06
		sec
		sbc tmp2
		; beq @l2
		tax
		lda #' '
@l0:
		jsr char_out
		dex
		bpl @l0

	    ldy #0
@l2:
	    lda ($0a),y
	    jsr char_out
	    iny
	    cpy tmp2
	    bne @l2
		ply
		rts
