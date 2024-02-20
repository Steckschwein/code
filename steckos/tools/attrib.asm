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


.export char_out=krn_chrout
.export dirent

.autoimport

appstart $1000
.code
		ldy #$00
@loop:
		lda (paramptr),y
		cmp #'+'
		beq param
		cmp #'-'
		beq param

		iny
		bne @loop
end:

		jmp wuerg

param:
		sta op
		iny

		lda (paramptr),y
		toupper
		; and #$DF
		ldx #$00
		cmp #'A'
		bne @l1
		ldx #DIR_Attr_Mask_Archive
@l1:	
		cmp #'H'
		bne @l2
		ldx #DIR_Attr_Mask_Hidden
@l2:	
		cmp #'R'
		bne @l3
		ldx #DIR_Attr_Mask_ReadOnly
@l3:	
		cmp #'S'
		bne @l4
		ldx #DIR_Attr_Mask_System
@l4:

		stx atr
		lda atr
		bne @l5
		jsr primm
		.byte "invalid attribute",$00
		jmp (retvec)
@l5:

		iny

		; everything until <space> in the parameter string is the source file name
		iny
wuerg:
		ldx #$00
@loop:
		lda (paramptr),y
		beq attrib
		sta filename,x
		iny
		inx
		stz filename,x
		bra @loop

attrib:
	  lda #<filename
    ldx #>filename
		ldy #O_WRONLY
    jsr krn_open
		bcs error

		lda #<dirent
    ldy #>dirent
    jsr krn_read_direntry
		bcs error

		phx

		lda atr
		ldx op
		ldy #F32DirEntry::Attr
		cpx #'+'
		bne @l1
		
		ora dirent,y
		
		bra @save
@l1:	
		cpx #'-'
		bne @view

		
		lda atr
		eor #$ff 				; make complement mask
		and dirent,y

@save:
		sta dirent,y
		plx

    lda #<dirent
    ldy #>dirent
    jsr krn_update_direntry
    bcs wrerror

		jsr krn_close

		jmp (retvec)

@view:
		ldy #F32DirEntry::Name
@l2:
		lda (dirptr),y
		jsr krn_chrout
		iny
		cpy #F32DirEntry::Attr
		bne @l2

		lda #':'
		jsr krn_chrout

		jsr print_attribs

@out:
		jmp (retvec)

error:
		jsr primm
		.asciiz "open error"
		jmp (retvec)
wrerror:
		jsr hexout
		jsr krn_close

		jsr primm
		.asciiz " write error"
		jmp (retvec)


.bss
filename:	.res 12
op:				.res 1
atr:			.res 1
dirent:   .res .sizeof(F32DirEntry)
