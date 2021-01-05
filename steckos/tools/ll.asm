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
.export char_out=krn_chrout

.import hexout
.import print_fat_date, print_fat_time, print_filename

.zeropage
tmp1: .res 1
tmp2: .res 1
tmp3: .res 2

appstart $1000

main:
    .repeat 4,i
        stz fsize_sum + i
    .endrepeat
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
    jmp @summary
@l4:
    lda (dirptr)
    cmp #$e5
    beq @l3

    ldy #F32DirEntry::FileSize+3
    clc
    lda (dirptr),y
    sta fsize+3
    adc fsize_sum+3
    sta fsize_sum+3

    ldx #2
:
    dey
    lda (dirptr),y
    sta fsize,x
    adc fsize_sum,x
    sta fsize_sum,x
    dex
    bpl :-

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
   ; cmp #$03 ; CTRL-C
   ; beq @exit

    ; check for ctrl c
    bit flags
    bmi @exit

    lda entries_per_page
    sta pagecnt
    bra @l
@lx:
    lda #1
    sta pagecnt
@l:
    ;jsr krn_getkey
    ;cmp #$03 ; CTRL-C?
    ;beq @exit

    ; check for ctrl c
    bit flags
    bmi @exit
    bra @l3

@summary:
    jsr show_bytes_decimal

    jsr krn_primm
    .asciiz " bytes in "

    stz decimal
    stz decimal+1

    ldx #8
    sed
@l1:
    asl files
    lda decimal
    adc decimal
    sta decimal

    lda decimal+1
    adc decimal+1
    sta decimal+1

    dex
    bne @l1
    cld

    lda decimal+1
    beq :+
    jsr hexout
:
    lda decimal
    jsr hexout


    printstring " files"

@exit:
    jmp (retvec)

show_bytes_decimal:
    jsr zero_decimal_buf

    sed
    ldx #32
@l1:
    asl fsize_sum + 0
    rol fsize_sum + 1
    rol fsize_sum + 2
    rol fsize_sum + 3

    ldy #<(-5)
:
    lda decimal + 5 -$100,y
    adc decimal + 5 -$100,y
    sta decimal + 5 -$100,y
    iny
    bne :-
    dex
    bne @l1
    cld

    stz tmp1
    ldx #6
:
    dex
    lda decimal,x
    beq :-
:
    lda decimal,x
    jsr hexout
    dex
    bpl :-

    rts

dir_show_entry:
	pha
	jsr print_filename

	ldy #F32DirEntry::Attr
	lda (dirptr),y

	bit #DIR_Attr_Mask_Dir
	beq @l
	jsr krn_primm
	.asciiz "    <DIR> "
	bra @date				; no point displaying directory size as its always zeros
							; just print some spaces and skip to date display
@l:

    lda #' '
    jsr krn_chrout

	jsr print_filesize

	lda #' '
	jsr krn_chrout
	inc files
@date:
	jsr print_fat_date


	lda #' '
	jsr krn_chrout


	jsr print_fat_time
    crlf

	pla
	rts

zero_decimal_buf:
    .repeat 6,i
        stz decimal + i
    .endrepeat
    rts

print_filesize:
    lda fsize + 3
    beq :+
    jsr krn_primm
    .asciiz "VERY BIG"
    rts
:
    jsr zero_decimal_buf

    ldx #32
    sed
@l1:
    asl fsize + 0
    rol fsize + 1
    rol fsize + 2
    rol fsize + 3

    ; phy
    ldy #<(-5)
:
    lda decimal + 5 -$100,y
    adc decimal + 5 -$100,y
    sta decimal + 5 -$100,y
    iny
    bne :-
    ; ply

    dex
    bne @l1
    cld

    lda decimal + 5
    bne :+
    bra @next0
:
    jsr hexout
@next0:
    lda decimal + 4
    bne :+
    bra @next1
:
    jsr hexout
@next1:

    lda decimal + 3
    jsr hexout
    lda decimal + 2
    jsr hexout
    lda decimal + 1
    jsr hexout
    lda decimal + 0
    jmp hexout

;	rts

entries = 23
; .data
pattern:        .asciiz "*.*"
cnt:            .byte $04
dir_attrib_mask:  .byte $0a
entries_per_page: .byte entries
pagecnt:          .byte entries
files:          .res 1
fsize_sum:      .res 4
fsize:          .res 4
decimal:        .res 6
