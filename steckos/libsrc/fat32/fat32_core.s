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


.ifdef DEBUG_FAT32_CORE ; debug switch for this module
	debug_enabled=1
.endif

; TODO OPTIMIZATIONS
; 	1. __calc_lba_addr - check whether we can skip the cluster_begin adc if we can proof that the cluster_begin is a multiple of sec/cl. if so we can setup the lba_addr as a cluster number, we can safe one addition => a + (b * c) => with a = n * c => n * c + b * c => c * (n + b)
;
.include "zeropage.inc"
.include "common.inc"
.include "fat32.inc"
.include "rtc.inc"
.include "errno.inc"	; from ca65 api
.include "fcntl.inc"	; from ca65 api

.include "debug.inc"

; external deps - block layer
.import read_block

.export __fat_read_cluster_block_and_select
.export __fat_find_first
.export __fat_find_first_mask
.export __fat_find_next
.export __fat_alloc_fd
.export __fat_clone_cd_td
.export __fat_clone_fd
.export __fat_init_fd
.export __fat_free_fd
.export __fat_isroot
.export __fat_next_cln
.export __fat_open_path
.export __fat_read_block
.export __fat_set_fd_attr_direntry
.export __calc_lba_addr
.export __calc_blocks
.export __calc_fat_lba_begin
.export __calc_cluster_begin_lba
.export __calc_fat_fsinfo_lba
.export __inc_lba_address

.import dirname_mask_matcher
.import string_fat_mask

; in:
;	.X - file descriptor (index into fd_area) of the directory
; out:
;
__fat_find_first_mask:
		SetVector fat_dirname_mask, krn_ptr2	; build fat dir entry mask from user input
		jsr string_fat_mask
		SetVector dirname_mask_matcher, fat_vec_matcher
; in:
;	.X - file descriptor (index into fd_area) of the directory
; out:
;  C=1 if dir entry was found with dirptr pointing to that entry, C=0 otherwise
__fat_find_first:
		SetVector block_data, read_blkptr
		lda volumeID+VolumeID::BPB + BPB::SecPerClus
		sta blocks
		jsr __calc_lba_addr
ff_l3:
		SetVector block_data, dirptr			; dirptr to begin of target buffer
		jsr __fat_read_block
		bne ff_exit
ff_l4:
		lda (dirptr)
		beq ff_exit									; first byte of dir entry is $00 (end of directory)
@l5:
		ldy #F32DirEntry::Attr					; else check if long filename entry
		lda (dirptr),y 							; we are only going to filter those here (or maybe not?)
		cmp #DIR_Attr_Mask_LongFilename
		beq __fat_find_next

		jsr __fat_matcher			  ; call matcher strategy
		lda #EOK						  ; Z=1 (success) and no error
		bcs ff_end					  ; if C=1 we had a match
; in:
;	X - directory fd index into fd_area
; out:
;	Z=1 on success (A=0), Z=0 and A=error code otherwise
__fat_find_next:
		lda dirptr
		clc
		adc #DIR_Entry_Size
		sta dirptr
		bcc @l6
		inc dirptr+1
@l6:
		.assert <(sd_blktarget + sd_blocksize) = $00, error, "sd_blktarget isn't aligned on a RAM page boundary"
		lda dirptr+1
		cmp #>(sd_blktarget + sd_blocksize)	; end of block reached?
		bcc ff_l4			; no, process entry
		dec blocks
		beq @ff_eoc			    	; end of cluster reached?
		jsr __inc_lba_address	; increment lba address to read next block
		bra ff_l3
@ff_eoc:
		ldx #FD_INDEX_TEMP_DIR				; TODO FIXME dont know if this is a good idea... FD_INDEX_TEMP_DIR was setup above and following the cluster chain is done with the FD_INDEX_TEMP_DIR to not clobber the FD_INDEX_CURRENT_DIR
		jsr __fat_next_cln		  			; select next cluster
		bcs ff_exit								; C=1 on error, exit
		bra __fat_find_first		  			; C=0, go on with next cluster
ff_exit:
		clc										; we are at the end, nothing found C=0 and return
		debug "ffex"
ff_end:
		rts


; open a path to a file or directory starting from current directory
; in:
;	A/X - pointer to string with the file path
;	Y	- file descriptor of fd_area denoting the start directory. usually FD_INDEX_CURRENT_DIR is used
; out:
;  X - index into fd_area of the opened file. if a directory was opened then X == FD_INDEX_TEMP_DIR
;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
;	Note: regardless of return value, the dirptr points to the last visited directory entry and the corresponding lba_addr is set to the block where the dir entry resides.
;		  furthermore the filenameptr points to the last inspected path fragment of the given input path
__fat_open_path:
		sta krn_ptr1
		stx krn_ptr1+1				 	; save path arg given in a/x

		ldx #FD_INDEX_TEMP_DIR		; we use the temp dir fd to not clobber the current dir (Y parameter!), maybe we will run into an error
		jsr __fat_clone_fd			; Y is given as param

		ldy #0							; trim wildcard at the beginning
@l1:
		lda (krn_ptr1), y
		cmp #' '
		bne @l2
		iny
		bne @l1
		bra @l_err_einval		; overflow, >255 chars
@l2:	;	starts with '/' ? - we simply cd root first
		cmp #'/'
		bne @l31
		jsr __fat_open_rootdir
		iny
		lda	(krn_ptr1), y		;end of input?
		beq	@l_exit				;yes, so it was just the '/', exit with A=0
@l31:
		SetVector filename_buf, filenameptr	; filenameptr to filename_buf
@l3:	;	parse input path fragments into filename_buf try to change dirs accordingly
		ldx #0
@l_parse_1:
		lda (krn_ptr1), y
		beq @l_openfile
		cmp #' '					 ;TODO FIXME support file/dir name with spaces? it's beyond 8.3 file support
		beq @l_openfile
		cmp #'/'
		beq @l_open

		sta filename_buf, x
		iny
		inx
		cpx #8+1+3		+1		; buffer overflow ? - only 8.3 file support yet
		bne @l_parse_1
		bra @l_err_einval
@l_open:
		stz filename_buf, x			; \0 terminate the current path fragment
		jsr __fat_open_file			; return with X as offset into fd_area with new allocated file descriptor
		bne @l_exit
		iny
		bne	@l3					;overflow - <path argument> exceeds 255 chars
@l_err_einval:
		lda	#EINVAL
@l_exit:
		rts
@l_openfile:
		stz filename_buf, x			;\0 terminate the current path fragment
		jmp __fat_open_file			; return with X as offset into fd_area with new allocated file descriptor

__fat_clone_cd_td:
		ldy #FD_INDEX_CURRENT_DIR
		ldx #FD_INDEX_TEMP_DIR
		; clone source file descriptor with offset y into fd_area to target fd with x
		; in:
		;	Y - source file descriptor (offset into fd_area)
		;	X - target file descriptor (offset into fd_area)
__fat_clone_fd:
		phx
		lda #FD_Entry_Size
		sta krn_tmp
@l1:	lda fd_area, y
		sta fd_area, x
		inx
		iny
		dec krn_tmp
		bne @l1
		plx
		rts


		; update the dir entry position and dir lba_addr of the given file descriptor
		; in:
		;	.A - file attr
		;	.X - file descriptor
		; out:
		;	updated file descriptor, DirEntryLBA and DirEntryPos setup accordingly
__fat_set_fd_attr_direntry:
		sta fd_area + F32_fd::Attr, x

	 	lda lba_addr + 3
		sta fd_area + F32_fd::DirEntryLBA + 3, x
	 	lda lba_addr + 2
		sta fd_area + F32_fd::DirEntryLBA + 2, x
	 	lda lba_addr + 1
		sta fd_area + F32_fd::DirEntryLBA + 1, x
	 	lda lba_addr + 0
		sta fd_area + F32_fd::DirEntryLBA + 0, x

		lda dirptr
		sta krn_tmp

		lda dirptr+1
		and #$01		; div 32, just bit 0 of high byte must be taken into account. dirptr must be $0200 aligned
		.assert >block_data & $01 = 0, error, "block_data must be $0200 aligned!"
		clc
		rol krn_tmp
		rol
		rol krn_tmp
		rol
		rol krn_tmp
		rol

		sta fd_area + F32_fd::DirEntryPos, x
		rts

;in:
;	filenameptr - ptr to the filename
;out:
;	X - index into fd_area of the opened file
;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
__fat_open_file:
		phy

		ldx #FD_INDEX_TEMP_DIR
		jsr __fat_find_first_mask
		bcs @l1
		lda #ENOENT
		bra @l_exit

@l1:	ldy #F32DirEntry::Attr
		lda (dirptr),y
		and #DIR_Attr_Mask_Dir 		; directory?
		bne @l2							; yes, do not allocate a new fd, use index (X) which is already set to FD_INDEX_TEMP_DIR and just update the fd data
		jsr __fat_alloc_fd			; no, then regular file and we allocate a new fd for them
		bne @l_exit
@l2:
		;save 32 bit cluster number from dir entry
		ldy #F32DirEntry::FstClusHI +1
		lda (dirptr),y
		sta fd_area + F32_fd::CurrentCluster + 3, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::CurrentCluster + 2, x

		ldy #F32DirEntry::FstClusLO +1
		lda (dirptr),y
		sta fd_area + F32_fd::CurrentCluster + 1, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::CurrentCluster + 0, x

		ldy #F32DirEntry::FileSize + 3
		lda (dirptr),y
		sta fd_area + F32_fd::FileSize + 3, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::FileSize + 2, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::FileSize + 1, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::FileSize + 0, x

		ldy #F32DirEntry::Attr
		lda (dirptr),y
		jsr __fat_set_fd_attr_direntry

		lda #EOK ; no error
@l_exit:
		ply
		cmp	#0			;restore z flag
		rts


	 ; out:
	 ;	.X - with index to fd_area
	 ;	Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
__fat_alloc_fd:
		ldx #(2*FD_Entry_Size)							; skip 2 entries, they're reserved for current and temp dir
@l1:	lda fd_area + F32_fd::CurrentCluster+3, x
		cmp #$ff	;#$ff means unused, return current x as offset
		beq __fat_init_fd

		txa
		adc #FD_Entry_Size; carry must be clear from cmp #$ff above
		tax

		cpx #(FD_Entry_Size*FD_Entries_Max)
		bne @l1
		lda #EMFILE								; Too many open files, no free file descriptor found
		rts

		; out:
		;	x - FD_INDEX_TEMP_DIR offset to fd area
__fat_open_rootdir:
		ldx #FD_INDEX_TEMP_DIR					; use fd of the temp directory
		; in:
		;	.X - with index to fd_area
__fat_init_fd:
		stz fd_area+F32_fd::CurrentCluster+3,x	; init start cluster with root cluster nr 0 and not RootClus - the RootClus offset is compensated within calc_lba_addr (@see Note)
		stz fd_area+F32_fd::CurrentCluster+2,x
		stz fd_area+F32_fd::CurrentCluster+1,x
		stz fd_area+F32_fd::CurrentCluster+0,x
		stz fd_area+F32_fd::FileSize+3,x		; init file size with 0, it's maintained during open
		stz fd_area+F32_fd::FileSize+2,x
		stz fd_area+F32_fd::FileSize+1,x
		stz fd_area+F32_fd::FileSize+0,x
		stz fd_area+F32_fd::offset+0,x		; init block offset/block counter
		stz fd_area+F32_fd::seek_pos+3,x
		stz fd_area+F32_fd::seek_pos+2,x
		stz fd_area+F32_fd::seek_pos+1,x
		stz fd_area+F32_fd::seek_pos+0,x
		lda #EOK
		rts

		; free file descriptor quietly
		; in:
		;	X - offset into fd_area
__fat_free_fd:
		debug "fat_free"
		pha
		lda #$ff	 ; otherwise mark as closed
		sta fd_area + F32_fd::CurrentCluster +3, x
		pla
		rts

		; check whether cluster of fd is the root cluster number - 0x00000000 (not VolumeID::RootClus due to lba calc optimization)
		; in:
		;	X - file descriptor
		; out:
		;	Z=1 if it is the root cluster, Z=0 otherwise
__fat_isroot:
		lda fd_area+F32_fd::CurrentCluster+3,x				; check whether start cluster is the root dir cluster nr (0x00000000) as initial set by fat_alloc_fd
		ora fd_area+F32_fd::CurrentCluster+2,x
		ora fd_area+F32_fd::CurrentCluster+1,x
		ora fd_area+F32_fd::CurrentCluster+0,x
		rts

		; TODO dedicated calls for data and fat, clean code
		; internal read block
		; requires: read_blkptr and lba_addr already calculated
__fat_read_block:
		phx
		debug32 "fat_rb", lba_addr
		debug16 "fat_rb", read_blkptr
		jsr read_block
		dec read_blkptr+1		; TODO FIXME clarification with TW - read_block increments block ptr highbyte - which is a sideeffect and should be avoided
		plx
		cmp #0
		rts

		; in:
		;	X - file descriptor
		; out:
		;	lba_addr setup with lba address from given file descriptor
		;	A - with bit 0-7 of lba address
__prepare_calc_lba_addr:
		jsr	__fat_isroot
		bne	@l_scl
		.repeat 4,i
			lda volumeID + VolumeID::EBPB + EBPB::RootClus + i
			sta lba_addr + i
		.endrepeat
		rts
@l_scl:
		.repeat 4,i
			lda fd_area + F32_fd::CurrentCluster + i,x
			sta lba_addr + i
		.endrepeat
		rts


; 		calculate LBA address of first block from cluster number found in file descriptor entry. file descriptor index must be in x
;		Note: lba_addr = cluster_begin_lba_m2 + (cluster_number * VolumeID::SecPerClus)
;		in:
;			X - file descriptor index
__calc_lba_addr:
		pha

		jsr __prepare_calc_lba_addr

		;SecPerClus is a power of 2 value, therefore cluster << n, where n is the number of bit set in VolumeID::SecPerClus
		lda volumeID+VolumeID::BPB + BPB::SecPerClus
		sta krn_tmp
@lm:
		lsr krn_tmp
		beq @lme	 ; until 1 sector/cluster
		asl lba_addr +0
		rol lba_addr +1
		rol lba_addr +2
		rol lba_addr +3
		bra @lm
@lme:
		; add cluster_begin_lba and lba_addr => TODO may be an optimization
		add32 cluster_begin_lba, lba_addr, lba_addr

		clc
		lda fd_area+F32_fd::offset+0,x			; load the current block counter
		adc lba_addr+0									; add to lba_addr
		sta lba_addr+0
		bcc :+
		.repeat 3, i
			lda lba_addr+1+i
			adc #0
			sta lba_addr+1+i
		.endrepeat
:
		;debug32 "f_lba", lba_addr

		pla
		rts

		; in:
		;	X - file descriptor
		; out:
		;	vol->LbaFat + (cluster_nr>>7);// div 128 -> 4 (32bit) * 128 cluster numbers per block (512 bytes)
__calc_fat_lba_addr:
		;instead of shift right 7 times in a loop, we copy over the hole byte (same as >>8) - and simply shift left 1 bit (<<1)
		jsr __prepare_calc_lba_addr
		lda lba_addr+0
		asl
		lda lba_addr+1
		rol
		sta lba_addr+0
		lda lba_addr+2
		rol
		sta lba_addr+1
		lda lba_addr+3
		rol
		sta lba_addr+2
		lda #0									;$0f (see EOC) highest value for cluster MSB, due to >>7 the $0f from the MSB is erased completely
		rol
		sta lba_addr+3

	; add fat_lba_begin and lba_addr
	add16 fat_lba_begin, lba_addr, lba_addr
	; TODO FIXME currently only 16 Bit LBA Fat-Sizes supported
	stz lba_addr +2
	stz lba_addr +3

	;debug32 "f_flba", lba_addr
	rts

		; in:
		;	X - file descriptor
		; out:
		;	Z=1 (A=0) if no blocks to read (file has zero length)
__calc_blocks: ;blocks = filesize / BLOCKSIZE -> filesize >> 9 (div 512) +1 if filesize LSB is not 0
		lda fd_area + F32_fd::FileSize + 3,x
		lsr
		sta blocks + 2
		lda fd_area + F32_fd::FileSize + 2,x
		ror
		sta blocks + 1
		lda fd_area + F32_fd::FileSize + 1,x
		ror
		sta blocks + 0
		bcs @l1
		lda fd_area + F32_fd::FileSize + 0,x
		beq @l2
@l1:	inc blocks
		bne @l2
		inc blocks+1
		bne @l2
		inc blocks+2
@l2:	lda blocks+2
		ora blocks+1
		ora blocks+0
		debug16 "__calc_blocks", blocks
		rts

		; extract next cluster number from the 512 fat block buffer
		; unsigned int offs = (clnr << 2 & (BLOCK_SIZE-1));//offset within 512 byte block, cluster nr * 4 (32 Bit) and Bit 8-0 gives the offset
		; in:
		;	X - file descriptor
		;	Y - offset from target address denoted by pointer (read_blkptr)
		; out:
		;	C=0 on success, C=1 on failure with A=<error code>, C=1 if EOC reached and A=0 (EOK)
__fat_next_cln:
		lda read_blkptr
		pha
		lda read_blkptr+1
		pha
		jsr __fat_read_cluster_block_and_select    	; read fat block of the current cluster
		bcs @l_exit
		lda (read_blkptr), y
		sta fd_area + F32_fd::CurrentCluster+0, x
		iny
		lda (read_blkptr), y
		sta fd_area + F32_fd::CurrentCluster+1, x
		iny
		lda (read_blkptr), y
		sta fd_area + F32_fd::CurrentCluster+2, x
		iny
		lda (read_blkptr), y
		sta fd_area + F32_fd::CurrentCluster+3, x
		stz fd_area + F32_fd::offset, x 					; reset block offset here
		clc ; success
@l_exit:
		ply
		sty read_blkptr+1
		ply
		sty read_blkptr
		rts

		; in:
		;	X - file descriptor
		; out:
		;	read_blkptr - setup to block_fat either low/high page
		;	Y - offset within block_fat to clnr
		;	C=1 if the cluster number is the EOC and A=EOK or C=1 and A=<error code>, C=0 otherwise
__fat_read_cluster_block_and_select:
		jsr __calc_fat_lba_addr
		SetVector block_fat, read_blkptr
		jsr __fat_read_block
		bne @l_exit
		jsr __fat_isroot							; is root clnr?
		bne @l_clnr_fd
		lda volumeID + VolumeID::EBPB + EBPB::RootClus+0
		bra @l_clnr_page
@l_exit:
		sec
		debug16 "f_rcbs", read_blkptr
		rts
@l_clnr_fd:
		lda fd_area+F32_fd::CurrentCluster+0,x 	; offset within block_fat, clnr<<2 (* 4)
@l_clnr_page:
		bit #$40										; clnr within 2nd page of the 512 byte block ?
		beq @l_clnr
		ldy #>(block_fat+$0100)					; yes, set read_blkptr to 2nd page of block_fat
		sty read_blkptr+1
@l_clnr:
		asl											; block offset = clnr*4
		asl
		tay
; check whether the EOC (end of cluster chain) cluster number is reached
; out:
;	C=1 if clnr is EOC, C=0 otherwise
__fat_is_cln_eoc:
		phy
		lda (read_blkptr),y
		cmp #<FAT_EOC
		bne @l_neoc
		iny
		lda (read_blkptr),y
		cmp #<(FAT_EOC>>8)
		iny
		lda (read_blkptr),y
		cmp #<(FAT_EOC>>16)
		bne @l_neoc
		iny
		lda (read_blkptr),y
		cmp #<(FAT_EOC>>24)
		beq @l_eoc
@l_neoc:
		clc
@l_eoc:
		ply
		lda #EOK ; carry denotes EOC state
		rts

__inc_lba_address:
		_inc32 lba_addr
		rts

__fat_matcher:
		jmp	(fat_vec_matcher)

__calc_cluster_begin_lba:
		; Number of FATs. Must be 2
		; cluster_begin_lba = fat_lba_begin + (sectors_per_fat * VolumeID::NumFATs (2))
		ldy volumeID + VolumeID::BPB + BPB::NumFATs
@l7:	clc
		ldx #$00
@l8:	ror ; get carry flag back
		lda volumeID + VolumeID::EBPB + EBPB::FATSz32,x ; sectors per fat
		adc cluster_begin_lba,x
		sta cluster_begin_lba,x
		inx
		rol ; save status register before cpx to save carry
		cpx #$04 ; 32Bit
		bne @l8
		dey
		bne @l7

		; performance optimization - the RootClus offset is compensated within calc_lba_addr
		; cluster_begin_lba_m2 = cluster_begin_lba - (VolumeID::RootClus*VolumeID::SecPerClus)
		; cluster_begin_lba_m2 = cluster_begin_lba - (2 * sec/cluster) = cluster_begin_lba - (sec/cluster << 1)

		;TODO FIXME we assume 2 here instead of using the value in VolumeID::RootClus
		lda volumeID+VolumeID::BPB + BPB::SecPerClus ; max sec/cluster can be 128, with 2 (BPB_RootClus) * 128 we may subtract max 256
		asl

		sta lba_addr		  ;	used as tmp
		stz lba_addr +1	  ;	safe carry
		rol lba_addr +1
		sec						 ;	subtract from cluster_begin_lba
		lda cluster_begin_lba
		sbc lba_addr
		sta cluster_begin_lba
		lda cluster_begin_lba +1
		sbc lba_addr +1
		sta cluster_begin_lba +1
		lda cluster_begin_lba +2
		sbc #0
		sta cluster_begin_lba +2
		lda cluster_begin_lba +3
		sbc #0
		sta cluster_begin_lba +3
		rts

__calc_fat_fsinfo_lba:
		; calc fs_info lba address as cluster_begin_lba + EBPB::FSInfoSec
		add16 lba_addr, volumeID+ VolumeID::EBPB + EBPB::FSInfoSec, fat_fsinfo_lba
		adc #0				; 0 + C
		sta fat_fsinfo_lba+2
		stz fat_fsinfo_lba+3 ; always 0
		rts

__calc_fat_lba_begin:
		; cluster_begin_lba = Partition_LBA_Begin + Number_of_Reserved_Sectors + (Number_of_FATs * Sectors_Per_FAT) -  (2 * sec/cluster);
		; fat_lba_begin = Partition_LBA_Begin + Number_of_Reserved_Sectors
		; fat2_lba_begin = Partition_LBA_Begin + Number_of_Reserved_Sectors + Sectors_Per_FAT

		; add number of reserved sectors to calculate fat_lba_begin. also store in cluster_begin_lba for further calculation
		clc
		lda lba_addr + 0
		adc volumeID + VolumeID::BPB + BPB::RsvdSecCnt + 0
		sta cluster_begin_lba + 0
		sta fat_lba_begin + 0
		lda lba_addr + 1
		adc volumeID + VolumeID::BPB + BPB::RsvdSecCnt + 1
		sta cluster_begin_lba + 1
		sta fat_lba_begin + 1
		lda lba_addr + 2
		adc #$00
		sta cluster_begin_lba + 2
		sta fat_lba_begin + 2
		lda lba_addr + 3
		adc #$00
		sta cluster_begin_lba + 3
		sta fat_lba_begin + 3

		; calc begin of 2nd fat (end of 1st fat)
		; TODO FIXME - we assume 16bit are sufficient for now since fat is placed at the beginning of the device
		; clc
		; lda volumeID +  VolumeID::EBPB + EBPB::FATSz32+0 ; sectors/blocks per fat
		; adc fat_lba_begin	+0
		; sta fat2_lba_begin	+0
		; lda volumeID +  VolumeID::EBPB + EBPB::FATSz32+1
		; adc fat_lba_begin	+1
		; sta fat2_lba_begin	+1

		add16 volumeID +  VolumeID::EBPB + EBPB::FATSz32, fat_lba_begin, fat2_lba_begin

		rts
