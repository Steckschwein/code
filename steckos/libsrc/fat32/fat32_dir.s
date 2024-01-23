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

.export __fat_opendir
.export __fat_opendir_nofd

.code

; open directory by given path starting from directory given as file descriptor
; in:
;	  A/X - pointer to string with the file path
; out:
;	  C - C=0 on success (A=0), C=1 and A=<error code> otherwise
;	  X - index into fd_area of the opened directory
fat_opendir:
    		  ldy #FD_INDEX_CURRENT_DIR	; clone current dir fd to temp dir fd (in __fat_open_path)
; in:
;	  Y 	- the file descriptor of the base directory which should be used, defaults to current directory (FD_INDEX_CURRENT_DIR)
__fat_opendir:
          jsr __fat_open_path
          bcs @l_exit
          lda fd_area + F32_fd::Attr,x
          and #DIR_Attr_Mask_Dir	; check that there is no error and we have a directory
          bne @l_exit
          lda #ENOTDIR				    ; error "Not a directory"
          sec                     ; we opened a file. just close it immediately and free the allocated fd
          jmp __fat_free_fd
@l_exit:  rts

; out:
;   C - C=0 on success, C=1 on error
;   X - FD_INDEX_TEMP_FILE from __fat_opendir/__fat_open_path
__fat_opendir_nofd:
          jsr __fat_opendir
          bcs @l_exit
          jsr __fat_free_fd
          ldx #FD_INDEX_TEMP_FILE
@l_exit:  rts


;in:
;   A/X - pointer to string with the file path
;out:
;   C - C=0 on success (A=0), C=1 and A=error code otherwise
;   X - index into fd_area of the opened directory (which is FD_INDEX_CURRENT_DIR)
fat_chdir:
          ldy #FD_INDEX_CURRENT_DIR
          jsr __fat_opendir_nofd
          bcs @l_exit
          ldy #FD_INDEX_TEMP_FILE
          ldx #FD_INDEX_CURRENT_DIR
          jsr __fat_clone_fd				; therefore we can simply clone the opened fd to current dir fd - FTW!
@l_exit:
          debug "fat chdir <"
          rts
