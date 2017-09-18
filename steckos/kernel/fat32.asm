.include "common.inc"
.include "kernel.inc"
.include "fat32.inc"
.include "rtc.inc"
.include "errno.inc"	; from ca65 api

.import sd_read_block, sd_read_multiblock, sd_write_block, sd_write_multiblock, sd_select_card, sd_deselect_card
.import sd_read_block_data

.import __rtc_systime_update, __rtc_systime_t

.export fat_mount
.export fat_open, fat_isOpen, fat_chdir, fat_get_root_and_pwd
.export fat_mkdir, fat_rmdir
.export fat_read, fat_read_block, fat_find_first, fat_find_next, fat_write
.export fat_close_all, fat_close, fat_getfilesize
.export calc_dirptr_from_entry_nr, inc_lba_address, calc_blocks

.macro inc32 val
		.local @l1
		inc val + 0
		bne @l1
		inc val + 1
		bne @l1
		inc val + 2
		bne @l1
		inc val + 3
@l1:
.endmacro

.macro copy32 src, dest
		.local @l
		ldx #$03
@l:
		lda src,x
		sta dest,x
		dex
		bpl @l
.endmacro

.macro _open
		stz	pathFragment, x	;\0 terminate the current path fragment
		;debugstr "_o", pathFragment
		jsr	_fat_open
		debug "o_"
		bne @l_exit
.endmacro

.segment "KERNEL"

		;	read one block, updates the seek position within FD
		;in:
		;	X	- offset into fd_area
		;out:
		;	A - A = 0 on success, error code otherwise
		;	@deprecated errno - error number
fat_read_block:
;		lda fd_area + F32_fd::SeekPos+0,x
;		lda fd_area + F32_fd::SeekPos+1,x
;		lda	#1
;		sta blocks		; just one block
;		bra _fat_read
		jsr calc_blocks
		jsr calc_lba_addr
		jsr sd_read_block
		lda errno
		rts
		;in:
		;	X - offset into fd_area
		;out:
		;	A - A = 0 on success, error code otherwise
		;	@deprecated errno - error number
fat_read:
		jsr calc_blocks
_fat_read:
		debug "fr"
		jsr calc_lba_addr
		stz errno
		jsr sd_read_multiblock
;		jsr sd_read_block
		lda errno
		rts


		;in:
		;	X - offset into fd_area
fat_write:
		stz errno

		jsr calc_lba_addr
		jsr calc_blocks

.ifdef MULTIBLOCK_WRITE
.warning "SD multiblock writes are EXPERIMENTAL"
		jsr sd_write_multiblock
.else
		phx
@l:
		jsr sd_write_block
		jsr inc_lba_address
		dec blocks
		bne @l

		plx
.endif
fat_update_direntry:

		lda fd_area + F32_fd::DirEntryLBA+3 , x
		sta lba_addr+3
		lda fd_area + F32_fd::DirEntryLBA+2 , x
		sta lba_addr+2
		lda fd_area + F32_fd::DirEntryLBA+1 , x
		sta lba_addr+1
		lda fd_area + F32_fd::DirEntryLBA+0 , x
		sta lba_addr+0

		lda fd_area + F32_fd::DirEntryPos , x
		jsr calc_dirptr_from_entry_nr

		phx
		SetVector sd_blktarget, read_blkptr
		jsr sd_read_block
		plx

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

		SetVector sd_blktarget, write_blkptr
		jsr sd_write_block
		lda errno

		rts


	;in:
        ;   A/X - pointer to the result buffer
		;	Y	- size of result buffer
        ;out:
		;	A - errno, 0 - means no error
fat_get_root_and_pwd:
		sta	krn_ptr2
		stx	krn_ptr2+1
		tya
		eor	#$ff
		sta	krn_ptr3		;save -size-1 for easy loop


@l1:	ldx #FD_INDEX_CURRENT_DIR
		lda fd_area + F32_fd::StartCluster + 3, x
		ora fd_area + F32_fd::StartCluster + 2, x
		lda root_dir_first_clus +1
		sta fd_area + F32_fd::StartCluster +1, x
		lda root_dir_first_clus +0
		sta fd_area + F32_fd::StartCluster +0, x

		bne @l2
		Copy fd_area + F32_fd::StartCluster, cluster_nr, 3	;save cluster current dir for matcher
		lda #<parent_dir
		ldx #>parent_dir
		jsr fat_chdir
		bne	@err
		jsr fat_find_first_intern


		SetVector clusternr_matcher, krn_call_internal
		bne	@end
		ldy #F32DirEntry::Name	;Name offset is 0
@l2:	lda (dirptr),y
		sta	(krn_ptr2),y	; '0' term string
		inc krn_ptr2
		beq @err
		iny
		cpy #$0b
		bne	@l1
		lda	#0
@end:
		rts
@err:	lda #ERANGE
		bra	@end

cluster_nr:
		.res 4
parent_dir:
		.asciiz ".."
clusternr_matcher:
		sec
		; TODO implement me
		rts

		;in:
        ;   A/X - pointer to the file path
        ;out:
		;	A - Z=0 on success, Z=1 and A with errno otherwise
        ;   X - index into fd_area of the opened directory - !!! ATTENTION !!! X is exactly the FD_INDEX_TEMP_DIR on success
__fat_opendir:
		jsr fat_open				; change dir using temp dir to not clobber the current dir, maybe we will run into an error
		bne	@l_exit					; exit on error
		lda	fd_area + F32_fd::Attr, x
		bit #DIR_Attr_Mask_Dir		; check that there is no error and we have a directory
		bne	@l_ok
		lda	#EINVAL				; TODO FIXME error code for "Not a directory"
		bra @l_exit
@l_ok:	lda #0                  ; ok
@l_exit:
		debug "od"
		rts

		;in:
        ;   A/X - pointer to the file path
        ;out:
		;	A - Z=0 on success, Z=1 and A with errno otherwise
        ;   X - index into fd_area of the opened directory
fat_chdir:
		jsr __fat_opendir
		bne	@l_exit
		phx
		ldx #FD_INDEX_TEMP_DIR  ; the temp dir fd is now set to the last dir of the path and we proofed that it's valid with the code above
		ldy #FD_INDEX_CURRENT_DIR
		jsr	fat_clone_fd        ; therefore we can simply clone the temp dir to current dir fd - FTW!
		plx
		lda #0                  ; ok
@l_exit:
		debug "chdir"
		rts

        ;in:
        ;   A/X - pointer to the file name
fat_rmdir:
		jsr __fat_opendir
		bne	@l_exit
		
		lda	#DIR_Entry_Deleted			; ($e5)
		sta (dirptr)					; mark dir entry as deleted
		debug "rmdir"
		ldy #0
@l0:	lda (dirptr), y
		iny 
		cpy #11
		bne @l0
		;TODO FIXME write back the current block
		
		lda #0                  ; ok
@l_exit:
		debug "rmdir"
		rts

		
        ;in:
        ;   A/X - pointer to the file name
fat_mkdir:
		jsr __fat_opendir
		beq	@err_dir_exists
		cmp	#ENOENT			;error must be no such file or directory, otherwise we wont create a new one
		bne @l_exit

		jsr __fat_find_free_cluster
		bne @l_exit

		; new dir entry
		jsr __rtc_systime_update
		;debug32 "rtc0", __rtc_systime_t
		;debug32 "rtc1", __rtc_systime_t+4
		
		lda __rtc_systime_t+time_t::tm_hour
		lda __rtc_systime_t+time_t::tm_min
		lda __rtc_systime_t+time_t::tm_sec
		sta @dir_entry_template+F32DirEntry::CrtTime
		sta @dir_entry_template+F32DirEntry::WrtTime

		lda __rtc_systime_t+time_t::tm_year
		lda __rtc_systime_t+time_t::tm_mon
		lda __rtc_systime_t+time_t::tm_mday
		sta @dir_entry_template+F32DirEntry::CrtTime
		sta @dir_entry_template+F32DirEntry::WrtTime
		
@err_unknown:
		lda #EUNKNOWN		;unknown
		bra @l_exit
@err_dir_exists:
		lda	#EEXIST
@l_exit:
		debug "mkdir"
		rts
		
@dir_entry_template:
; TODO FIXME struct init not implemented yet - @see http://www.cc65.org/doc/ca65-15.html#ss15.4
;		.tag F32DirEntry
		.byte "           "		;name
		.byte 1<<4 				;attr, type dir
		.res 2
		.word 0					;create time
		.word 0					;create date
		.res 2	
		.word 0					;clnr high
		.word 0					;write time
		.word 0					;write date
		.word 0					;clnr low
		.dword 0				;file size
		

__fat_find_free_cluster:
		SetVector	block_fat, read_blkptr
		
		;TODO improve, use a previously saved lba_addr and/or found cluster number
		m_memcpy	fat_lba_begin, lba_addr, 2	; init lba_addr with fat_block
		stz lba_addr+2;16 bit fat address
		stz lba_addr+3
		
		m_memset	fat_clnr_tmp, 0, 4
		
@next_block:
;		debug32 "f_lba", lba_addr
;		debug32 "fr_cl_tmp", fat_clnr_tmp
		jsr	sd_read_block		; read fat block
		bne @exit
		dec read_blkptr+1		; TODO FIXME clarification with TW - sd_read_block increments block ptr highbyte
		
		ldx	#0
@l1:	lda	block_fat+0,x		; 1st page find cluster entry with 00 00 00 00
		ora block_fat+1,x
		ora block_fat+2,x
		ora block_fat+3,x
		beq	@l_found_lb			
		lda	block_fat+$100+0,x	; 2nd page find cluster entry with 00 00 00 00
		ora block_fat+$100+1,x
		ora block_fat+$100+2,x
		ora block_fat+$100+3,x
		beq	@l_found_hb
		inx
		inx 
		inx 
		inx
		bne @l1
		jsr inc_lba_address		; inc lba_addr, next fat block
		lda lba_addr+1
		cmp	fat2_lba_begin+1
		bne @next_block 
		lda lba_addr+0
		cmp	fat2_lba_begin+0
		bne	@next_block
		lda #ENOSPC				; ENOSPC - No space left on device
		bra @exit
@l_found_hb:
		lda #$40				; cluster nr found in 2nd page, adjust with $40 clusters
		sta fat_clnr_tmp+0
@l_found_lb:
		txa
		lsr
		lsr
		adc fat_clnr_tmp		; add the offset X>>2
		sta fat_clnr_tmp
;		debug32 "fr_cl", fat_clnr_tmp
;		m_memcpy lba_addr, safe_lba TODO fat lba address, reuse them at next search
		; to calc them we have to (lba_addr - fat_lba_begin) * 512 / 4 + (X / 2) => (lba_addr - fat_lba_begin) << 7 | (X>>2)
		sec						; blocks = lba_addr - fat_begin_lba
		lda lba_addr+0
		sbc fat_lba_begin+0
		sta blocks+0
		lda lba_addr+1
		sbc fat_lba_begin+1
;		sta blocks+1
;		stz blocks+2
;		lda blocks+1
		lsr						; clnr = blocks * 128
		sta fat_clnr_tmp+2
		lda blocks+0
		ror
		sta fat_clnr_tmp+1
		lda #0
		ror
		adc fat_clnr_tmp+0
		sta fat_clnr_tmp+0										
@exit:
		debug32 "free_cl", fat_clnr_tmp
		rts
		
@add_fat_clnr_tmp:
		clc
		adc	fat_clnr_tmp+0		; add to clnr
		bcc @add_ex
		inc fat_clnr_tmp+1
		bne @add_ex
		inc fat_clnr_tmp+2
		bne @add_ex
		inc fat_clnr_tmp+3
@add_ex:
		rts
		
        ;in:
        ;   A/X - pointer to the file path
		;	  Y - flags, 0 - "ro", 1 - "rw"
        ;out:
        ;   X - index into fd_area of the opened file
        ;   A - errno, Z=0 no error, Z=1 error and A contains error number
		;	Note: regardless of return value, dirptr points the last visited directory entry. furthermore lba_addr is set to the corresponding block
fat_open:
		sta krn_ptr1
		stx krn_ptr1+1			    ; save path arg given in a/x

		ldx #FD_INDEX_CURRENT_DIR   ; clone current dir fd to temp dir fd
		ldy #FD_INDEX_TEMP_DIR
		jsr fat_clone_fd

		ldy	#0
		;	trim wildcard at the beginning
@l1:	lda (krn_ptr1), y
		cmp	#' '
		bne	@l2
		iny
		bne @l1
		lda #EINVAL
		rts
@l2:		;	starts with / ? - cd root
		cmp	#'/'
		bne	@l31
		jsr fat_open_rootdir
		iny
        lda	(krn_ptr1), y		;end of input?
		beq	@l_exit_noerr       ;yes, so it was just the '/'
@l31:
		SetVector   pathFragment, filenameptr	; filenameptr to path fragment
@l3:	;	parse path fragments and change dirs accordingly
		ldx #0
@l_parse_1:
		lda	(krn_ptr1), y
		beq	@l_openfile
		cmp	#' '                ;TODO FIXME support file/dir name with spaces? it's beyond 8.3 file support
		beq	@l_openfile
		cmp	#'/'
		beq	@l_open

		sta pathFragment, x
		iny
		inx
		cpx	#8+1+3		+1		; buffer overflow ? - only 8.3 file support yet
		bne	@l_parse_1
		lda #EINVAL
		bra @l_exit
@l_open:
		_open
		iny
		bne	@l3
		;TODO FIXME handle overflow - <path argument> too large - only 8.3 file support yet
		lda	#EINVAL
		bra @l_exit
@l_exit_noerr:
		lda #0
@l_exit:
		debug	"fe"
		rts
@l_openfile:
		_open				; return with x as offset to fd_area
		; TODO FIXME 		if opened "path" is a directory, alloc a new fd to save them
		bra @l_exit_noerr
pathFragment: .res 8+1+3+1; 12 chars + \0 for path fragment


        ;in:
        ;   filenameptr - ptr to the filename
        ;out:
        ;   X - index into fd_area of the opened file
		;   A - Z=0 on success, Z=1 and A with error code otherwise
_fat_open:
		phy

		ldx #FD_INDEX_TEMP_DIR
		jsr fat_find_first
		ldx #FD_INDEX_TEMP_DIR
		bcs fat_open_found
		lda #ENOENT
		jmp end_open_err

lbl_fat_open_error:
		lda #EINVAL ; TODO FIXME error code
		jmp end_open_err

; found.
fat_open_found:
		ldy #F32DirEntry::Attr
		lda (dirptr),y
		bit #DIR_Attr_Mask_Dir 		; directory?
		bne @l2						; go on, do not allocate fd, use index (X) which is already set to FD_INDEX_TEMP_DIR
		bit #DIR_Attr_Mask_File 	; is file?
		beq lbl_fat_open_error
		jsr fat_alloc_fd
		bne end_open_err
@l2:
		;save 32 bit cluster number from dir entry
		ldy #F32DirEntry::FstClusHI +1
		lda (dirptr),y
		sta fd_area + F32_fd::StartCluster + 3, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::StartCluster + 2, x

		ldy #F32DirEntry::FstClusLO +1
		lda (dirptr),y
		sta fd_area + F32_fd::StartCluster + 1, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::StartCluster + 0, x

		; cluster no = 0? - its root dir, set to root dir first cluster
		lda fd_area + F32_fd::StartCluster + 3, x
		ora fd_area + F32_fd::StartCluster + 2, x
		ora fd_area + F32_fd::StartCluster + 1, x
		ora fd_area + F32_fd::StartCluster + 0, x
		bne @l3

		lda root_dir_first_clus +1
		sta fd_area + F32_fd::StartCluster +1, x
		lda root_dir_first_clus +0
		sta fd_area + F32_fd::StartCluster +0, x

@l3:
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
		sta fd_area + F32_fd::Attr, x

	 	lda lba_addr + 3
		sta fd_area + F32_fd::DirEntryLBA + 3, x
	 	lda lba_addr + 2
		sta fd_area + F32_fd::DirEntryLBA + 2, x
	 	lda lba_addr + 1
		sta fd_area + F32_fd::DirEntryLBA + 1, x
	 	lda lba_addr + 0
		sta fd_area + F32_fd::DirEntryLBA + 0, x

		jsr calc_dir_entry_nr
		sta fd_area + F32_fd::DirEntryPos + 0, x

		lda #0 ; no error
end_open_err:
		ply
		cmp	#0			;restore z flag
		rts

inc_blkptr:
		; Increment blkptr by 32 bytes, jump to next dir entry
		clc
		lda read_blkptr
		adc #32
		sta read_blkptr
		bcc @l
		inc read_blkptr+1
@l:
		rts

fat_check_signature:
		lda #$55
		cmp sd_blktarget + BootSector::Signature
		bne @l1
		asl ; $aa
		cmp sd_blktarget + BootSector::Signature + 1
		beq @l2
@l1:		lda #fat_bad_block_signature
		sta errno
@l2:		rts


calc_blocks: ;blocks = filesize / BLOCKSIZE -> filesize >> 9 (div 512) +1 if filesize LSB is not 0
		lda fd_area + F32_fd::FileSize + 3,x
		lsr
		sta blocks + 2
		lda fd_area + F32_fd::FileSize + 2,x
		ror
		sta blocks + 1
		lda fd_area + F32_fd::FileSize + 1,x
		ror
		sta blocks
		bcs @l1
		lda fd_area + F32_fd::FileSize + 0,x
		beq @l2
@l1:	inc blocks
		bne @l2
		inc blocks+1
		bne @l2
		inc blocks+2
@l2:	rts

; calculate LBA address of first block from cluster number found in file descriptor entry
; file descriptor index must be in x
;		in:	X - file descriptor index
calc_data_lba_addr:
calc_lba_addr:
		pha
		phx

		lda fd_area + F32_fd::StartCluster +3, x
		cmp #$ff
		beq file_not_open

		; lba_addr = cluster_begin_lba_m2 + (cluster_number * sectors_per_cluster);
		.repeat 4,i
			lda fd_area + F32_fd::StartCluster + i,x
			sta lba_addr + i
		.endrepeat

		;sectors_per_cluster -> is a power of 2 value, therefore cluster << n, where n ist the number of bit set in sectors_per_cluster
		lda sectors_per_cluster
@lm:	lsr
		beq @lme    ; 1 sector/cluster therefore skip multiply
		tax
		asl lba_addr +0
		rol lba_addr +1
		rol lba_addr +2
		rol lba_addr +3
		txa
		bra @lm
@lme:
		; add cluster_begin_lba and lba_addr
		clc
		.repeat 4, i
			lda cluster_begin_lba + i
			adc lba_addr + i
			sta lba_addr + i
		.endrepeat

calc_end:
		plx
		pla
		rts

file_not_open:
		lda #fat_file_not_open
		sta errno
		bra calc_end


inc_lba_address:
		inc32 lba_addr
		rts

;vol->LbaFat + (cluster_nr>>7);// div 128 -> 4 (32bit) * 128 cluster numbers per block (512 bytes)
calc_fat_lba_addr:
		;instead of shift right 7 times in a loop, we copy over the hole byte (same as >>8) - and simply shift left 1 bit (<<1)
		lda fd_area + F32_fd::CurrentCluster	+0,	x
		asl
		lda fd_area + F32_fd::CurrentCluster	+1,x
		rol
		sta lba_addr+0
		lda fd_area + F32_fd::CurrentCluster	+2,x
		rol
		sta lba_addr+1
		lda fd_area + F32_fd::CurrentCluster	+3,x
		rol
		sta lba_addr+2
		lda fd_area + F32_fd::CurrentCluster	+3,x
		rol
		rol
		and	#$01;only bit 0
		sta lba_addr+3
		; add fat_lba_begin and lba_addr
		clc
		lda fat_lba_begin+0
		adc lba_addr +0
		sta lba_addr +0
		lda fat_lba_begin+1
		adc lba_addr +1
		sta lba_addr +1
		lda fat_lba_begin+2

		lda fat_lba_begin+3
		adc lba_addr +3
		sta lba_addr +3
		rts
		
		; check whether the EOC (end of cluster chain) cluster number is reached
		;
		; out:
		;	Z = 1 if EOC detected, Z=0 otherwise
is_fat_cln_end:
		lda fd_area + F32_fd::CurrentCluster+3, x
		and	#<(FAT_EOC>>24)
		cmp	#<(FAT_EOC>>24)
		bne	@e
		lda fd_area + F32_fd::CurrentCluster+2, x
		cmp	#<(FAT_EOC>>16)
		bne	@e
		lda fd_area + F32_fd::CurrentCluster+1, x
		cmp	#<(FAT_EOC>>8)
		bne	@e
		lda fd_area + F32_fd::CurrentCluster+0, x
		and #<FAT_EOC
		cmp	#<FAT_EOC
@e:		rts

		; extract next cluster number from the 512 fat block buffer
		; unsigned int offs = (cla << 2 & (BLOCK_SIZE-1));//offset within 512 byte block, cluster nr * 4 (32 Bit) and Bit 8-0 gives the offset
fat_next_cln:
		lda fd_area + F32_fd::CurrentCluster  +0,x
		asl
		asl
		tay
		lda fd_area + F32_fd::CurrentCluster  +0,x
		and #$c0	; we dont <<2 the bit15-8 of the cluster number but test bit 7,6 - if one is set, we simply use the "high" page of the block + the bit7-0 <<2 offset in y
		bne	fat_next_cln_hi
		lda	block_fat+0, y
		sta fd_area + F32_fd::CurrentCluster+0, x
		lda	block_fat+1, y
		sta fd_area + F32_fd::CurrentCluster+1, x
		lda	block_fat+2, y
		sta fd_area + F32_fd::CurrentCluster+2, x
		lda	block_fat+3, y
		sta fd_area + F32_fd::CurrentCluster+3, x
		rts
fat_next_cln_hi:
		lda	block_fat+$100, y
		sta fd_area + F32_fd::CurrentCluster+0, x
		lda	block_fat+$100+1, y
		sta fd_area + F32_fd::CurrentCluster+1, x
		lda	block_fat+$100+2, y
		sta fd_area + F32_fd::CurrentCluster+2, x
		lda	block_fat+$100+3, y
		sta fd_area + F32_fd::CurrentCluster+3, x
		rts


;---------------------------------------------------------------------
; Mount FAT32 on Partition 0
;---------------------------------------------------------------------
fat_mount:
		save
		
		; set lba_addr to $00000000 since we want to read the bootsector
		.repeat 4, i
			stz lba_addr + i
		.endrepeat

		SetVector sd_blktarget, read_blkptr
		jsr sd_read_block

		jsr fat_check_signature

		lda errno
		beq @l1
		jmp end_mount

@l1:
		part0 = sd_blktarget + BootSector::Partitions + PartTable::Partition_0

		lda part0 + PartitionEntry::TypeCode
		cmp #PartType_FAT32
		beq @l2
		cmp #PartType_FAT32_LBA
		beq @l2

		; type code not PartType_FAT32 or PartType_FAT32_LBA
		lda #fat_invalid_partition_type
		sta errno
		jmp end_mount

@l2:
		copy32 part0 + PartitionEntry::LBABegin, lba_addr

		SetVector sd_blktarget, read_blkptr
		; Read FAT Volume ID at LBABegin and Check signature
		jsr sd_read_block

		jsr fat_check_signature
		lda errno
		beq @l4
		jmp end_mount
@l4:

.ifdef DEBUGFAT
		jsr krn_primm
		.asciiz "MF: "
		lda sd_blktarget + VolumeID::MirrorFlags
		jsr krn_hexout
.endif


		; Bytes per Sector, must be 512 = $0200
		lda sd_blktarget + VolumeID::BytsPerSec
		bne @l5
		lda sd_blktarget + VolumeID::BytsPerSec + 1
		cmp #$02
		beq @l6
@l5:	lda #fat_invalid_sector_size
		sta errno
		jmp end_mount
@l6:

		; Sectors per Cluster. Valid: 1,2,4,8,16,32,64,128
		lda sd_blktarget + VolumeID::SecPerClus
		sta sectors_per_cluster

		; cluster_begin_lba = Partition_LBA_Begin + Number_of_Reserved_Sectors + (Number_of_FATs * Sectors_Per_FAT) -  (2 * sec/cluster);
		; fat_lba_begin		= Partition_LBA_Begin + Number_of_Reserved_Sectors
		; fat2_lba_begin	= Partition_LBA_Begin + Number_of_Reserved_Sectors + Sectors_Per_FAT
	
		; add number of reserved sectors to fat_lba_begin. store in cluster_begin_lba
		clc

		lda lba_addr + 0
		adc sd_blktarget + VolumeID::RsvdSecCnt + 0
		sta cluster_begin_lba + 0
		sta fat_lba_begin + 0
		lda lba_addr + 1
		adc sd_blktarget + VolumeID::RsvdSecCnt + 1
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

		; Number of FATs. Must be 2
		; add sectors_per_fat * 2 to cluster_begin_lba
		ldy sd_blktarget + VolumeID::NumFATs
@l7:	clc
		ldx #$00
@l8:	ror ; get carry flag back
		lda sd_blktarget + VolumeID::FATSz32,x ; sectors per fat
		adc cluster_begin_lba,x
		sta cluster_begin_lba,x
		inx
		rol ; save status register before cpx to save carry
		cpx #$04 ; 32Bit
		bne @l8
		dey
		bne @l7
	
		; calc fat end or begin or fat2
		clc
		lda sd_blktarget + VolumeID::FATSz32+0 ; sectors per fat
		adc fat_lba_begin	+0
		sta fat2_lba_begin	+0
		lda sd_blktarget + VolumeID::FATSz32+1
		adc fat_lba_begin	+1
		sta fat2_lba_begin	+1
		; TODO FIXME - we assume 16bit are sufficient for now since fat is placed at the beginning of the device

		; cluster_begin_lba_m2 -> cluster_begin_lba - (BPB_RootClus*sec/cluster)
		debug8 "sec/cl", sectors_per_cluster
		debug32 "cl_lba", cluster_begin_lba
		debug32 "lba", lba_addr
		debug16 "r_sec", sd_blktarget + VolumeID::RsvdSecCnt
		debug32 "f_sec", sd_blktarget + VolumeID::FATSz32
		debug16 "f_lba", fat_lba_begin
		debug16 "f2_lba", fat2_lba_begin

		;TODO FIXME we assume 2 here insteasd of using the value in BPB_RootClus
		; cluster_begin_lba_m2 -> cluster_begin_lba - (2*sec/cluster) -> sec/cluster << 1
		lda sectors_per_cluster ; max sec/cluster can be 128, with 2 (BPB_RootClus) * 128 wie may subtract max 256
		asl
		sta lba_addr        ;   used as tmp
		stz lba_addr +1     ;   safe carry
		rol	lba_addr +1
		sec	                ;   subtract from cluster_begin_lba
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

		;debug32s "clb2:", cluster_begin_lba

		; init file descriptor area
		jsr fat_init_fdarea

		Copy sd_blktarget + VolumeID::RootClus, root_dir_first_clus, 3
		; now we have the lba address of the first sector of the first cluster

end_mount:
		restore
		Copy root_dir_first_clus, fd_area + FD_INDEX_CURRENT_DIR + F32_fd::StartCluster, 3
		ldx #FD_INDEX_CURRENT_DIR
		rts


		;
		; out:
		;   x - FD_INDEX_TEMP_DIR offset to fd area
fat_open_rootdir:
		Copy root_dir_first_clus, fd_area + FD_INDEX_TEMP_DIR + F32_fd::StartCluster, 3
		ldx #FD_INDEX_TEMP_DIR
		rts

		; clone source file descriptor with offset x into fd_area to target fd with y
		; in:
		;   x - source offset into fd_area
		;   y - target offset into fd_area
fat_clone_fd:
		lda #FD_Entry_Size
		sta krn_tmp
@l1:	lda fd_area, x
		sta fd_area, y
		inx
		iny
		dec krn_tmp
		bpl @l1
		rts

		; in:
		;	x - offset to fd_area
		; out:
		;	carry - C=0 if file is open, C=1 otherwise
fat_isOpen:
		lda fd_area + F32_fd::StartCluster +3, x
		cmp #$ff	;#$ff means not open, carry is set...
		rts

fat_init_fdarea:
		ldx #$00
fat_init_fdarea_with_x:
		lda #$ff
@l1:		sta fd_area + F32_fd::StartCluster + 3 , x
		inx
		cpx #(FD_Entry_Size*FD_Entries_Max)
		bne @l1
		rts

		;
		; out:
		;       X - with index to fd_area
		;		A - errno if one, 0 otherwise
fat_alloc_fd:
		ldx #(2*FD_Entry_Size)	; skip 2 entries, they're reserverd for current and temp dir
@l1:	lda fd_area + F32_fd::StartCluster +3, x

		cmp #$ff	;#$ff means unused, return current x as offset
		beq @l2

		txa ; 2 cycles
		adc #FD_Entry_Size; carry must be clear from cmp #$ff above
		tax ; 2 cycles

		cpx #(FD_Entry_Size*FD_Entries_Max)
		bne @l1

		; Too many open files, no free file descriptor found
		lda #EMFILE
		rts
@l2:	lda #0
		rts

        ; in:
        ;   X - offset into fd_area
        ; out:
        ;   A - A = 0 on success, error code otherwise
fat_close:
		lda fd_area + F32_fd::StartCluster +3, x
		cmp #$ff	;#$ff means not open, carry is set...
		bcs @l1
		lda #$ff    ; otherwise mark as closed
		sta fd_area + F32_fd::StartCluster +3, x
@l1:	lda #0
		rts

fat_close_all:
		ldx #(2*FD_Entry_Size)	; skip 2 entries, they're reserverd for current and temp dir
		bra	fat_init_fdarea_with_x

		; get size of file in fd
		; in:
		;   x - fd offset
		; out:
		;   a - filesize lo
		;   x - filesize hi
fat_getfilesize:
		lda fd_area + F32_fd::FileSize + 0, x
		pha
		lda fd_area + F32_fd::FileSize + 1, x
		tax
		pla
		rts

		; find first dir entry
		; in:
		;   X 			- fd offset
		;	filenameptr	- with file name to search
		; out:
		;	C 			- carry = 1 if found and dirptr is set to the dir entry found, carry = 0 otherwise
fat_find_first:
		ldy #0				; TODO FIXME should be part of the matcher, also duplicate code buffer is already prepared in matcher.asm
@l1:	lda (filenameptr),y
		beq @l2
		sta filename_buf,y
		iny
		cpy #8+1+3	+1		;?buffer overflow
		bne @l1
@l2:	lda	#0
		sta filename_buf,y
		SetVector filename_matcher, krn_call_internal	;setup the filename matcher

		; internal find first, assumes that (krn_call_internal) is already setup
		; in:
		;   X - directory fd index into fd_area
fat_find_first_intern:
		jsr calc_lba_addr
		debug32 "lba", lba_addr
		SetVector sd_blktarget, read_blkptr

ff_l3:	SetVector sd_blktarget, dirptr	; dirptr to begin of target buffer
		jsr sd_read_block
		dec read_blkptr+1	; set read_blkptr to origin address

ff_l4:
		lda (dirptr)
		bne @l5				; first byte of dir entry is $00 (end of directory)?
		clc
		rts   				; we are at the end, C=0 and return
@l5:
		ldy #F32DirEntry::Attr		; else check if long filename entry
		lda (dirptr),y 		; we are only going to filter those here (or maybe not?)
		cmp #DIR_Attr_Mask_LongFilename
		beq fat_find_next

		jsr fat_find_first_matcher	; jmp indirect via (krn_call_internal), set to appropriate matcher strategy
		bcs ff_end
		
		; in:
		;   X - directory fd index into fd_area
fat_find_next:
		lda dirptr
		clc
		adc #DIR_Entry_Size
		sta dirptr
		bcc @l6
		inc dirptr+1
@l6:
		lda dirptr+1 	; end of block?
		cmp #>(sd_blktarget + sd_blocksize)
		bcc ff_l4			; no, process entry
		; TODO FIXME check whether the end of the cluster is reached - check whether sector_nr/block_nr reaches volume->SectorsPerCluster
		; lda startcluster
		; ora SectorsPerCluster
		; cmp lba...
		jsr inc_lba_address	; increment lba address to read next block
		bra ff_l3
ff_end:
		rts

fat_find_first_matcher:
		jmp	(krn_call_internal)

calc_dirptr_from_entry_nr:

		stz dirptr

		lsr
		ror dirptr
		ror
		ror dirptr
		ror
		ror dirptr

		clc
		adc #>sd_blktarget
		sta dirptr+1

		rts

calc_dir_entry_nr:
		phx

		lda dirptr
		sta krn_tmp

		lda dirptr+1
		sec
		sbc #>sd_blktarget

		ldx #$03
		clc
@l:
		rol krn_tmp
		rol
		dex
		bne @l

		plx
		rts

.include "matcher.asm"
buffer: .res 8+1+3,0
