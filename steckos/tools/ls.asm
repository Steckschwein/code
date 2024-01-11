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


appstart $1000

.code
    SetVector pattern, filenameptr
    SetVector dir_show_entry_short, direntry_vec
    lda #entries_short
    sta pagecnt
    sta entries_per_page

    stz showcls
    stz crtdate
    stz paging
    
    ldy #0
@parseloop:
    lda (paramptr),y 
    beq @read
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

    cmp #'l'
    bne :+
    SetVector dir_show_entry_long, direntry_vec
    lda #entries_long
    sta pagecnt
    sta entries_per_page
:
    ; show all files (remove hidden bit from mask)
    cmp #'a'
    bne :+
    lda dir_attrib_mask
    and #%11111101
    sta dir_attrib_mask
:
    ; show volume id (remove volid bit from mask)
    cmp #'v'
    bne :+
    lda dir_attrib_mask
    and #%11110111
    sta dir_attrib_mask
:
    cmp #'c'
    bne :+
    inc showcls
:
    cmp #'d'
    bne :+
    inc crtdate
:
    cmp #'p'
    bne :+
    inc paging
:

    cmp #'h'
    bne :+
    jsr usage
    jmp @exit
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

    jsr dir_show_entry

@next:
    lda paging
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
    ; SetVector paramptr, filenameptr
    jmp (retvec)

dir_show_entry:
    jmp (direntry_vec)

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

    lda #' '
    jsr krn_chrout

    lda showcls
    beq :+
    jsr print_cluster_no
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
    jsr krn_chrout

    jsr print_filesize

    lda #' '
    jsr krn_chrout



@date:
    lda crtdate
    bne :+
    ldy #F32DirEntry::WrtDate+1
    bra @x
:
    ldy #F32DirEntry::CrtDate+1
@x:
    lda (dirptr),y 
    tax 
    dey 
    lda (dirptr),y 
    
    jsr print_fat_date_ax


    lda #' '
    jsr krn_chrout

    lda crtdate
    bne :+
    ldy #F32DirEntry::WrtTime
    bra @y
:
    ldy #F32DirEntry::CrtTime
@y:
    lda (dirptr),y 
    tax
    iny
    lda (dirptr),y 


    jsr print_fat_time_ax
    crlf

    pla
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

print_fat_date_ax:
        pha
		and #%00011111
		jsr b2ad

		lda #'.'
		jsr char_out

		; month
		
		txa
		lsr
		tax

        pla
		ror
		lsr
		lsr
		lsr
		lsr

		jsr b2ad

		lda #'.'
		jsr  char_out

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


print_fat_time_ax:
    pha
    lsr
    lsr
    lsr

    jsr b2ad
 
    lda #':'
    jsr char_out

    pla
    and #%00000111
    sta tmp1

    txa
   
    .repeat 5
    lsr tmp1
    ror
    .endrepeat

    jsr b2ad

    lda #':'
    jsr char_out

    txa
    and #%00011111

    jsr b2ad
    rts



usage:
    jsr primm
    .byte "Usage: ls [OPTION]... [FILE]...",$0a, $0d
    .byte "options:",$0a,$0d
    .byte "   -a   show all files (including hidden)",$0a,$0d
    .byte "   -c   show number of first cluster",$0a,$0d
    .byte "   -d   show creation date",$0a,$0d
    .byte "   -h   show this useful message",$0a,$0d
    .byte "   -p   paginate output",$0a,$0d
    .byte "   -v   show volume ID ",$0a,$0d
    .byte "   -l   use a long listing format",$0a,$0d
    .byte 0
    rts



.data
pattern:  .byte "*.*",$00
dir_attrib_mask:  .byte DIR_Attr_Mask_Volume|DIR_Attr_Mask_Hidden
cnt:      .byte 6

.bss
fat_dirname_mask: .res 8+3 ;8.3 fat mask <name><ext>
direntry_vec: .res 2
showcls: .res 1
crtdate: .res 1
paging: .res 1
pagecnt:          .res 1
entries_per_page: .res 1
tmp1: .res 1
