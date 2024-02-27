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

filename_length = .sizeof(F32DirEntry::Name) + .sizeof(F32DirEntry::Ext) 


.export char_out=krn_chrout

.autoimport

appstart $1000

  ; everything until <space> in the parameter string is the source file name
    ldy #$00
@loop:
    lda (paramptr),y
    beq rename
    cmp #' '
    beq next
    sta filename,y
    iny
    lda #$00
    sta filename,y
    bra @loop


next:
    ; first we init the buffer with spaces so we just need to fill in the filename and extension
    ldx #filename_length -1
    lda #' '
@l:
    sta new_filename,x
    dex
    bne @l

    iny
    ldx #$00
@loop:
    lda (paramptr),y
    beq rename
    cmp #'.'
    bne @skip

    ; found the dot. advance x to pos. 8, point y to the next byte and go again
    iny
    ldx #8
    bra @loop

@skip:
    toupper
    sta new_filename,x
    inx
    iny
    bra @loop


rename:
    lda #<filename
    ldx #>filename
    ldy #O_WRONLY
    jsr krn_open
    bcs error
    
    phx 
    lda #<dirent
    ldy #>dirent
    jsr krn_read_direntry
    bcs error

    ldy #filename_length -1
  :
    lda new_filename,y
    sta dirent,y
    dey 
    bpl :-


  ; after <space> there comes the destination filename
  ; copy and normalize it FAT dir entry style

    plx 

    lda #<dirent
    ldy #>dirent
    jsr krn_update_direntry

    bcs wrerror

    jsr krn_close
    jmp (retvec)

error:
    jsr primm
    .asciiz "open error"
    jmp (retvec)
wrerror:
    jsr hexout
    jsr primm
    .asciiz " write error"
    jmp (retvec)

.bss
filename:	    .res filename_length
new_filename:	.res filename_length
dirent:       .res .sizeof(F32DirEntry)