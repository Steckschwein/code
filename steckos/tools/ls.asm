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

entries_short    = 5*24
entries_long     = 23

opts_long       = (1 << 0)
opts_paging     = (1 << 1)
opts_cluster    = (1 << 2)
opts_attribs    = (1 << 3)
opts_crtdate    = (1 << 4)

appstart $1000

.code
    SetVector pattern, filenameptr

    lda #entries_short
    sta pagecnt
    sta entries_per_page

    stz options
    
    ldy #0
@parseloop:
    lda (paramptr),y
    bne :+
    jmp @read
: 
    cmp #' '
    beq @set_filenameptr
    cmp #'-'
    beq @option
    bne @set_filenameptr

@next_opt:
    iny 
    bne @parseloop 
    bra @set_filenameptr

@option:
    iny
    lda (paramptr),y  
    beq @parseloop    
    cmp #' '
    beq @next_opt
    
    cmp #'?'
    bne :+
    jsr usage
    jmp @exit
:
    cmp #'l'
    bne :+
    lda #opts_long
    jsr setopt

    lda #entries_long
    sta pagecnt
    sta entries_per_page
:
    ; show all files (remove hidden bit from mask)
    cmp #'h'
    bne :+
    lda #<~DIR_Attr_Mask_Hidden
    jsr setmask
    bra @option
:
    ; show volume id (remove volid bit from mask)
    cmp #'v'
    bne :+
    lda #<~DIR_Attr_Mask_Volume
    jsr setmask
:
    cmp #'c'
    bne :+
    lda #opts_cluster
    jsr setopt
    bra @option
:
    cmp #'d'
    bne :+
    lda #opts_crtdate
    jsr setopt
    bra @option
:
    cmp #'p'
    bne :+
    lda #opts_paging
    jsr setopt
    bra @option
:
    cmp #'a'
    bne :+
    lda #opts_attribs
    jsr setopt
:
    bra @option 

@set_filenameptr:
    
    iny
    lda (paramptr),y
    beq @l2
    dey
    copypointer paramptr, filenameptr

    tya 
    clc 
    adc filenameptr
    sta filenameptr

@read:

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

    lda options
    and #opts_long 
    beq :+
    jsr dir_show_entry_long
    bra @next
:
    jsr dir_show_entry_short

@next:
    lda options
    and #opts_paging
    beq @l
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

    jsr print_filename

    ldy #F32DirEntry::Attr
    lda (dirptr),y

    bit #DIR_Attr_Mask_Dir
    beq :+
    lda #']'
    jsr char_out
    bra @pad
:

    lda #' '
    jsr char_out
@pad:
    lda #' '
    jsr char_out
    lda #' '
    jsr char_out
    rts 

dir_show_entry_long:
    pha
    jsr print_filename

    lda #' '
    jsr char_out


    lda options
    and #opts_cluster
    beq :+
    jsr print_cluster_no
:   

    lda options
    and #opts_attribs   
    beq :+
    lda #' '
    jsr char_out
    jsr print_attribs
:

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
    jsr char_out

    jsr print_filesize

    lda #' '
    jsr char_out

@date:
    lda #opts_crtdate
    and options
    bne :+
    ldy #F32DirEntry::WrtDate
    bra @x
:
    ldy #F32DirEntry::CrtDate
@x:
    
    jsr print_fat_date

    lda #' '
    jsr char_out

    lda #opts_crtdate
    and options
    bne :+
    ldy #F32DirEntry::WrtTime+1
    bra @y
:
    ldy #F32DirEntry::CrtTime+1
@y:

    jsr print_fat_time
    crlf

    pla
    rts

setopt:
    ora options
    sta options
    rts

setmask:
    and dir_attrib_mask
    sta dir_attrib_mask
    rts 


print_cluster_no:
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
    rts


usage:
    jsr primm
    .byte "Usage: ls [OPTION]... [FILE]...",$0a, $0d
    .byte "options:",$0a,$0d
    .byte "   -a   show file attributes",$0a,$0d
    .byte "   -c   show number of first cluster",$0a,$0d
    .byte "   -d   show creation date",$0a,$0d
    .byte "   -h   show hidden files",$0a,$0d
    .byte "   -l   use a long listing format",$0a,$0d
    .byte "   -p   paginate output",$0a,$0d
    .byte "   -v   show volume ID ",$0a,$0d
    .byte "   -?   show this useful message",$0a,$0d
    .byte 0
    rts



; .data
pattern:    .byte "*.*",$00
dir_attrib_mask:  .byte DIR_Attr_Mask_Volume|DIR_Attr_Mask_Hidden
cnt:        .byte 6
.bss
fat_dirname_mask: .res 8+3 ;8.3 fat mask <name><ext>
options:          .res 1
pagecnt:          .res 1
entries_per_page: .res 1