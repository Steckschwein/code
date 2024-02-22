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
.include "fcntl.inc"


.autoimport

.export char_out=krn_chrout
.export dirent

appstart $1000

main:
    lda (paramptr)
    beq @usage
    copypointer paramptr, filenameptr

    lda filenameptr
    ldx filenameptr+1
    ldy #O_RDONLY
    jsr krn_open
    bcs @open_fail

    lda #<dirent
    ldy #>dirent
    jsr krn_read_direntry
    jsr krn_close

    jsr dir_show_entry

@open_fail:
@exit:
    jmp (retvec)
@usage:
    jsr primm
    .asciiz "usage: stat <filename>"
    bra @exit

dir_show_entry:

    jsr primm
    .byte "Name: ",$00
    jsr print_filename
    crlf

    jsr primm
    .byte "Size: ",$00
    jsr print_filesize

    jsr primm
    .byte "  Cluster#1: ",$00

    jsr print_cluster_no

    crlf

    jsr primm
    .byte "Attribute: "
    .byte "--ADVSHR",$00
    crlf

    jsr primm
    .byte "           ",$00

    ldy #F32DirEntry::Attr
    lda dirent,y

    jsr bin2dual
    crlf


    jsr primm
    .byte "Created  : ",$00
    ldy #F32DirEntry::CrtDate
    jsr print_fat_date

    lda #' '
    jsr krn_chrout

    ldy #F32DirEntry::CrtTime +1
    jsr print_fat_time
    crlf

    jsr primm
    .byte "Modified : ",$00
    ldy #F32DirEntry::WrtDate
    jsr print_fat_date

    lda #' '
    jsr krn_chrout

    ldy #F32DirEntry::WrtTime +1
    jsr print_fat_time
    crlf

    rts

.bss
dirent:           .res .sizeof(F32DirEntry)
