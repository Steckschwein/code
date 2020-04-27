; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

.include "common.inc"
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "fat32.inc"
.include "appstart.inc"

.import hexout
.import print_filename
.import b2ad, dpb2ad, print_fat_date, print_fat_time, bin2dual, hexout

.export dir_show_entry, pagecnt, entries_per_page, dir_attrib_mask

.export char_out=krn_chrout
.zeropage
tmp1: .res 1
tmp2: .res 1
tmp3: .res 2
.code
appstart $1000

main:
l1:
    crlf
    SetVector pattern, filenameptr

    lda (paramptr)
    beq @l2
    copypointer paramptr, filenameptr
@l2:
    ldx #FD_INDEX_CURRENT_DIR
    jsr krn_find_first
    bcs @l4
    jsr hexout
    printstring " i/o error"
    bra @exit
@l3:
    ldx #FD_INDEX_CURRENT_DIR
    jsr krn_find_next
    bcc @exit
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
    beq @exit

    lda entries_per_page
    sta pagecnt
    bra @l
@lx:
    lda #1
    sta pagecnt
@l:
    jsr krn_getkey
    cmp #$03 ; CTRL-C?
    beq @exit
    bra @l3

@exit:
    jmp (retvec)

dir_show_entry:
		pha
		jsr krn_primm
		.byte "Name: ",$00
		jsr print_filename
		crlf

		jsr krn_primm
		.byte "Size: ",$00
		ldy #F32DirEntry::FileSize +1
		lda (dirptr),y
		tax
		ldy #F32DirEntry::FileSize
		lda (dirptr),y
		jsr dpb2ad

		jsr krn_primm
		.byte "  Cluster#1: ",$00

		ldy #F32DirEntry::FstClusHI+1
		lda (dirptr),y
		jsr hexout
		dey
		lda (dirptr),y
		jsr hexout
		ldy #F32DirEntry::FstClusLO+1
		lda (dirptr),y
		jsr hexout
		dey
		lda (dirptr),y
		jsr hexout

		crlf

		jsr krn_primm
		.byte "Attribute: "
		.byte "--ADVSHR",$00
		crlf

		jsr krn_primm
		.byte "           ",$00

		ldy #F32DirEntry::Attr
		lda (dirptr),y

		jsr bin2dual
		crlf


		jsr krn_primm
		.byte "Created  : ",$00
		ldy #F32DirEntry::CrtDate
		jsr print_fat_date

		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::CrtTime +1
		jsr print_fat_time
		crlf

		jsr krn_primm
		.byte "Modified : ",$00
		ldy #F32DirEntry::WrtDate
		jsr print_fat_date

		lda #' '
		jsr krn_chrout

		ldy #F32DirEntry::WrtTime +1
		jsr print_fat_time
		crlf

		pla
		rts

pattern:  .byte "*.*",$00
cnt:      .byte $04
entries = 23
dir_attrib_mask:  .byte $0a
entries_per_page: .byte entries
pagecnt:          .byte entries
