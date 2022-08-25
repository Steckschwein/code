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


.ifdef DEBUG_FAT32 ; debug switch for this module
	debug_enabled=1
.endif

; TODO OPTIMIZATIONS
;  1. avoid fat block read - calculate fat lba address, but before reading a the fat block, compare the new lba_addr with the previously saved fat_lba
;
.include "zeropage.inc"
.include "common.inc"
.include "fat32.inc"
.include "rtc.inc"
.include "errno.inc"	; from ca65 api
.include "fcntl.inc"	; from ca65 api

.include "debug.inc"

.importzp __volatile_tmp

.autoimport

.export fat_fopen
.export fat_fread_byte
.export fat_fseek
.export fat_find_first, fat_find_next
.export fat_close_all, fat_close

.export __fat_init_fdarea

.code

		;	seek n bytes within file denoted by the given FD
		;in:
		;	X	 - offset into fd_area
		;	A/Y - pointer to seek_struct - @see
		;out:
		;	Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_fseek:
		rts

		;in:
		;	X	 - offset into fd_area
		;out:
		;	Z=1 on success (A=0), Z=0 and A=error code otherwise
__fat_fseek:
		;SetVector block_data, read_blkptr
		rts

;in:
;	X - offset into fd_area
;out:
;	C=0 on success and A=<byte>, C=1 on error and A=<error code> or C=1 and A=0 (EOK) if EOF reached
fat_fread_byte:

		_is_file_open	; otherwise rts C=1 and A=#EINVAL
		_is_file_dir  	; otherwise rts C=1 and A=#EISDIR

		_cmp32_x fd_area+F32_fd::seek_pos, fd_area+F32_fd::FileSize, :+
		lda #EOK
		rts ; exit - EOK (0) and C=1

:		jsr __fat_prepare_access
		bcs @l_exit

		lda (__volatile_ptr)
		_inc32_x fd_area+F32_fd::seek_pos		
		clc
@l_exit:
		debug "rd_ex"
		rts

.export __fat_prepare_access
__fat_prepare_access:
		; TODO FIXME - dirty check - the block_data may be corrupted if there where a read from another fd in between
		lda fd_area+F32_fd::seek_pos+1,x
		and #$01				 			; mask
		ora fd_area+F32_fd::seek_pos+0,x	; and test whether seek_pos is at the begin of a block (multiple of $0200) ?
		bne @l_read_byte

		lda fd_area+F32_fd::offset+0,x
		cmp volumeID+VolumeID::BPB_SecPerClus  	; last block of cluster reached?
		bne @l_read_block						; no, go on reading...
		
		jsr __fat_next_cln		; select next cluster within chain
		bcs @l_exit				; exit on error or EOC (C=1)
@l_read_block:
		jsr __calc_lba_addr
		jsr __fat_read_block_data
		bcs @l_exit
		inc fd_area+F32_fd::offset+0,x	; block number in cluster
@l_read_byte:
		lda fd_area+F32_fd::seek_pos+0,x
		sta __volatile_ptr+0
		lda fd_area+F32_fd::seek_pos+1,x
		and #$01
		ora #>block_data
		sta __volatile_ptr+1
		clc
@l_exit:
		rts

; in:
;	A/X - pointer to zero terminated string with the file path
;	  Y - file mode constants
;		O_RDONLY	= $01
;		O_WRONLY	= $02
;		O_RDWR		= $03
;		O_CREAT		= $10
;		O_TRUNC		= $20
;		O_APPEND	= $40
;		O_EXCL		= $80
; out:
;	.X - index into fd_area of the opened file
;	C=0 on success (A=0), C=1 and A=error code otherwise
fat_fopen:
		sty __volatile_tmp				; save open flag
		ldy #FD_INDEX_CURRENT_DIR		; use current dir fd as start directory
		jsr __fat_open_path
		bne @l_error
		lda fd_area + F32_fd::Attr, x
		and #DIR_Attr_Mask_Dir			; regular file or directory?
		beq @l_atime					; not dir, update atime if desired, exit ok
		lda #EISDIR						; was directory, we must not free any fd
	;	bra @l_exit_err					; exit with error "Is a directory"
@l_error:
		cmp #ENOENT						; no such file or directory ?
		bne @l_exit_err					; other error, then exit
		lda __volatile_tmp				; check if we should create a new file
		and #O_CREAT | O_WRONLY | O_APPEND ; | O_TRUNC
		bne :+
		lda #ENOENT						; no "write" flags set, exit with ENOENT
@l_exit_err:
		sec
		rts

:		debug "r+"
		copypointer dirptr, s_ptr2
		jsr string_fat_name				; build fat name upon input string (filenameptr)
		bne @l_exit_err
		jsr __fat_alloc_fd				; alloc a fd for the new file we want to create to make sure we get one before
		bne @l_exit_err					; we do any sd block writes which may result in various errors
		
		lda __volatile_tmp				; save file open flags
		sta fd_area + F32_fd::flags, x
		lda #DIR_Attr_Mask_Archive		; create as regular file with archive bit set
		jsr __fat_set_fd_attr_dirlba	; update dir lba addr and dir entry number within fd from lba_addr and dir_ptr which where setup during __fat_opendir_cwd from above
		jsr __fat_write_dir_entry		; create dir entry at current dirptr
		bcc @l_exit_ok
		jmp fat_close					; free the allocated file descriptor if there where errors, C=1 and A are preserved
@l_atime:
;		jsr __fat_set_direntry_modify_datetime
;		lda #EOK								; A=0 (EOK)
		clc
@l_exit_ok:
		debug "fop"
		rts

fat_close_all:
		ldx #(2*FD_Entry_Size)	; skip first 2 entries, they're reserved for current and temp dir
__fat_init_fdarea:
		lda #$ff
@l1:
		sta fd_area + F32_fd::CurrentCluster, x
		inx
		cpx #(FD_Entry_Size*FD_Entries_Max)
		bne @l1
		rts

		; free file descriptor quietly
		; in:
		;	X - offset into fd_area
fat_close = __fat_free_fd

		; find first dir entry
		; in:
		;	X - file descriptor (index into fd_area) of the directory
		;	filenameptr	- with file name to search
		; out:
		;	Z=1 on success (A=0), Z=0 and A=error code otherwise
		;	C=1 if found and dirptr is set to the dir entry found (requires Z=1), C=0 otherwise
fat_find_first:
		txa										; use the given fd as source (Y)
		tay
		ldx #FD_INDEX_TEMP_DIR					; we use the temp dir with a copy of given fd, cause F32_fd::CurrentCluster is adjusted if end of cluster is reached
		jsr __fat_clone_fd
		jmp __fat_find_first_mask

fat_find_next = __fat_find_next
