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

.ifdef DEBUG_FAT32_DIR ; debug switch for this module
          debug_enabled=1
.endif

.include "zeropage.inc"
.include "common.inc"
.include "fat32.inc"
.include "rtc.inc"
.include "errno.inc"  ; from ca65 api
.include "fcntl.inc"  ; from ca65 api

.include "debug.inc"

;lib internal api
.autoimport

.export fat_chdir
.export fat_opendir
.export fat_readdir

.export __fat_readdir
.export __fat_readdir_next

.code

;@name: "fat_opendir"
;@in: A/X - pointer to string with the file path
;@out: C, "C=0 on success (A=0), C=1 and A=<error code> otherwise"
;@out: X, "index into fd_area of the opened directory"
;@desc: "open directory by given path starting from directory given as file descriptor"
fat_opendir:
              ldy #O_RDONLY
              jsr fat_open
              bcs @l_exit
              and #DIR_Attr_Mask_Dir	; check for directory
              bne @l_exit
              jsr __fat_free_fd       ; we opened a file. close it immediately and free the allocated fd
              lda #ENOTDIR				    ; error "Not a directory"
              sec
@l_exit:      rts


;in:
;   A/X - pointer to string with the file path
;out:
;	C - C=0 on success (A=0), C=1 and A=error code otherwise
;	X - index into fd_area of the opened directory (which is FD_INDEX_CURRENT_DIR)
;@name: "fat_chdir"
;@in: A, "low byte of pointer to zero terminated string with the file path"
;@in: X, "high byte of pointer to zero terminated string with the file path"
;@out: C, "C=0 on success (A=0), C=1 and A=<error code> otherwise"
;@out: X, "index into fd_area of the opened directory (which is FD_INDEX_CURRENT_DIR)"
;@desc: "change current directory"
fat_chdir:
              jsr fat_opendir
              bcs @l_exit
              jsr __fat_free_fd         ; free fd immediately
              ldy #FD_INDEX_TEMP_FILE   ; open success, FD_INDEX_TEMP_FILE still contains the data from last opened file
              ldx #FD_INDEX_CURRENT_DIR
              jsr __fat_clone_fd				; therefore we can simply clone the opened fd to current dir fd - FTW!
@l_exit:      debug "f cd <"
              rts


;@desc: readdir expects a pointer in A/Y to store the next F32DirEntry structure representing the next FAT32 directory entry in the directory stream pointed of directory X.
;@name: fat_readdir
;@in: X - file descriptor to fd_area of the directory
;@in: A/Y - pointer to target buffer which must be .sizeof(F32DirEntry)
;@out: C - C = 0 on success (A=0), C = 1 and A = <error code> otherwise. C=1/A=EOK if end of directory is reached
fat_readdir:
              sta __volatile_ptr
              sty __volatile_ptr+1

              lda fd_area+F32_fd::Attr, x
              and #DIR_Attr_Mask_Dir		; is directory?
              bne @l_read_dir
              lda #ENOTDIR
@l_exit_eod:  cmp #ENOENT
              bne @l_exit
              lda #EOK
@l_exit:      sec
              rts

@l_read_dir:  jsr __fat_readdir
              bcs @l_exit_eod
              ldy #.sizeof(F32DirEntry)
:             lda (dirptr),y
              sta (__volatile_ptr),y
              dey
              bpl :-
__fat_readdir_seek:
              lda #DIR_Entry_Size
              ldy #0
              jmp __fat_add_seekpos

__fat_readdir_next:
              jsr __fat_readdir_seek
__fat_readdir:
              jsr __fat_prepare_data_block_access_read
              bcs @l_exit
              sta dirptr
              sty dirptr+1

              lda (dirptr)
              beq @l_exit_eod             ; first byte of dir entry is $00 (end of directory)
              cmp #DIR_Entry_Deleted
              beq __fat_readdir_next

              ldy #F32DirEntry::Attr      ; else check if long filename entry
              lda (dirptr),y              ; we are only going to filter those here (or maybe not?)
              cmp #DIR_Attr_Mask_LongFilename
              beq __fat_readdir_next
              clc
@l_exit:      debug16 "f rd <", dirptr
              rts
@l_exit_eod:  lda #ENOENT
              sec ; eod reachead, C=1/A=EOK
              debug16 "f rd eod <", dirptr
              rts
