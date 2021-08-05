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

; external deps - block layer
.import read_block, write_block
; TODO FIXME - encapsulate within sd layer
.import sd_read_multiblock


;lib internal api
.import __fat_read_cluster_block_and_select
.import __fat_isroot
.import __fat_read_block
.import __fat_init_fd
.import __fat_free_fd
.import __fat_alloc_fd
.import __fat_set_fd_attr_direntry
.import __fat_open_path
.import __fat_find_first
.import __fat_find_first_mask
.import __fat_find_next
.import __fat_clone_fd
.import __fat_clone_cd_td
.import __fat_next_cln
.import __fat_write_dir_entry
.import __calc_lba_addr
.import __calc_blocks

.import string_fat_name, fat_name_string, put_char
.import string_fat_mask
.import dirname_mask_matcher, cluster_nr_matcher
.import path_inverse

.export fat_read_block
.export fat_fopen
.export fat_fread ; TODO FIXME update exec, use fat_fread / fat_fread_byte
.export fat_fread_byte
.export fat_read
.export fat_fseek
.export fat_find_first, fat_find_next
.export fat_close_all, fat_close, fat_getfilesize

;.ifdef TEST_EXPORT TODO FIXME - any ideas?
.export __fat_init_fdarea
;.endif

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
		;	C=1 on success and A=<byte>, C=0 on error, A=<error code>
fat_fread_byte:
		_is_file_open l_exit_einval

		_cmp32_x fd_area+F32_fd::seek_pos, fd_area+F32_fd::FileSize, :+
		rts ; exit, C=1
:
		SetVector read_blkptr, block_data
		ldy #1
		jsr __fat_fread
		bne l_exit
		cpy #1
		bne l_exit

		lda fd_area+F32_fd::seek_pos+0, x
		tay
:		lda block_data,y

		_inc32_x fd_area+F32_fd::seek_pos

:		sec
		rts

l_exit_einval:
		lda #EINVAL
l_exit:
		clc
     	rts


    	;  TODO FIXME currently we always read until the end of the cluster regardless whether we reached the end of the file. the file size and blocks must be checked
    	;
		;	read n blocks from file denoted by the given FD and maintains FD.offset
		;in:
		;	X - offset into fd_area
		;	Y - number of blocks to read at once - !!!NOTE!!! it's currently limited to $ff
		;	read_blkptr - address where the data of the read blocks should be stored
		;out:
		;	Z=1 on success and A=0 (EOK), Z=0 and A=error code otherwise
		; 	Y - number of blocks which where successfully read
fat_fread:
		_is_file_open l_exit_einval
__fat_fread:
		sty krn_tmp3										; safe requested block number
		stz krn_tmp2										; init counter
@_l_read_loop:
		ldy krn_tmp2
		cpy krn_tmp3
		beq @l_exit_ok

		lda fd_area+F32_fd::offset+0,x
		cmp volumeID+VolumeID::BPB + BPB::SecPerClus  	; last block of cluster reached?
		bne @_l_read											 	; no, go on reading...

		copypointer read_blkptr, krn_ptr1					; backup read_blkptr
		jsr __fat_read_cluster_block_and_select	    ; read fat block of the current cluster
		bne @l_exit_err							; read error...
		bcs @l_exit									; EOC reached?	return ok, and block counter
		jsr __fat_next_cln						; select next cluster
		stz fd_area+F32_fd::offset+0,x		; and reset offset within cluster
		copypointer krn_ptr1, read_blkptr	; restore read_blkptr

@_l_read:
		jsr __calc_lba_addr
		jsr __fat_read_block
		bne @l_exit_err
		inc read_blkptr+1							; read address + $0200 (block size)
		inc read_blkptr+1
		inc fd_area+F32_fd::offset+0,x		; inc block counter
		inc krn_tmp2
		bra @_l_read_loop
@l_exit_einval:
		lda #EINVAL
		rts
@l_exit:
		ldy krn_tmp2
@l_exit_ok:
		lda #EOK														; A=0 (EOK)
@l_exit_err:
		rts

		;	@deprecated - use fat_fread instead, just for backward compatibility
		;
		; read one block, TODO - update seek position within FD
		;in:
		;	X	- offset into fd_area
		;	read_blkptr has to be set to target address - TODO FIXME ptr. parameter
		;out:
		;	Z=1 on success (A=0), Z=0 and A=error code otherwise
		;  X	- number of bytes read
fat_read_block:
		bit fd_area + F32_fd::CurrentCluster+3, x
		bmi @l_err_exit

		jsr __calc_blocks
		jsr __calc_lba_addr
		jmp read_block
@l_err_exit:
		lda #EINVAL
		rts

		;in:
		;	X - offset into fd_area
		;out:
		;	Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_read:
		bit fd_area + F32_fd::CurrentCluster+3, x
		bmi @l_err_exit

		jsr __calc_blocks
		beq @l_exit					; if Z=0, no blocks to read. we return with "EOK", 0 bytes read
		jsr __calc_lba_addr
		jsr sd_read_multiblock
		rts
@l_err_exit:
		lda #EINVAL
@l_exit:
		rts

		; in:
		;	A/X - pointer to zero terminated string with the file path
		;	  Y - file mode constants
		;		O_RDONLY		= $01
		;		O_WRONLY		= $02
		;		O_RDWR		= $03
		;		O_CREAT		= $10
		;		O_TRUNC		= $20
		;		O_APPEND		= $40
		;		O_EXCL		= $80
		; out:
		;	.X - index into fd_area of the opened file
		;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_fopen:
		sty __volatile_tmp				; save open flag
		ldy #FD_INDEX_CURRENT_DIR		; use current dir fd as start directory
		jsr __fat_open_path
		bne @l_error
		lda fd_area + F32_fd::Attr, x
		and #DIR_Attr_Mask_Dir			; regular file or directory?
		beq @l_exit_ok						; not dir, ok
		lda #EISDIR							; was directory, we must not free any fd
		rts									; exit with error "Is a directory"
@l_error:
		cmp #ENOENT							; no such file or directory ?
		bne @l_exit							; other error, then exit
		lda __volatile_tmp				; check if we should create a new file
		and #O_CREAT | O_WRONLY | O_APPEND
		bne :+
		lda #ENOENT							; nothing set, exit with ENOENT
		rts
:
		debug "r+"
		copypointer dirptr, krn_ptr2
		jsr string_fat_name				; build fat name upon input string (filenameptr)
		bne @l_exit
		jsr __fat_alloc_fd				; alloc a fd for the new file we want to create to make sure we get one before
		bne @l_exit							; we do any sd block writes which may result in various errors

		lda #DIR_Attr_Mask_Archive		; create as regular file with archive bit set
		jsr __fat_set_fd_attr_direntry; update dir lba addr and dir entry number within fd
		jsr __fat_write_dir_entry		; create dir entry at current dirptr
		beq @l_exit_ok
		jmp fat_close						; free the allocated file descriptor regardless of any errors
@l_exit_ok:
		lda #EOK								; A=0 (EOK)
@l_exit:
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

		; get size of file in fd
		; in:
		;	x - fd offset
		; out:
		;	.A - filesize lo
		;	.X - filesize hi
fat_getfilesize:
		lda fd_area + F32_fd::FileSize + 0, x
		pha
		lda fd_area + F32_fd::FileSize + 1, x
		tax
		pla
		rts

		; find first dir entry
		; in:
		;	X - file descriptor (index into fd_area) of the directory
		;	filenameptr	- with file name to search
		; out:
		;	Z=1 on success (A=0), Z=0 and A=error code otherwise
		;	C=1 if found and dirptr is set to the dir entry found (requires Z=1), C=0 otherwise
fat_find_first:
		txa											; use the given fd as source (Y)
		tay
		ldx #FD_INDEX_TEMP_DIR					; we use the temp dir with a copy of given fd, cause F32_fd::CurrentCluster is adjusted if end of cluster is reached
		jsr __fat_clone_fd
		jmp __fat_find_first_mask

fat_find_next = __fat_find_next
