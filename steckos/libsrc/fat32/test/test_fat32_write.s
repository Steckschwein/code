	.include "test_fat32.inc"

	.import __fat_init_fdarea
	.import fat_fopen
	.import fat_close
	.import fat_write

	.import asmunit_chrout
	krn_chrout=asmunit_chrout

; fat32 geometry
.define LBA_BEGIN $00006800
.define FAT_LBA $297e
.define SEC_PER_CL 1
.define ROOT_CL $02


; mock defines
.export read_block=mock_read_block
.export write_block=mock_write_block
.export __rtc_systime_update=mock_rtc
.export cluster_nr_matcher=mock_not_implemented1
.export fat_name_string=mock_not_implemented2
.export path_inverse=mock_not_implemented3
.export put_char=mock_not_implemented4

.zeropage
	test_data_ptr: .res 2

.code

; -------------------
		setup "fat_fopen O_CREAT"
		ldy #O_CREAT
		lda #<test_file_name_1
		ldx #>test_file_name_1
		jsr fat_fopen
		assertA EOK
		assertX FD_Entry_Size*2
		assertDirEntry $0480
			fat32_dir_entry_file "TEST01  ", "TST", 0, 0		; 0 - no cluster reserved, file length 0
		assertFdEntry fd_area + (FD_Entry_Size*2)
			fd_entry_file 4, LBA_BEGIN, DIR_Attr_Mask_Archive
		jsr fat_close

; -------------------
		setup "fat_write O_CREAT"
		ldy #O_CREAT
		lda #<test_file_name_2
		ldx #>test_file_name_2
		jsr fat_fopen
		assertA EOK
		assertX FD_Entry_Size*2	; assert FD

		assertDirEntry $0480
 			fat32_dir_entry_file "TEST02  ", "TST", 0, 0
		assertFdEntry fd_area + (FD_Entry_Size*2)
				fd_entry_file 4, LBA_BEGIN, DIR_Attr_Mask_Archive


;		jsr fat_write
		assertA EOK
		assertX FD_Entry_Size*2	; assert FD

;		assertDirEntry $0480
;			fat32_dir_entry_file "TEST02  ", "TST", 0, 33

		jsr fat_close

		brk

load_test_data:
		lda #0
		ldy #0
@l0:	lda (test_data_ptr),y
		sta (read_blkptr), y
		iny
		bne @l0
		rts

mock_rtc:
		m_memcpy	_rtc_ts, rtc_systime_t, 8
		rts
_rtc_ts:
		.byte 34	; tm_sec	.byte		;0-59
		.byte 22	; tm_min	.byte		;0-59
		.byte 11	; tm_hour	.byte		;0-23
		.byte 10	; m_mday	.byte		;1-31
		.byte 03	; tm_mon	.byte	1	;0-11 0-jan, 11-dec
		.byte 120; tm_year	.word  70	;years since 1900
		.byte 06 ; tm_wday	.byte		;
		rts

mock_read_block:
		cmp32 lba_addr, LBA_BEGIN; load root cl block
		bne :+
		load_block block_root_cl
		rts
:
		cmp32 lba_addr, FAT_LBA
		bne @err
		load_block block_fat_01
		rts
@err:
		assert32 $22, lba_addr
		fail "mock read_block"

mock_write_block:
		cmp32 lba_addr, LBA_BEGIN
		bne :+
		rts
:		cmp32 lba_addr, FAT_LBA
		bne @err
		rts
@err:
		assert32 $11, lba_addr
		fail "mock write_block"

mock_not_implemented1:
		fail "mock 1"
mock_not_implemented2:
		fail "mock 2"
mock_not_implemented3:
		fail "mock 3"
mock_not_implemented4:
		fail "mock 4"

setUp:
	.define test_start_cluster	$016a
	jsr __fat_init_fdarea

	set8 volumeID+VolumeID::BPB + BPB::SecPerClus, SEC_PER_CL
	set32 volumeID + VolumeID::EBPB + EBPB::RootClus, ROOT_CL
	set32 cluster_begin_lba, $67fe	;cl lba to $67fe
	set32 fat_lba_begin, FAT_LBA		;fat lba to

	;setup fd0 as root cluster
	set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
	set16 fd_area+(0*FD_Entry_Size)+F32_fd::offset, 0

	;setup fd1 as test cluster
	set32 fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
	set16 fd_area+(1*FD_Entry_Size)+F32_fd::offset, 0
	rts

.data
	test_file_name_1: .asciiz "test01.tst"
	test_file_name_2: .asciiz "test02.tst"

block_root_cl:
	fat32_dir_entry_dir 	"DIR01   ", "   ", 8
	fat32_dir_entry_dir 	"DIR02   ", "   ", 9
	fat32_dir_entry_file "FILE01  ", "DAT", 0, 0		; 0 - no cluster reserved, file length 0
	fat32_dir_entry_file "FILE02  ", "TXT", $a, 12	; $a - 1st cluster nr of file, file length 12 byte

.bss
block_fat_01:
