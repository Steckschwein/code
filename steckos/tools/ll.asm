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
.import hexout
.import print_fat_date, print_fat_time, print_filename

.export char_out=krn_chrout
.zeropage
tmp1: .res 1
tmp2: .res 1
tmp3: .res 2
.exportzp tmp1, tmp2
.code
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

    dey
    lda (dirptr),y
    sta fsize+2
    adc fsize_sum+2
    sta fsize_sum+2

    dey
    lda (dirptr),y
    sta fsize+1
    adc fsize_sum+1
    sta fsize_sum+1

    dey
    lda (dirptr),y
    sta fsize+0
    adc fsize_sum+0
    sta fsize_sum+0

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

@summary:
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

@exit:
    jmp (retvec)

show_bytes_decimal:
    stz decimal + 0
    stz decimal + 1
    stz decimal + 2
    stz decimal + 3
    sed
    ldx #32
@l1:
    asl fsize_sum + 0
    rol fsize_sum + 1
    rol fsize_sum + 2
    rol fsize_sum + 3

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

print_filesize:
    .repeat 4,i
        stz decimal + i
    .endrepeat

    ldx #32
    sed
@l1:
    asl fsize + 0
    rol fsize + 1
    rol fsize + 2
    rol fsize + 3

    .repeat 4,i
        lda decimal + i
        adc decimal + i
        sta decimal + i
    .endrepeat

    dex
    bne @l1
    cld

    lda decimal + 3
    bne @show1
    jsr krn_primm
    .asciiz "  "
    bra @next1
@show1:

    jsr show_digit
@next1:
    lda decimal + 2
    bne @show2
    jsr krn_primm
    .asciiz "  "
    bra @next2
@show2:
    jsr show_digit
@next2:
    lda decimal + 1
    jsr show_digit
    lda decimal + 0
    jmp show_digit

;	rts

entries = 23
.bss
pattern:        .asciiz "*.*"
cnt:            .byte $04
dir_attrib_mask:  .byte $0a
entries_per_page: .byte entries
pagecnt:          .byte entries
files:          .res 1
files_dec:      .res 1
fsize_sum:      .res 4
fsize:          .res 4
decimal:        .res 4
