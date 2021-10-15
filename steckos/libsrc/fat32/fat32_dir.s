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
.include "errno.inc"	; from ca65 api
.include "fcntl.inc"	; from ca65 api

.include "debug.inc"

;lib internal api
.import __fat_isroot
.import __fat_init_fd
.import __fat_free_fd
.import __fat_alloc_fd
.import __fat_set_fd_direntry
.import __fat_open_path
.import __fat_find_first
.import __fat_find_first_mask
.import __fat_find_next
.import __fat_clone_fd
.import __fat_clone_cd_td

.import __calc_lba_addr

.import string_fat_name, fat_name_string, put_char
.import string_fat_mask
.import dirname_mask_matcher, cluster_nr_matcher
.import path_inverse

.export fat_chdir
.export fat_get_root_and_pwd
.export __fat_opendir_cwd

.code

; open directory by given path starting from current directory
;in:
;	A/X - pointer to string with the file path
;out:
;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
;	X - index into fd_area of the opened directory - !!! ATTENTION !!! X is exactly the FD_INDEX_TEMP_DIR on success
__fat_opendir_cwd:
		ldy #FD_INDEX_CURRENT_DIR	; clone current dir fd to temp dir fd
		; open directory by given path starting from directory given as file descriptor
		; in:
	  	;	A/X - pointer to string with the file path
		;	Y 	- the file descriptor of the base directory which should be used, defaults to current directory (FD_INDEX_CURRENT_DIR)
	  	; out:
		;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
	  	;	X - index into fd_area of the opened directory - !!! ATTENTION !!! X is exactly the FD_INDEX_TEMP_DIR on success
__fat_opendir:
		jsr __fat_open_path
		bne @l_exit					; exit on error
		lda fd_area + F32_fd::Attr, x
		and #DIR_Attr_Mask_Dir	; check that there is no error and we have a directory
		beq @l_exit_close
		lda #EOK						; ok
@l_exit:
		debug "fod"
		rts
@l_exit_close:
		lda #ENOTDIR				; error "Not a directory"
		jmp __fat_free_fd			; not a directory, so we opened a file. just close them immediately and free the allocated fd

		;in:
		;	A/X - pointer to the result buffer
		;	Y	- size of result buffer
		;out:
		;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_get_root_and_pwd:
		sta	fat_tmp_dw2
		stx	fat_tmp_dw2+1
;		tya
;		eor	#$ff
		;sta	krn_ptr3					;TODO FIXME - length check of output buffer, save -size-1 for easy loop
		SetVector block_fat, krn_ptr3		;TODO FIXME - we use the 512 byte fat block buffer as temp space - FTW!
		stz krn_tmp3

		jsr __fat_clone_cd_td							; start from current directory, clone the cd fd

@l_rd_dir:
		lda #'/'										; put the / char to result string
		jsr put_char
		ldx #FD_INDEX_TEMP_DIR							; if root, exit to inverse the path string
		jsr __fat_isroot
		beq @l_inverse
		m_memcpy fd_area+FD_INDEX_TEMP_DIR+F32_fd::CurrentCluster, fat_tmp_dw, 4	; save the cluster from the fd of the "current" dir which is stored in FD_INDEX_TEMP_DIR (see clone above)
		lda #<l_dot_dot
		ldx #>l_dot_dot
		ldy #FD_INDEX_TEMP_DIR									; call opendir function with "..", on success the fd (FD_INDEX_TEMP_DIR) was updated and points to the parent directory
		jsr __fat_opendir
		bne @l_exit
		SetVector cluster_nr_matcher, fat_vec_matcher	; set the matcher strategy to the cluster number matcher
		jsr __fat_find_first										; and call find first to find the entry with that cluster number we saved in fat_tmp_dw before we did the cd ".."
		bcc @l_exit
		jsr fat_name_string										; found, dirptr points to the entry and we can simply extract the name - fat_name_string formats and appends the dir entry name:attr
		bra @l_rd_dir												; go on with bottom up walk until root is reached
@l_inverse:
		copypointer fat_tmp_dw2, krn_ptr2					; fat_tmp_dw2 is the pointer to the result string, given by the caller (eg. pwd.prg)
		jsr path_inverse								; since we captured the dir entry names bottom up, the path segments are in inverse order, we have to inverse them per segment and write them to the target string
		lda #EOK										; that's it...
@l_exit:
		rts
l_dot_dot:
		.asciiz ".."

;in:
;	A/X - pointer to string with the file path
;out:
;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
;	X - index into fd_area of the opened directory (which is FD_INDEX_CURRENT_DIR)
fat_chdir:
		jsr __fat_opendir_cwd
		bne @l_exit
		ldy #FD_INDEX_TEMP_DIR		  ; the temp dir fd is now set to the last dir of the path and we proofed that it's valid with the code above
		ldx #FD_INDEX_CURRENT_DIR
		jsr __fat_clone_fd				; therefore we can simply clone the temp dir to current dir fd - FTW!
		lda #EOK						; ok
@l_exit:
		debug "fcd"
		rts
