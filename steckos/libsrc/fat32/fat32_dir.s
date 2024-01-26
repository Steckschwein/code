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

.code

; open directory by given path starting from directory given as file descriptor
; in:
;	  A/X - pointer to string with the file path
;   Y - file mode constants - see fcntl.inc (cc65)
;     O_RDONLY  = $01
;     O_WRONLY  = $02
;     O_RDWR    = $03
;     O_CREAT   = $10
;     O_TRUNC   = $20
;     O_APPEND  = $40
;     O_EXCL    = $80
; out:
;	  C - C=0 on success (A=0), C=1 and A=<error code> otherwise
;	  X - index into fd_area of the opened directory
fat_opendir:
          jsr fat_open
          bcs @l_exit
          and #DIR_Attr_Mask_Dir	; check that there is no error and we have a directory
          bne @l_exit
          lda #ENOTDIR				    ; error "Not a directory"
          sec                     ; we opened a file. just close it immediately and free the allocated fd
          jmp __fat_free_fd
@l_ok:    lda #EOK
@l_exit:  rts


;in:
;   A/X - pointer to string with the file path
;out:
;   C - C=0 on success (A=0), C=1 and A=error code otherwise
;   X - index into fd_area of the opened directory (which is FD_INDEX_CURRENT_DIR)
fat_chdir:
          ldy #O_RDONLY
          jsr fat_opendir
          bcs @l_exit
          jsr __fat_free_fd         ; free fd immediately
          ldy #FD_INDEX_TEMP_FILE   ; open success, FD_INDEX_TEMP_FILE still contains the data from last opened file
          ldx #FD_INDEX_CURRENT_DIR
          jsr __fat_clone_fd				; therefore we can simply clone the opened fd to current dir fd - FTW!
@l_exit:  debug "fat chdir <"
          rts


;@desc: readdir expects a pointer in A/Y to store the next F32DirEntry structure representing the next FAT32 directory entry in the directory stream pointed of directory X.
;@name: fat_readdir
;@in: X - file descriptor to fd_area of the directory
;@in: A/Y - pointer to target buffer which must be .sizeof(F32DirEntry)
;@out: C - C = 0 on success (A=0), C = 1 and A = <error code> otherwise
fat_readdir:
          sta __volatile_ptr
          sty __volatile_ptr+1

          lda fd_area+F32_fd::Attr, x
          and #DIR_Attr_Mask_Dir		; is directory?
          bne @l_read
          lda #ENOTDIR
          sec
          rts

@l_read:  jsr __fat_prepare_block_access_read
          bcs @l_exit
          sta dirptr
          sty dirptr+1

@l_match: lda (dirptr)
          debug16 "ff rd dirptr", dirptr
          beq @l_enoent               ; first byte of dir entry is $00 (end of directory)
          cmp #DIR_Entry_Deleted
          beq @l_next

          ldy #F32DirEntry::Attr      ; else check if long filename entry
          lda (dirptr),y              ; we are only going to filter those here (or maybe not?)
          cmp #DIR_Attr_Mask_LongFilename
          beq @l_next

          ldy #.sizeof(F32DirEntry)
:         lda (dirptr),y
          sta (__volatile_ptr),y
          dey
          bpl :-
          jmp __fat_seek_next_dirent

@l_next:  jsr __fat_seek_next_dirent
          .assert >block_data & $01 = 0, error, "block_data address must be $0200 aligned!"
          lda dirptr+1 ; block_data start at $?200 ?
          and #$01
          ora dirptr
          beq @l_read
          bra @l_match
@l_enoent:
          lda #ENOENT
          sec ; nothing found C=1 and return
          debug "ff rd exit <"
@l_exit:  rts
