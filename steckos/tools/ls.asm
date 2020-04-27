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

.export cnt, files;, dirs
.import dir_show_entry, pagecnt, entries_per_page, dir_attrib_mask
.import b2ad2
.import hexout

.export char_out=krn_chrout

appstart $1000

main:
    stz bytes
    stz bytes +1
    stz bytes +2
    stz bytes +3
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


    ldy #F32DirEntry::FileSize+3
    clc
    lda (dirptr),y
    adc bytes+3
    sta bytes+3

    dey
    lda (dirptr),y
    adc bytes+2
    sta bytes+2

    dey
    lda (dirptr),y
    adc bytes+1
    sta bytes+1

    dey
    lda (dirptr),y
    adc bytes+0
    sta bytes+0

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

    jsr show_bytes_decimal

    jsr krn_primm
    .asciiz " bytes in "

    stz files_dec
    ldx #8
    sed
@l1:
    asl files
    lda files_dec
    adc files_dec
    sta files_dec
    dex
    bne @l1
    cld
    lda files_dec
    jsr show_digit

    printstring " files"

    jmp (retvec)

show_bytes_decimal:
    sed
    ldx #32
@l1:
    asl bytes + 0
    rol bytes + 1
    rol bytes + 2
    rol bytes + 3

    lda decimal + 0
    adc decimal + 0
    sta decimal + 0

    lda decimal + 1
    adc decimal + 1
    sta decimal + 1

    lda decimal + 2
    adc decimal + 2
    sta decimal + 2

    lda decimal + 3
    adc decimal + 3
    sta decimal + 3

    dex
    bne @l1
    cld

    lda decimal+3
    beq @n1
    jsr show_digit
@n1:
    lda decimal+2
    beq @n2
    jsr show_digit
@n2:
    lda decimal+1
    beq @n3
    jsr show_digit
@n3:
    lda decimal+0

show_digit:
    pha
    lsr
    lsr
    lsr
    lsr
    ora #$30
    jsr char_out
    pla
    and #$0f
    ora #$30
    jsr char_out
    rts

pattern:  .byte "*.*",$00
cnt:      .byte $04
;dirs:     .byte $00
files:    .byte $00
files_dec: .byte $00
bytes:    .dword $00000000
decimal:  .dword $00000000
