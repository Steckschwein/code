.include "test_fat32.inc"

.import __fat_init_fdarea
.import fat_fopen
.import fat_close
.import fat_write
.import fat_mkdir

; mock defines
.export read_block=mock_read_block
.export write_block=mock_write_block
.export rtc_systime_update=mock_rtc
.export cluster_nr_matcher=mock_not_implemented1
.export fat_name_string=mock_not_implemented2
.export path_inverse=mock_not_implemented3
.export put_char=mock_not_implemented4

.code

; -------------------
		setup "fat_mkdir_eexist"
		lda #<test_dir_name_eexist
		ldx #>test_dir_name_eexist
		jsr fat_mkdir
		assertZ 0
		assertA EEXIST

; -------------------
		setup "fat_mkdir_new"
		lda #<test_dir_name_mkdir
		ldx #>test_dir_name_mkdir
		jsr fat_mkdir
		assertZ 1
		assertA EOK

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
		setup "fat_write O_CREAT 1cl"
		ldy #O_CREAT
		lda #<test_file_name_1cl
		ldx #>test_file_name_1cl
		jsr fat_fopen
		assertA EOK
		assertX FD_Entry_Size*2	; assert FD reserved

		assertDirEntry block_data + 4 * $20 ;expect 4th entry created
			fat32_dir_entry_file "TST_01CL", "TST", 0, 0	; no cluster reserved yet
		assertFdEntry fd_area + (FD_Entry_Size*2)
				fd_entry_file 4, LBA_BEGIN, DIR_Attr_Mask_Archive
		set32 fd_area + (FD_Entry_Size*2) + F32_fd::FileSize, 3 * 512 + 3 ; 4 blocks

		jsr fat_write
		assertA EOK
		jsr fat_close

; -------------------
		setup "fat_write O_CREAT 2cl"
		ldy #O_CREAT
		lda #<test_file_name_2cl
		ldx #>test_file_name_2cl
		jsr fat_fopen
		assertA EOK
		assertX FD_Entry_Size*2	; assert FD reserved

		assertDirEntry $0480
				fat32_dir_entry_file "TST_02CL", "TST", 0, 0	; no cluster reserved yet
		assertFdEntry fd_area + (FD_Entry_Size*2)
				fd_entry_file 4, LBA_BEGIN, DIR_Attr_Mask_Archive
		; size to 4 blocks + 1 block, new cluster must be reserved, assert cl chain build
		set32 fd_area + (FD_Entry_Size*2) + F32_fd::FileSize, 4 * 512 + 3

;		TODO
;		jsr fat_write
;		assertA EOK
;		assertX FD_Entry_Size*2	; assert FD
;		assertDirEntry $0480
;			fat32_dir_entry_file "TST_02CL", "TST", 0, $10
		jsr fat_close

		brk

data_loader	; define data loader

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
		load_block LBA_BEGIN, block_root_cl ; load root cl block
		cmp32 lba_addr, FAT_LBA, :+
		;simulate fat block read
		m_memset block_fat+$000, $ff, $40	; simulate reserved
		m_memset block_fat+$100, $ff, $40	;
		m_memset block_fat+$40, $0, 4 ;

		lda #EOK
		rts

:		load_block FS_INFO_LBA, block_fsinfo

		assert32 $ffffffff, lba_addr
		fail "mock read_block"

mock_write_block:
		cmp32 lba_addr, LBA_BEGIN, :+
		rts
:		cmp32 lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * $10)+0), :+
		rts
:		cmp32 lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * $10)+1), :+
		rts
:		cmp32 lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * $10)+2), :+
		rts
:		cmp32 lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * $10)+3), :+
		rts
:		cmp32 lba_addr, FAT_LBA, :+
		rts
:		cmp32 lba_addr, FAT2_LBA, :+
		rts
:		cmp32 lba_addr, FS_INFO_LBA, :+
		rts
:		assert32 $ffffffff, lba_addr ; fail

mock_not_implemented1:
		fail "mock 1"
mock_not_implemented2:
		fail "mock 2"
mock_not_implemented3:
		fail "mock 3"
mock_not_implemented4:
		fail "mock 4"

setUp:
	jsr __fat_init_fdarea

	set8 volumeID+VolumeID::BPB + BPB::SecPerClus, SEC_PER_CL
	set8 volumeID+VolumeID::BPB + BPB::NumFATs, 2
	set32 volumeID + VolumeID::EBPB + EBPB::RootClus, ROOT_CL
	set32 volumeID + VolumeID::EBPB + EBPB::FATSz32, (FAT2_LBA - FAT_LBA)
	set32 cluster_begin_lba, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL))
	set32 fat_lba_begin, FAT_LBA
	set32 fat2_lba_begin, FAT2_LBA
	set32 fat_fsinfo_lba, FS_INFO_LBA

	;setup fd0 as root cluster
	set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
	set16 fd_area+(0*FD_Entry_Size)+F32_fd::offset, 0

	;setup fd1 as test cluster
	set32 fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
	set16 fd_area+(1*FD_Entry_Size)+F32_fd::offset, 0
	rts

.data
	test_file_name_1: 	.asciiz "test01.tst"
	test_file_name_1cl: 	.asciiz "tst_01cl.tst"
	test_file_name_2cl:	.asciiz "tst_02cl.tst"
	test_dir_name_eexist: .asciiz "dir01"
	test_dir_name_mkdir: .asciiz "dir03"

.bss
block_root_cl:
	fat32_dir_entry_dir 	"DIR01   ", "   ", 8
	fat32_dir_entry_dir 	"DIR02   ", "   ", 9
	fat32_dir_entry_file "FILE01  ", "DAT", 0, 0		; 0 - no cluster reserved, file length 0
	fat32_dir_entry_file "FILE02  ", "TXT", $a, 12	; $a - 1st cluster nr of file, file length 12 byte
	.res 32 * 12, 0

block_fsinfo:
	.byte $52, $52, $61, $41		;"RRaA"
	.res 480, 0
	.byte $72, $72, $41, $61 	;"rrAa"
	.byte 1,2,3,4
