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

.ifdef DEBUG_UTIL		; enable debug for this module
	debug_enabled=1
.endif
.setcpu "65c02"
.include	"kernel.inc"
.include	"fat32.inc"
.include	"errno.inc"

.code

.export fat_name_string, put_char
.export path_inverse
.export cluster_nr_matcher

		; in:
		;	dirptr - pointer to dir entry (F32DirEntry)
cluster_nr_matcher:
		ldy #F32DirEntry::Name
		lda (dirptr),y
		cmp #DIR_Entry_Deleted
		beq @l_notfound
		ldy #F32DirEntry::FstClusLO+0
		lda fat_tmp_dw+0
		cmp (dirptr),y
		bne @l_notfound
		ldy #F32DirEntry::FstClusLO+1
		lda fat_tmp_dw+1
		cmp (dirptr),y
		bne @l_notfound
		ldy #F32DirEntry::FstClusHI+0
		lda fat_tmp_dw+2
		cmp (dirptr),y
		bne @l_notfound
		ldy #F32DirEntry::FstClusHI+1
		lda fat_tmp_dw+3
		cmp (dirptr),y
		beq @l_found
@l_notfound:
		clc
@l_found:
		rts

	; fat name to string (by reference)
	; in:
	;	dirptr		- pointer to directory entry (F32DirEntry)
	;	krn_ptr3	- pointer to result string
	;	krn_tmp3	- offset from krn_ptr3 (result string)
fat_name_string:
	stz krn_tmp
l_next:
	ldy krn_tmp
	cpy #11
	beq l_exit
	inc krn_tmp
	lda (dirptr), y
	cmp #' '
	beq l_next
	cpy #8
	bne fns_ca
	pha
	lda #'.'
	jsr put_char
	pla
fns_ca:
	jsr put_char
	bra l_next

put_char:
	ldy krn_tmp3
	sta (krn_ptr3), y
	inc krn_tmp3
l_exit:
	rts

	; recursive inverse a path string where each path segment is separated by a '/'
	; in:
	;	krn_ptr2 - pointer to the result string
	;	krn_ptr3	- pointer to originary path we have to inverse
	; out:
	;	Y - length of the result string (krn_ptr2)
	;
	; sample: foo/bar/baz is converted to baz/bar/foo
	;
path_inverse:
		stz krn_tmp
		stz krn_tmp2
		ldy #0
		jsr l_inv
		iny
		lda #0
		sta (krn_ptr2),y
		rts
l_inv:
		lda (krn_ptr3), y
		iny
		cpy krn_tmp3
		beq l_seg
		cmp #'/'
		bne l_inv
		phy
		jsr l_inv
		ply
		sty krn_tmp
l_seg:
		ldy krn_tmp
		inc krn_tmp
		lda (krn_ptr3), y
		ldy krn_tmp2
		inc krn_tmp2
		sta (krn_ptr2), y
		cmp #'/'
		bne l_seg
		rts
