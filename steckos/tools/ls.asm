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


.include "steckos.inc"
.include "fat32.inc"

.import hexout
.import primm
.export char_out=krn_chrout

appstart $1000

.code
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
    jmp @exit
@l3:
    ldx #FD_INDEX_CURRENT_DIR
    jsr krn_find_next
    bcs @l4 
    jmp @exit
@l4:
    lda (dirptr)
    cmp #$e5
    beq @l3


    ldy #F32DirEntry::Attr
    lda (dirptr),y
    bit dir_attrib_mask ; Hidden attribute set, skip
    bne @l3


    dec cnt
    bne @l1
    crlf
    lda #5
    sta cnt
@l1:
    ldy #F32DirEntry::Attr
	lda (dirptr),y

 	bit #DIR_Attr_Mask_Dir
	beq :+
    lda #'['
    jsr char_out
    bra @print
:
    lda #' '
    jsr char_out

@print:
  
	ldy #F32DirEntry::Name
:
	lda (dirptr),y
    jsr char_out
    iny
    cpy #$0b
    bne :-

    ldy #F32DirEntry::Attr
	lda (dirptr),y

	bit #DIR_Attr_Mask_Dir
	beq :+
    lda #']'
    jsr char_out
    bra @pad
:

    lda #' '
    jsr krn_chrout
@pad:
    lda #' '
    jsr krn_chrout
    lda #' '
    jsr krn_chrout

    dec pagecnt
    bne @l
    keyin
    cmp #13 ; enter pages line by line
    beq @lx

    ; check ctrl c
    bit flags
    bmi @exit

    lda entries_per_page
    sta pagecnt
    bra @l
@lx:
    lda #1
    sta pagecnt
@l:
    bit flags
    bmi @exit
    jmp @l3

@exit:
    jmp (retvec)


pattern:  .byte "*.*",$00
cnt:      .byte 6
entries = 5*24
dir_attrib_mask:  .byte $0a
entries_per_page: .byte entries
pagecnt:          .byte entries
