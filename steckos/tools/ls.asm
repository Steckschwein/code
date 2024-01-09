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

.autoimport
.export char_out=krn_chrout

appstart $1000

.code
main:
    stz long
l1:
    crlf
    SetVector pattern, filenameptr
   
    ldy #0
@parseloop:
    lda (paramptr),y 
    beq @read
    cmp #'-'
    beq @option
    iny 
    bne @parseloop 
    bra @read 

@option:
    iny
    lda (paramptr),y  
    beq @parseloop    
    cmp #' '
    beq @parseloop

    ; jsr char_out

    cmp #'l'
    bne :+
    lda #1
    sta long
:
    bne @option 
    


    ; beq @l2
@read:

    ; copypointer paramptr, filenameptr
@l2:
    lda #<fat_dirname_mask
    ldy #>fat_dirname_mask
    jsr string_fat_mask ; build fat dir entry mask from user input

    ldx #FD_INDEX_CURRENT_DIR
    lda #<string_fat_mask_matcher
    ldy #>string_fat_mask_matcher
    jsr krn_find_first
    bcc @l4

    jsr hexout
    printstring " i/o error"
    jmp @exit
@l3:
    ldx #FD_INDEX_CURRENT_DIR
    jsr krn_find_next
    bcc @l4
    jmp @exit
@l4:
    lda (dirptr)
    cmp #$e5
    beq @l3


    ldy #F32DirEntry::Attr
    lda (dirptr),y
    bit dir_attrib_mask ; Hidden attribute set, skip
    bne @l3

    lda long 
    beq :+
    jsr dir_show_entry_long
    bra @next
:
    jsr dir_show_entry_short
@next:
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

dir_show_entry_short:
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
    rts 

dir_show_entry_long:
    pha
    jsr print_filename

    ldy #F32DirEntry::Attr
    lda (dirptr),y

    bit #DIR_Attr_Mask_Dir
    beq @l
    jsr primm
    .asciiz " <DIR> "
    bra @date        ; no point displaying directory size as its always zeros
              ; just print some spaces and skip to date display
@l:

    lda #' '
    jsr krn_chrout

    jsr print_filesize


    lda #' '
    jsr krn_chrout
@date:
    jsr print_fat_date


    lda #' '
    jsr krn_chrout


    jsr print_fat_time
    crlf

    pla
    rts



entries = 5*24

.data
pattern:  .byte "*.*",$00
cnt:      .byte 6
dir_attrib_mask:  .byte $0a
entries_per_page: .byte entries
pagecnt:          .byte entries

.bss
fat_dirname_mask: .res 8+3 ;8.3 fat mask <name><ext>
long: .res 1, 0
