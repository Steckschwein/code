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

;@module: fat32

.ifdef DEBUG_FAT32 ; debug switch for this module
  debug_enabled=1
.endif

.include "zeropage.inc"
.include "fat32.inc"
.include "errno.inc"  ; from ca65 api
.include "fcntl.inc"  ; from ca65 api
.include "stdio.inc"  ; from ca65 api

.include "debug.inc"

.importzp __volatile_tmp

.autoimport

.export fat_fseek

.code

;@desc: seek n bytes within file denoted by the given FD
;@name: fat_fseek
;@in: X - offset into fd_area
;@in: A/Y - pointer to seek_struct - @see fat32.inc
;@out: C=0 on success (A=0), C=1 and A=<error code> or C=1 and A=0 (EOK) if EOF reached
fat_fseek:

    _is_file_open   ; otherwise rts C=1 and A=#EINVAL
    _is_file_dir    ; otherwise rts C=1 and A=#EISDIR

    sta __volatile_ptr
    sty __volatile_ptr+1

    ldy #Seek::Whence
    lda (__volatile_ptr),y
    debug "fat fseek >"
    cmp #SEEK_SET
    ; TODO support SEEK_CUR, SEEK_END
    bne @l_exit_err
    ; save new seek pos
    ldy #Seek::Offset
    lda (__volatile_ptr),y
    sta fd_area+F32_fd::SeekPos+0,x
    iny
    lda (__volatile_ptr),y
    sta fd_area+F32_fd::SeekPos+1,x
    iny
    lda (__volatile_ptr),y
    sta fd_area+F32_fd::SeekPos+2,x
    iny
    lda (__volatile_ptr),y
    sta fd_area+F32_fd::SeekPos+3,x

    lda fd_area+F32_fd::status,x
    ora #FD_STATUS_DIRTY                 ; set dirty - @see __fat_prepare_block_access
    sta fd_area+F32_fd::status,x

    lda #EOK
    clc
    debug "fat fseek <"
    rts
@l_exit_err:
    lda #EINVAL
    sec
    rts
