.include "fat32.inc"
.include "common.inc"


.export print_filename, print_fat_date, print_fat_time, print_filesize, print_attribs

.importzp dirptr
.autoimport 
.code
print_filename:
		ldx #0
		ldy #F32DirEntry::Name
@l1:
		lda (dirptr),y
		tolower
		jsr char_out
		iny
		cpy #11
		bne @l1

		rts

print_fat_date:
    ; ldy #F32DirEntry::WrtDate
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
@l6:
    jsr b2ad ; there we go
    rts

print_fat_time:
    ; ldy #F32DirEntry::WrtTime +1
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
    phy
	clc
    ldy #F32DirEntry::FileSize+3
    lda (dirptr),y
    ldy #F32DirEntry::FileSize+2
    adc (dirptr),y

    beq :+
    jsr primm
    .asciiz ">64k "
		ply
    rts
:
    ldy #F32DirEntry::FileSize+1
    lda (dirptr),y
    tax 
    dey 
    lda (dirptr),y

    jsr dpb2ad
	ply
    rts

print_attribs:
    ldy #F32DirEntry::Attr
    lda (dirptr),y

    ldx #3
@al:
    bit attr_tbl,x
    beq @skip
    pha
    lda attr_lbl,x
    jsr char_out
    pla
    bra @next
@skip:
    pha
    lda #' '
    jsr char_out
    pla
@next:
    dex 
    bpl @al
    rts
attr_tbl:   .byte DIR_Attr_Mask_ReadOnly, DIR_Attr_Mask_Hidden,DIR_Attr_Mask_System,DIR_Attr_Mask_Archive
attr_lbl:   .byte 'R','H','S','A'

.bss
tmp1: .res 1
tmp2: .res 1