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


.ifdef DEBUG_FAT32_WRITE ; debug switch for this module
	debug_enabled=1
.endif

.include "zeropage.inc"
.include "common.inc"
.include "fat32.inc"
.include "rtc.inc"
.include "errno.inc"	; from ca65 api
.include "fcntl.inc"	; from ca65 api
.include "debug.inc"

.export __fat_write_dir_entry
.export fat_mkdir
.export fat_rmdir
.export fat_unlink
.export fat_write

.import string_fat_name
.import write_block
.import rtc_systime_update

.import __fat_read_cluster_block_and_select
.import __fat_set_fd_attr_dirlba
.import __fat_alloc_fd
.import __fat_opendir_cwd
.import __fat_free_fd
.import __fat_read_block
.import __fat_isroot
.import __fat_find_next
.import __fat_find_first_mask

.import __calc_lba_addr
.import __calc_blocks
.import __inc_lba_address

.import fat_fopen
.importzp __volatile_ptr

; in:
;	A - byte to write
;	X - offset into fd_area
; out:
;	C=0 on success and A=<byte>, C=1 on error and A=<error code> or C=1 and A=0 (EOK) if EOF reached
fat_write_byte:

		_is_file_open ; otherwise rts C=1 and A=#EINVAL

		pha
		SetVector block_data, write_blkptr
		lda fd_area+F32_fd::seek_pos+1,x
		and #$01
;		bne l_read_h							; 2nd half block?
		lda fd_area+F32_fd::seek_pos+0,x	; check whether seek pos points to start of block
;		bne l_read

		ldy fd_area+F32_fd::seek_pos+0, x
		pla
		sta (write_blkptr),y

		_inc32_x fd_area+F32_fd::FileSize
		_inc32_x fd_area+F32_fd::seek_pos

		clc

		rts

; in:
;	X - offset into fd_area
;	write_blkptr - set to the address with data we have to write
; out:
;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_write:
		_is_file_open ; otherwise rts C=1 and A=#EINVAL

		lda fd_area + F32_fd::Attr, x
		bit #DIR_Attr_Mask_Dir							; regular file?
		beq @l_isfile
@l_exit_einval:
		lda #EINVAL
		rts
@l_isfile:
		jsr __fat_isroot									; check whether the start cluster of the file is the root cluster - @see fat_alloc_fd, fat_open)
		bne @l_write										; if not, we can directly update dir entry and write data afterwards

		jsr __fat_reserve_cluster						; otherwise start cluster is root, we try to find a free cluster
		debug "fw_res_cl"
		bne @l_exit
@l_write:
		jsr __calc_blocks									; calc blocks
		beq @l_direntry									; Z=1 - no blocks to write, but update dir entry
		jsr __calc_lba_addr								; calc lba file payload
		debug32 "fat_wr lb", lba_addr
.ifdef MULTIBLOCK_WRITE
		.warning "SD multiblock writes are EXPERIMENTAL"
		debug16 "fat_wr wp", write_blkptr
		.import sd_write_multiblock
		jsr sd_write_multiblock
.else
@l:	debug16 "fat_wr blks", blocks
		debug16 "fat_wr wp", write_blkptr
		jsr __fat_write_block
		bcs @l_exit
		jsr __inc_lba_address							; increment lba address to write next block
		inc write_blkptr+1
		inc write_blkptr+1
		dec blocks
		bne @l
.endif

@l_direntry:
		jsr __fat_read_direntry							; read dir entry, dirptr is set accordingly
		jsr __fat_set_direntry_cluster				; set cluster number of direntry entry via dirptr - TODO FIXME only necessary on first write
		jsr __fat_set_direntry_filesize				; set filesize of directory entry via dirptr
		jsr __fat_set_direntry_timedate				; set time and date

		; set archive bit
		ldy #F32DirEntry::Attr
		lda #DIR_Attr_Mask_Archive
		ora (dirptr),y
		sta (dirptr),y
		jsr __fat_write_block_data						; lba_addr is already set from read, see above
@l_exit:
		debug16 "fat_wr dirptr", dirptr
		rts

		; read the block with the directory entry of the given file descriptor, dirptr is adjusted accordingly
		; in:
		;	X - file descriptor of the file the directory entry should be read
		; out:
		;	dirptr pointing to the corresponding directory entry of type F32DirEntry
__fat_read_direntry:
		jsr __fat_set_lba_from_fd_dirlba					; setup lba address from fd
		SetVector block_data, read_blkptr
		jsr __fat_read_block									; and read the block with the dir entry
		bne @l_exit

		stz dirptr
		lda fd_area + F32_fd::DirEntryPos, x			; setup dirptr
		lsr
		ror dirptr
		ror
		ror dirptr
		ror
		ror dirptr

		clc
		adc #>block_data
		sta dirptr+1

		lda #EOK
@l_exit:
		rts

		; in:
		;	X - file descriptor
		; out:
		;	lba_addr setup with direntry lba
__fat_set_lba_from_fd_dirlba:
		lda fd_area + F32_fd::DirEntryLBA+3 , x				; set lba addr of dir entry...
		sta lba_addr+3
		lda fd_area + F32_fd::DirEntryLBA+2 , x
		sta lba_addr+2
		lda fd_area + F32_fd::DirEntryLBA+1 , x
		sta lba_addr+1
		lda fd_area + F32_fd::DirEntryLBA+0 , x
		sta lba_addr+0
		debug32 "fw_slba", lba_addr
		rts

		; write new timestamp to direntry entry given as dirptr
		; in:
		;	dirptr
__fat_set_direntry_timedate:
		phx
		jsr rtc_systime_update									; update systime struct
		;TODO FIXME rtx may be #EBUSY
		jsr __fat_rtc_time

		ldy #F32DirEntry::WrtTime
		sta (dirptr), y
		txa
		iny ; #F32DirEntry::WrtTime+1
		sta (dirptr), y

		jsr __fat_rtc_date
		ldy #F32DirEntry::WrtDate+0
		sta (dirptr), y
		ldy #F32DirEntry::LstModDate+0
		sta (dirptr), y
		txa
		ldy #F32DirEntry::WrtDate+1
		sta (dirptr), y
		ldy #F32DirEntry::LstModDate+1
		sta (dirptr), y
		plx
		rts

__fat_set_direntry_filesize:
		lda fd_area + F32_fd::FileSize+3,x
		ldy #F32DirEntry::FileSize+3
		debug "fs3"
		sta (dirptr),y
		lda fd_area + F32_fd::FileSize+2,x
		dey
		debug "fs2"
		sta (dirptr),y
		lda fd_area + F32_fd::FileSize+1,x
		dey
		debug "fs1"
		sta (dirptr),y
		lda fd_area + F32_fd::FileSize+0,x
		dey
		debug "fs0"
		sta (dirptr),y
		rts

		; copy cluster number from file descriptor to direntry given as dirptr
		; in:
		;	dirptr
__fat_set_direntry_cluster:
		ldy #F32DirEntry::FstClusHI+1
		lda fd_area + F32_fd::CurrentCluster+3 , x
		sta (dirptr), y
		dey
		lda fd_area + F32_fd::CurrentCluster+2 , x
		sta (dirptr), y

		ldy #F32DirEntry::FstClusLO+1
		lda fd_area + F32_fd::CurrentCluster+1 , x
		sta (dirptr), y
		dey
		lda fd_area + F32_fd::CurrentCluster+0 , x
		sta (dirptr), y
		rts

; delete a directory entry denoted by given path in A/X
;in:
;	A/X - pointer to the directory path
; out:
;	C=0 on success, C=1 and A=error code otherwise
fat_rmdir:
		jsr __fat_opendir_cwd
		bne @l_exit
		debugdirentry
		jsr __fat_is_dot_dir
		beq @l_err_einval
		jsr __fat_dir_isempty
		bcs @l_exit
		jmp __fat_unlink
@l_err_einval:
		lda #EINVAL
		sec
@l_exit:
		debug "rmdir"
		rts

; in:
; 	A/X - pointer to the directory name
; out:
;	C=0 on success (A=0), C=1 on error and A=error code otherwise
fat_mkdir:
		jsr __fat_opendir_cwd
		beq @l_exit_eexist							; open success, dir exists already
:		cmp #ENOENT										; we expect 'no such file or directory' error, otherwise a file with same name already exists
		bne @l_exit_err								; exit on other error

		copypointer dirptr, krn_ptr2
		jsr string_fat_name							; build fat name upon input string (filenameptr) and store them directly to current dirptr!
		bne @l_exit_err
		jsr __fat_alloc_fd							; alloc a fd for the new directory - try to allocate a new fd here, right before any fat writes, cause they may fail
		bne @l_exit_err								; and we want to avoid an error in between the different block writes
		lda #DIR_Attr_Mask_Dir						; set type directory
		jsr __fat_set_fd_attr_dirlba				; update dir lba addr and dir entry number within fd from lba_addr and dir_ptr which where setup during __fat_opendir_cwd from above
		jsr __fat_reserve_cluster					; try to find and reserve next free cluster and store them in fd_area at fd (X)
		bcs @l_exit_close								; C=1 - fail, exit but close fd
		jsr __fat_set_lba_from_fd_dirlba			; setup lba_addr from fd
		jsr __fat_write_dir_entry					; create dir entry at current dirptr
		bcs @l_exit_close
		jsr __fat_write_newdir_entry				; write the data of the newly created directory with prepared data from dirptr
@l_exit_close:
		jmp __fat_free_fd								; A and C are preserved
@l_exit_eexist:
		lda #EEXIST										; exists already
@l_exit_err:
		sec
		debug "fat_mkdir"
		rts

		; in:
		;	X - file descriptor of directory
		; out:
		;	C=0 if directory is empty or contains <=2 entries ("." and ".."), C=1 otherwise
__fat_dir_isempty:
		phx
		jsr __fat_count_direntries
		cmp #3							; >= 3 dir entries, must be more then only the "." and ".."
		bcc @l_exit
		lda #ENOTEMPTY
@l_exit:
		plx
		rts

__fat_count_direntries:
		stz krn_tmp3
		SetVector @l_all, filenameptr
		jsr __fat_find_first_mask		; find within dir given in X
		bcc @l_exit
@l_next:
		lda (dirptr)
		cmp #DIR_Entry_Deleted
		beq @l_find_next
		inc	krn_tmp3
@l_find_next:
		jsr __fat_find_next
		bcs	@l_next
@l_exit:
		lda krn_tmp3
		debug "f_cnt_d"
		rts
@l_all:
		.asciiz "*.*"


; write new dir entry to dirptr and set new end of directory marker
; in:
;	X - file descriptor of the new dir entry within fd_area
;	dirptr - set to current dir entry within block_data
; out:
;	C=0 on success, C=1 on error and A=<error code>
__fat_write_dir_entry:
		jsr __fat_prepare_dir_entry
		debug16 "f_w_dp", dirptr

		;TODO FIXME duplicate code here! - @see __fat_find_next:
		lda dirptr+1
		sta krn_ptr1+1
		lda dirptr														; create the end of directory entry
		clc
		adc #DIR_Entry_Size
		sta krn_ptr1
		bcc @l2
		inc krn_ptr1+1
@l2:
		lda krn_ptr1+1 												; end of block reached? :/ edge-case, we have to create the end-of-directory entry at the next block
		cmp #>(block_data + sd_blocksize)
		beq @l_new_block												; yes, prepare new block
		lda #0															; no, write the updated block only
		sta (krn_ptr1)													; set eod
		bra @l_eod
@l_new_block:															; new dir entry
		jsr __fat_write_block_data					  				; write the current block with the updated dir entry first
		bcs @l_exit

		ldy #$7f															; safely, fill the new dir block with 0 to mark eod
		lda #0
@l_erase:
		sta block_data+$000, y
		sta block_data+$080, y
		sta block_data+$100, y
		sta block_data+$180, y
		dey
		bpl @l_erase
		;TODO FIXME test end of cluster, if so reserve a new one, update cluster chain for directory ;)
		debug32 "eod_lba", lba_addr
		debug32 "eod_cln", fd_area+FD_INDEX_TEMP_DIR
		jsr __inc_lba_address										; increment lba address to write to next block
@l_eod:
		;TODO FIXME erase the rest of the block, currently 0 is assumed
		jsr __fat_write_block_data									; write the updated dir entry to device
@l_exit:
		debug "f_wde"
		rts


; free cluster and maintain the fsinfo block
; in:
;	X - the file descriptor into fd_area (F32_fd::CurrentCluster)
; out:
;	C=0 on success, C=1 on error and A=error code
__fat_free_cluster:
		jsr __fat_read_cluster_block_and_select	; Y offset in block
		bne l_exit				; read error
		bcc l_exit				; EOC? (C=1) expected here in order to free - TODO FIXME cluster chain during deletion not supported yet
		lda #1
		sta krn_tmp
		lda #0
		bra _fat_update_cluster
l_exit:
		rts
; find and reserve next free cluster and maintains the fsinfo block
; in:
;	X - the file descriptor into fd_area where the found cluster should be stored
; out:
;	C=0 on success, C=1 otherwise and A=error code
__fat_reserve_cluster:
		jsr __fat_find_free_cluster				; find free cluster, stored in fd_area for the fd given within X
		bcs l_exit
		lda #$ff
		sta krn_tmp

_fat_update_cluster:
		jsr __fat_mark_cluster						; mark cluster in fat block eihter with EOC (0x0fffffff) or free 0x00000000
		jsr __fat_write_fat_blocks					; write the updated fat block for 1st and 2nd FAT to the device
		bcs l_exit										; exit on error, otherwise fall through and update the fsinfo sector/block
		;TODO check valid fsinfo block
		;TODO check whether clnr is maintained, test 0xFFFFFFFF ?
		;TODO improve calc, currently fixed to cluster-=1
		;TODO update amount of free clusters to be reserved/freed with A [-128...127]
__fat_update_fsinfo:
		m_memcpy fat_fsinfo_lba, lba_addr, 4
		SetVector block_fat, read_blkptr
		jsr __fat_read_block
		bne l_exit
		stz krn_tmp2
		lda krn_tmp
		bpl :+											; cluster reserved?
		dec krn_tmp2 ; 2's complement ($ff)
		ldy fd_area+F32_fd::CurrentCluster+0,x
	 	sty block_fat+F32FSInfo::LastClus+0
		ldy fd_area+F32_fd::CurrentCluster+1,x
	 	sty block_fat+F32FSInfo::LastClus+1
		ldy fd_area+F32_fd::CurrentCluster+2,x
	 	sty block_fat+F32FSInfo::LastClus+2
		ldy fd_area+F32_fd::CurrentCluster+3,x
	 	sty block_fat+F32FSInfo::LastClus+3
:		debug32 "fs_info", block_fat+F32FSInfo::FreeClus
		clc
		adc block_fat+F32FSInfo::FreeClus+0
		sta block_fat+F32FSInfo::FreeClus+0
		lda block_fat+F32FSInfo::FreeClus+1
		adc krn_tmp2
		sta block_fat+F32FSInfo::FreeClus+1
		lda block_fat+F32FSInfo::FreeClus+2
		adc krn_tmp2
		sta block_fat+F32FSInfo::FreeClus+2
		lda block_fat+F32FSInfo::FreeClus+3
		adc krn_tmp2
		sta block_fat+F32FSInfo::FreeClus+3
		jmp __fat_write_block_fat

; create the "." and ".." entry of the new directory
; in:
;	.X - the file descriptor into fd_area of the the new dir entry
;	dirptr - set to current dir entry within block_data
; out:
;	C=0 on success, C=1 otherwise and A=error code
__fat_write_newdir_entry:
		ldy #F32DirEntry::Attr																		; copy from (dirptr), start with F32DirEntry::Attr, the name is skipped and overwritten below
@l_dir_cp:
		lda (dirptr), y
		sta block_data+0*.sizeof(F32DirEntry), y												; 1st dir entry
		sta block_data+1*.sizeof(F32DirEntry), y												; 2nd dir entry
		iny
		cpy #.sizeof(F32DirEntry)
		bne @l_dir_cp

		ldy #.sizeof(F32DirEntry::Name) + .sizeof(F32DirEntry::Ext)	-1			; erase name and build the "." and ".." entries
		lda #$20
@l_clr_name:
		sta block_data, y																		; 1st dir entry
		sta block_data+1*.sizeof(F32DirEntry), y										; 2nd dir entry
		dey
		bne @l_clr_name
		lda #'.'
		sta block_data+0*.sizeof(F32DirEntry)+F32DirEntry::Name+0				; 1st entry "."
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::Name+0				; 2nd entry ".."
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::Name+1

		ldy #FD_INDEX_TEMP_DIR													; due to fat_opendir/fat_open within fat_mkdir the fd of temp dir (FD_INDEX_TEMP_DIR) represents the last visited directory which must be the parent of this one ("..") - FTW!
		debug32 "cd_cln", fd_area + FD_INDEX_TEMP_DIR + F32_fd::CurrentCluster
		lda fd_area+F32_fd::CurrentCluster+0,y
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusLO+0
		lda fd_area+F32_fd::CurrentCluster+1,y
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusLO+1
		lda fd_area+F32_fd::CurrentCluster+2,y
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusHI+0
		lda fd_area+F32_fd::CurrentCluster+3,y
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusHI+1

		ldy #$7f
		lda #$00
@l_1st_block:
		sta block_data+2*.sizeof(F32DirEntry), y								; all dir entries, but "." and ".." (+2), are set to 0
		sta block_data+$080, y
		sta block_data+$100, y
		sta block_data+$180, y
		dey
		bpl @l_1st_block

		jsr __calc_lba_addr
		jsr __fat_write_block_data
		bcs @l_exit

		m_memset block_data, 0, 2*.sizeof(F32DirEntry)							; now erase the "." and ".." entries too
		ldy volumeID+ VolumeID:: BPB + BPB::SecPerClus							; Y = VolumeID::SecPerClus - reamining blocks of the cluster with empty dir entries
		debug32 "er_d", lba_addr
		bra @l_remain_blocks_e
@l_remain_blocks:
		jsr __inc_lba_address												; next block within cluster
		jsr __fat_write_block_data
		bcs @l_exit
@l_remain_blocks_e:
		dey
		bne @l_remain_blocks													; write until 0 (VolumeID::SecPerClus) reached
@l_exit:
		debug "fat_wr_nd"
		rts

__fat_write_fat_blocks:
		jsr __fat_write_block_fat			; lba_addr is already setup by __fat_find_free_cluster
		bcs @err_exit
		clc										; calc fat2 lba_addr = lba_addr + VolumeID::FATSz32
		.repeat 4, i
			lda lba_addr + i
			adc volumeID + VolumeID::EBPB + EBPB::FATSz32 + i
			sta lba_addr + i
		.endrepeat
		jsr __fat_write_block_fat				; write to fat mirror (fat2)
@err_exit:
		debug "fw_blocks"
		rts

; return C=0 on success, C=1 otherwise
__fat_write_block_fat:
		phy
		ldy #>block_fat
		bra __fat_write_block_ptr
__fat_write_block_data:
		phy
		ldy #>block_data
.ifdef FAT_DUMP_FAT_WRITE
		debugdump "fat_wb dmp", block_fat
.endif
__fat_write_block_ptr:
		lda write_blkptr
		pha
		lda write_blkptr+1
		pha
		jsr :+
		ply
		sty write_blkptr+1
		ply
		sty write_blkptr
		ply
		rts

:		sty write_blkptr+1
		stz write_blkptr	;page aligned
__fat_write_block:
.ifndef FAT_NOWRITE
		debug32 "f_wr lba", lba_addr
		debug16 "f_wr wpt", write_blkptr
		phx
		jsr write_block
		dec write_blkptr+1		; TODO FIXME clarification with TW - write_block increments write_blkptr highbyte - which is a sideeffect and should be avoided
		plx
		cmp #EOK
		bne :+
		clc
		rts
.else
		lda #EOK
.endif
:		sec
		rts

__fat_rtc_high_word:
		lsr
		ror	krn_tmp2
		lsr
		ror	krn_tmp2
		lsr
		ror	krn_tmp2
		ora krn_tmp
		tax
		rts

		; out:
		;	.A/.X with time from rtc struct in fat format
__fat_rtc_time:
		stz krn_tmp2
		lda rtc_systime_t+time_t::tm_hour							; hour
		asl
		asl
		asl
		sta krn_tmp
		lda rtc_systime_t+time_t::tm_min								; minutes 0..59
		jsr __fat_rtc_high_word
		lda rtc_systime_t+time_t::tm_sec								; seconds/2
		lsr
		ora krn_tmp2
		rts

		; out
		;	A/X with date from rtc struct in fat format
__fat_rtc_date:
		stz krn_tmp2
		lda rtc_systime_t+time_t::tm_year							; years since 1900
		sec
		sbc #80																; fat year is 1980..2107 (bit 15-9), we have to adjust 80 years
		asl
		sta krn_tmp
		lda rtc_systime_t+time_t::tm_mon								; month from rtc is (0..11), adjust +1
		inc
		jsr __fat_rtc_high_word
		lda rtc_systime_t+time_t::tm_mday							; day of month (1..31)
		ora krn_tmp2
		rts

		; prepare dir entry, expects cluster number set in fd_area of newly allocated fd given in X
		; in:
		;	X - file descriptor
		;	dirptr of the directory entry to prepare
__fat_prepare_dir_entry:
		lda fd_area + F32_fd::Attr, x
		ldy #F32DirEntry::Attr										; store attribute
		sta (dirptr), y

		lda #0
		ldy #F32DirEntry::Reserved									; unused
		sta (dirptr), y
		ldy #F32DirEntry::CrtTimeMillis
		sta (dirptr), y												; ms to 0, ms not supported by rtc

		jsr __fat_set_direntry_timedate

		ldy #F32DirEntry::WrtTime									; creation date/time copy over from modified date/time
		lda (dirptr),y
		ldy #F32DirEntry::CrtTime
		sta (dirptr),y
		ldy #F32DirEntry::WrtTime+1
		lda (dirptr),y
		ldy #F32DirEntry::CrtTime+1
		sta (dirptr),y

		ldy #F32DirEntry::WrtDate
		lda (dirptr),y
		ldy #F32DirEntry::CrtDate
		sta (dirptr),y
		ldy #F32DirEntry::WrtDate+1
		lda (dirptr),y
		ldy #F32DirEntry::CrtDate+1
		sta (dirptr),y

		jsr __fat_set_direntry_cluster
		jmp __fat_set_direntry_filesize

; mark cluster according to A
; in:
;	A - 0x00 free, 0xff EOC
;	Y - offset in block
; 	read_blkptr - points to block_fat either 1st or 2nd page
__fat_mark_cluster: ; TODO cluster chain support
		sta (read_blkptr), y
		iny
		sta (read_blkptr), y
		iny
		sta (read_blkptr), y
		iny
		and #$0f
		sta (read_blkptr), y
		rts

; in:
;	X - file descriptor
; out:
;	C=0 on success
;		Y=offset in block_fat of found cluster
;		lba_addr with fat block where the found cluster resides
;		the found cluster is stored within the given file descriptor (fd_area+F32_fd::CurrentCluster,x)
;	C=1 on error, A=error code
__fat_find_free_cluster:
		;TODO improve, use a previously saved lba_addr and/or found cluster number
		stz lba_addr+3			; TODO FIXME we assume that 16 bit are sufficient for fat lba address
		stz lba_addr+2			;
		lda fat_lba_begin+1	; init lba_addr with fat_begin lba addr
		sta lba_addr+1
		lda fat_lba_begin+0
		sta lba_addr+0

		SetVector block_fat, read_blkptr
@next_block:
		jsr __fat_read_block	; read fat block
		bne @l_exit_err

		ldy #0
@l1:	lda block_fat+0,y			; 1st page find cluster entry with 00 00 00 00
		ora block_fat+1,y
		ora block_fat+2,y
		ora block_fat+3,y
		beq @l_found_lb			; branch, A=0 here
		lda block_fat+$100+0,y	; 2nd page find cluster entry with 00 00 00 00
		ora block_fat+$100+1,y
		ora block_fat+$100+2,y
		ora block_fat+$100+3,y
		beq @l_found_hb
		iny
		iny
		iny
		iny
		bne @l1
		jsr __inc_lba_address; inc lba_addr, next fat block
		lda lba_addr+1			; end of fat reached?
		cmp fat2_lba_begin+1	; cmp with fat2_begin_lba
		bne @next_block
		lda lba_addr+0
		cmp fat2_lba_begin+0
		bne @next_block
		lda #ENOSPC				; end reached, answer ENOSPC () - "No space left on device"
@l_exit_err:
		sec
	 	debug32 "free_cl", fd_area+(2*.sizeof(F32_fd)) + F32_fd::CurrentCluster ; almost the 3rd entry
		rts
@l_found_hb: ; found in "high" block (2nd page of the sd_blocksize)
		lda #>(block_fat+$100)	; set read_blkptr to begin 2nd page of fat_buffer - @see __fat_mark_free_cluster
		sta read_blkptr+1
		lda #$40				; adjust clnr with +$40 (256 / 4 byte/clnr) clusters since it was found in 2nd page
		debug "fat_ffc_hb"
@l_found_lb:				; A=0 here, if called from above
		sta fd_area+F32_fd::CurrentCluster+0, x
		tya
		lsr						; offset Y>>2 (div 4, 32 bit clnr)
		lsr
		adc fd_area+F32_fd::CurrentCluster+0, x	; C=0 here always, y is multiple of 4 and 2 lsr
		sta fd_area+F32_fd::CurrentCluster+0, x	; safe clnr
		debug32 "fc_tmp2", fd_area+(2*.sizeof(F32_fd)) + F32_fd::CurrentCluster ; hart debug 3rd entry

		;m_memcpy lba_addr, safe_lba TODO FIXME fat lba address, reuse them at next search
		; to calc them we have to clnr = (block number * 512) / 4 + (Y / 4) => (lba_addr - fat_lba_begin) << 7 + (Y>>2)
		; to avoid the <<7, we simply <<8 and do one ror - FTW!
		sec
		lda lba_addr+0
		sbc fat_lba_begin+0
		sta krn_tmp				; save A
		lda lba_addr+1
		sbc fat_lba_begin+1		; now we have 16bit blocknumber
		lsr						; clnr = blocks<<7
		sta fd_area+F32_fd::CurrentCluster+2, x
		lda krn_tmp				; restore A
		ror
		sta fd_area+F32_fd::CurrentCluster+1, x
		lda #0
		ror						; clnr += Y>>2 (offset within block) - already saved in F32_fd::CurrentCluster+0, x s.above
		adc fd_area+F32_fd::CurrentCluster+0, x
		sta fd_area+F32_fd::CurrentCluster+0, x
		lda #0					; exit found
		sta fd_area+F32_fd::CurrentCluster+3, x
		clc ; found, C=0 success
		rts

; unlink a file denoted by given path in A/X
; in:
;	A/X - pointer to string with the file path
; out:
;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_unlink:
		ldy #O_RDONLY
		jsr fat_fopen		; try to open as regular file
		bne @l_exit
		jsr __fat_unlink
		debug "unlnk"
		jmp __fat_free_fd
@l_exit:
		rts

__fat_unlink:
		jsr __fat_isroot							; is root or no clnr assigned yet, file was just touched
		beq @l_unlink_direntry					; ... then we can skip freeing clusters from fat

		jsr __fat_free_cluster					; free cluster, update fsinfo
		bcs @l_exit
@l_unlink_direntry:
		jsr __fat_read_direntry					; read the dir entry
		bne @l_exit
		lda #DIR_Entry_Deleted					; mark dir entry as deleted ($e5)
		sta (dirptr)
		jsr __fat_write_block_data				; write back dir entry
@l_exit:
		debug "_ulnk"
		rts

__fat_is_dot_dir:
		lda #'.'
		cmp (dirptr)
		bne @l_exit
		ldy #10
		lda #' '
@l_next:
		cmp (dirptr),y
		bne @l_exit
		dey
		bne @l_next
@l_exit:
		rts
