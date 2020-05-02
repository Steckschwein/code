.include "test_fat32.inc"

.import __fat_init_fdarea
.import __fat_opendir_cwd

; mock defines
.export read_block=mock_read_block
.export write_block=mock_not_implemented
.export __rtc_systime_update=mock_not_implemented
.export cluster_nr_matcher=mock_not_implemented
.export fat_name_string=mock_not_implemented
.export path_inverse=mock_not_implemented
.export put_char=mock_not_implemented

.code

; -------------------
		setup "__fat_opendir_cwd"
		lda #<test_file_name_1
		ldx #>test_file_name_1
		jsr __fat_opendir_cwd

		brk

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

mock_not_implemented:
		fail "mock!"

data_loader	; define data loader

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
