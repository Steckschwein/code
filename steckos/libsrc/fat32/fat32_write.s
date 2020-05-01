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

.import __fat_read_cluster_block_and_select
.import __fat_set_fd_attr_direntry
.import __fat_alloc_fd
.import __fat_opendir_cd
.import __fat_free_fd
.import __fat_read_block
.import __fat_isroot
.import __fat_is_open
.import __fat_find_next
.import __fat_find_first_mask

.import __calc_lba_addr
.import __calc_blocks
.import __inc_lba_address
.import __rtc_systime_update

.import fat_open

		; in:
		;	X - offset into fd_area
		;	write_blkptr - set to the address with data we have to write
		; out:
		;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_write:
		debug "fws"
		stx fat_tmp_fd										; save fd

		jsr __fat_is_open
		beq @l_exit_einval								; exit, not open

		lda fd_area + F32_fd::Attr, x
		bit #DIR_Attr_Mask_Dir							; regular file?
		beq @l_isfile
@l_exit_einval:
		lda #EINVAL
		rts
@l_isfile:
		jsr __fat_isroot									; check whether the start cluster of the file is the root cluster - @see fat_alloc_fd, fat_open)
		bne	@l_write										; if not, we can directly update dir entry and write data afterwards
		saveptr write_blkptr								;
		jsr __fat_reserve_cluster						; otherwise start cluster is root, we try to find a free cluster, fat_tmp_fd has to be set
		bne @l_exit
		restoreptr write_blkptr							; restore write ptr
		;debug "fw1"
		ldx fat_tmp_fd										; restore fd, go on with writing data
@l_write:
		jsr __calc_blocks
		jsr __calc_lba_addr								; calc lba and blocks of file payload
.ifdef MULTIBLOCK_WRITE
.warning "SD multiblock writes are EXPERIMENTAL"
		.import sd_write_multiblock
		jsr sd_write_multiblock
.else
@l:
		jsr write_block
		bne @l_exit
		jsr __inc_lba_address							; increment lba address to read next block
		dec blocks
		bne @l
.endif
		ldx fat_tmp_fd										; restore fd
		jsr __fat_read_direntry

		jsr __fat_set_direntry_cluster						; set cluster number of direntry entry via dirptr - TODO FIXME only necessary on first write
		jsr __fat_set_direntry_filesize						; set filesize of directory entry via dirptr
		jsr __fat_set_direntry_timedate						; set time and date

		; set archive bit
		ldy #F32DirEntry::Attr
		lda #DIR_Attr_Mask_Archive
		ora (dirptr),y
		sta (dirptr),y

		jsr __fat_write_block_data							; lba_addr is already set from read, see above
@l_exit:
		;debug16 "f_w_e", dirptr
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

		lda fd_area + F32_fd::DirEntryPos , x			; setup dirptr
		stz dirptr

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
		debug32 "f_slba", lba_addr
		rts

		; write new timestamp to direntry entry given as dirptr
		; in:
		;	dirptr
__fat_set_direntry_timedate:
		phx
		jsr __rtc_systime_update									; update systime struct
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
		lda fd_area + F32_fd::FileSize+3 , x
		ldy #F32DirEntry::FileSize+3
		sta (dirptr),y
		lda fd_area + F32_fd::FileSize+2 , x
		dey
		sta (dirptr),y
		lda fd_area + F32_fd::FileSize+1 , x
		dey
		sta (dirptr),y
		lda fd_area + F32_fd::FileSize+0 , x
		dey
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
		;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_rmdir:
		jsr __fat_opendir_cd
		bne @l_exit
		;debugdirentry
		jsr __fat_isroot
		beq @l_err_root					; cannot delete the root dir ;)
		jsr __fat_is_dot_dir
		beq @l_err_einval
		jsr __fat_dir_isempty
		bcs @l_exit
		jsr __fat_unlink
		bra @l_exit
@l_err_root:
@l_err_einval:
		lda #EINVAL
@l_exit:
		;debug "rmdir"
		rts

		  ; in:
		  ; 	A/X - pointer to the directory name
		; out:
		;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_mkdir:
		jsr __fat_opendir_cd
		beq @err_exists
		cmp #ENOENT										; we expect 'no such file or directory' error, otherwise a file with same name already exists
		bne @l_exit

		copypointer dirptr, krn_ptr2
		jsr string_fat_name							; build fat name upon input string (filenameptr) and store them directly to current dirptr!
		bne @l_exit

		jsr __fat_alloc_fd							; alloc a fd for the new directory - try to allocate a new fd here, right before any fat writes, cause they may fail
		bne @l_exit										; and we want to avoid an error in between the different block writes

		lda #DIR_Attr_Mask_Dir						; set type directory
		jsr __fat_set_fd_attr_direntry			; update dir lba addr and dir entry number within fd from lba_addr and dir_ptr which where setup during __fat_opendir_cd from above
		jsr __fat_reserve_cluster					; try to find and reserve next free cluster and store them in fd_area at fd (X)
		bne @l_exit_close

		jsr __fat_set_lba_from_fd_dirlba			; setup lba_addr from fd
		jsr __fat_write_dir_entry					; create dir entry at current dirptr
		bne @l_exit_close

		jsr __fat_write_newdir_entry				; write the data of the newly created directory with prepared data from dirptr
@l_exit_close:
		jsr __fat_free_fd						 		; free the allocated file descriptor
		bra @l_exit
@err_exists:
		lda	#EEXIST
@l_exit:
		;debug "mkdir"
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
		;debug "f_cnt_d"
		rts
@l_all:
		.asciiz "*.*"


		; write new dir entry to dirptr and set new end of directory marker
		; in:
		;	X - file descriptor
		;	dirptr - set to current dir entry within block_data
		; out:
		;	Z=1 on success, Z=0 otherwise, A=error code
__fat_write_dir_entry:
		jsr __fat_prepare_dir_entry
		;debug16 "f_w_dp", dirptr

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
		bne @l_eod														; no, write one block only

		; new dir entry
		jsr __fat_write_block_data					  				; write the current block with the updated dir entry first
		bne @l_exit
		ldy #$80															; safely, fill the new dir block with 0 to mark eod
@l_erase:; A=0 here
		sta block_data+$000, y
		sta block_data+$080, y
		sta block_data+$100, y
		sta block_data+$180, y
		dey
		bpl @l_erase
		;TODO FIXME test end of cluster, if so reserve a new one, update cluster chain for directory ;)
		;debug32 "eod_lba", lba_addr
		;debug32 "eod_cln", fd_area+FD_INDEX_TEMP_DIR
;		lda lba_addr+0
;		adc #02
;		sbc volumeID+VolumeID::BPB + BPB::SecPerClus
;		lda fd_area+F32_fd::CurrentCluster+0
;		sbc lba_addr+0
		jsr __inc_lba_address												; increment lba address to write to next block
@l_eod:
		;TODO FIXME erase the rest of the block, currently 0 is assumed
		jsr __fat_write_block_data										; write the updated dir entry to device
@l_exit:
		debug "f_wde"
		rts


		; free cluster and maintain the fsinfo block
		; in:
		;	X - the file descriptor into fd_area (F32_fd::CurrentCluster)
		; out:
		;	Z=1 on success, Z=0 otherwise and A=error code
__fat_free_cluster:
		jsr __fat_read_cluster_block_and_select
		bne @l_exit								; read error...
		bcc @l_exit								; TODO FIXME cluster chain during deletion not supported yet - therefore EOC (C=1) expected here !!!
		;debug "f_fc"
		jsr __fat_mark_cluster				; mark cluster as free (A=0)
		jsr __fat_write_fat_blocks			; write back fat blocks
		beq __fat_update_fsinfo_inc		; ok - update fsinfo block
@l_exit:
		rts

		; find and reserve next free cluster and maintains the fsinfo block
		; in:
		;	X - the file descriptor into fd_area where the found cluster should be stored
		; out:
		;	Z=1 on success, Z=0 otherwise and A=error code
__fat_reserve_cluster:
		jsr __fat_find_free_cluster				; find free cluster, stored in fd_area for the fd given within X
		bne @l_exit
		jsr __fat_mark_cluster_eoc					; mark cluster in block with EOC - TODO cluster chain support
		jsr __fat_write_fat_blocks					; write the updated fat block for 1st and 2nd FAT to the device
		beq __fat_update_fsinfo_dec				; ok - update the fsinfo sector/block
@l_exit:
		rts
		;TODO check valid fsinfo block
		;TODO check whether clnr is maintained, test 0xFFFFFFFF ?
		;TODO improve calc, currently fixed to cluster-=1
		;TODO A - update amount of free clusters to be reserved/freed [-128...127]
__fat_update_fsinfo_inc:
		jsr __fat_read_fsinfo
		bne __fat_update_fsinfo_exit
		;debug32 "fi_fcl+", block_fat+F32FSInfo::FreeClus
		_inc32 block_fat+F32FSInfo::FreeClus
		jmp __fat_write_block_fat
__fat_update_fsinfo_dec:
		jsr __fat_read_fsinfo
		bne __fat_update_fsinfo_exit
		;debug32 "fi_fcl-", block_fat+F32FSInfo::FreeClus
		_dec32 block_fat+F32FSInfo::FreeClus
		jmp __fat_write_block_fat
__fat_read_fsinfo:
		m_memcpy fat_fsinfo_lba, lba_addr, 4
		SetVector block_fat, read_blkptr
		jmp __fat_read_block
__fat_update_fsinfo_exit:
		rts


		; create the "." and ".." entry of the new directory
		; in:
		;	X - the file descriptor into fd_area of the the new dir entry
		;	dirptr - set to current dir entry within block_data
__fat_write_newdir_entry:
		ldy #F32DirEntry::Attr																		; copy from (dirptr), start with F32DirEntry::Attr, the name is skipped and overwritten below
@l_dir_cp:
		lda (dirptr), y
		sta block_data, y																				; 1st dir entry
		sta block_data+1*.sizeof(F32DirEntry), y														; 2nd dir entry
		iny
		cpy #.sizeof(F32DirEntry)
		bne @l_dir_cp

		ldy #.sizeof(F32DirEntry::Name) + .sizeof(F32DirEntry::Ext)	-1			; erase name and build the "." and ".." entries
		lda #$20
@l_clr_name:
		sta block_data, y														; 1st dir entry
		sta block_data+1*.sizeof(F32DirEntry), y								; 2nd dir entry
		dey
		bne @l_clr_name
		lda #'.'
		sta block_data+F32DirEntry::Name+0										; 1st entry "."
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::Name+0				; 2nd entry ".."
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::Name+1

		ldy #FD_INDEX_TEMP_DIR													; due to fat_opendir/fat_open within fat_mkdir the fd of temp dir (FD_INDEX_TEMP_DIR) represents the last visited directory which must be the parent of this one ("..") - FTW!
		;debug32 "cd_cln", fd_area + FD_INDEX_TEMP_DIR + F32_fd::CurrentCluster
		lda fd_area+F32_fd::CurrentCluster+0,y
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusLO+0
		lda fd_area+F32_fd::CurrentCluster+1,y
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusLO+1
		lda fd_area+F32_fd::CurrentCluster+2,y
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusHI+0
		lda fd_area+F32_fd::CurrentCluster+3,y
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusHI+1

		ldy #$80
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
		bne @l_exit

		m_memset block_data, 0, 2*.sizeof(F32DirEntry)							; now erase the "." and ".." entries too
		ldy volumeID+ VolumeID:: BPB + BPB::SecPerClus							; fill up (VolumeID::SecPerClus - 1) reamining blocks of the cluster with empty dir entries
		;debug32 "er_d", lba_addr
		bra @l_remain_blocks_e
@l_remain_blocks:
		jsr __inc_lba_address												; next block within cluster
		jsr __fat_write_block_data
		bne @l_exit
@l_remain_blocks_e:
		dey
		bne @l_remain_blocks													; write until VolumeID::SecPerClus - 1
@l_exit:
		rts

__fat_write_fat_blocks:
		jsr __fat_write_block_fat			; lba_addr is already setup by __fat_find_free_cluster
		bne @err_exit
		clc										; calc fat2 lba_addr = lba_addr + VolumeID::FATSz32
		.repeat 4, i
			lda lba_addr + i
			adc volumeID + VolumeID::EBPB + EBPB::FATSz32 + i
			sta lba_addr + i
		.endrepeat
		jsr __fat_write_block_fat				; write to fat mirror (fat2)
@err_exit:
		rts

__fat_write_block_fat:
		;debug32 "wb_lba", lba_addr
.ifdef FAT_DUMP_FAT_WRITE
		;debugdump "wbf", block_fat
.endif
		lda #>block_fat
		bra	__fat_write_block
__fat_write_block_data:
		lda #>block_data
__fat_write_block:
		sta write_blkptr+1
		stz write_blkptr	;page aligned
.ifndef FAT_NOWRITE
		jmp write_block
.else
		lda #EOK
		rts
.endif

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

		; mark cluster as EOC
		; in:
		;	Y - offset in block
		; 	read_blkptr - points to block_fat either 1st or 2nd page
__fat_mark_cluster_eoc:
		lda #$ff
__fat_mark_cluster:
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
		;	Z=1 on success
		;		Y=offset in block_fat of found cluster
		;		lba_addr with fat block where the found cluster resides
		;		the found cluster is stored within the given file descriptor (fd_area+F32_fd::CurrentCluster,x)
		;	Z=0 on error, A=error code
__fat_find_free_cluster:
		;TODO improve, use a previously saved lba_addr and/or found cluster number
		stz lba_addr+3			; init lba_addr with fat_begin lba addr
		stz lba_addr+2			; TODO FIXME we assume that 16 bit are sufficient for fat lba address
		lda fat_lba_begin+1
		sta lba_addr+1
		lda fat_lba_begin+0
		sta lba_addr+0

		SetVector	block_fat, read_blkptr
@next_block:
		;debug32 "fr_lba", lba_addr
		jsr __fat_read_block	; read fat block
		bne @exit

		ldy #0
@l1:	lda block_fat+0,y		; 1st page find cluster entry with 00 00 00 00
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
		bne @next_block		;
		lda #ENOSPC				; end reached, answer ENOSPC () - "No space left on device"
@exit:
	 ;debug32 "free_cl", fd_area+(2*.sizeof(F32_fd)) + F32_fd::CurrentCluster ; almost the 3rd entry
		rts
@l_found_hb: ; found in "high" block (2nd page of the sd_blocksize)
		lda #>(block_fat+$100)	; set read_blkptr to begin 2nd page of fat_buffer - @see __fat_mark_free_cluster
		sta read_blkptr+1
		lda #$40				; adjust clnr with +$40 (256 / 4 byte/clnr) clusters since it was found in 2nd page
@l_found_lb:				; A=0 here, if called from above
		;debug32 "f_ffc_lba", lba_addr
		sta fd_area+F32_fd::CurrentCluster+0, x
		tya
		lsr						; offset Y>>2 (div 4, 32 bit clnr)
		lsr
		adc fd_area+F32_fd::CurrentCluster+0, x	; C=0 always here, y is multiple of 4 and 2 lsr
		sta fd_area+F32_fd::CurrentCluster+0, x	; safe clnr
		;debug32 "fc_tmp2", fd_area+F32_fd::CurrentCluster+.sizeof(F32_fd)*3 ;(new fd is almost the 3rd entry)

		;m_memcpy lba_addr, safe_lba TODO FIXME fat lba address, reuse them at next search
		; to calc them we have to clnr = (block number * 512) / 4 + (Y / 4) => (lba_addr - fat_lba_begin) << 7 + (Y>>2)
		; to avoid the <<7, we simply <<8 and do one ror
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
		ror						; clnr += offset within block - already saved in F32_fd::CurrentCluster+0, x s.above
		adc fd_area+F32_fd::CurrentCluster+0, x
		sta fd_area+F32_fd::CurrentCluster+0, x
		lda #0					; exit found
		sta fd_area+F32_fd::CurrentCluster+3, x
		bra @exit

		; unlink a file denoted by given path in A/X
		  ; in:
		  ;	A/X - pointer to string with the file path
		; out:
		;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_unlink:
		ldy #O_RDONLY
		jsr fat_open		; try to open as regular file
		bne @l_exit
		jsr __fat_unlink
		;debug "unlnk"
		jmp __fat_free_fd
@l_exit:
		rts

__fat_unlink:
		jsr __fat_isroot							; no clnr assigned yet, file was just touched
		beq @l_unlink_direntry					; if so, we can skip freeing clusters from fat

		jsr __fat_free_cluster					; free cluster, update fsinfo
		bne	@l_exit
@l_unlink_direntry:
		jsr __fat_read_direntry					; read the dir entry
		bne	@l_exit
		lda	#DIR_Entry_Deleted				; mark dir entry as deleted ($e5)
		sta (dirptr)
		jsr __fat_write_block_data				; write back dir entry
@l_exit:
		;debug "_ulnk"
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
