.include "test_fat32.inc"

.import __fat_init_fdarea
.import __fat_opendir_cwd
.import fat_chdir

; mock defines
.export read_block=mock_read_block
.export write_block=mock_not_implemented
.export __rtc_systime_update=mock_not_implemented
.export cluster_nr_matcher=mock_not_implemented
.export fat_name_string=mock_not_implemented
.export path_inverse=mock_not_implemented
.export put_char=mock_not_implemented

debug_enabled=1
.code

; -------------------
		setup "fat_chdir_enotdir"
		lda #<test_file_name_1
		ldx #>test_file_name_1
		jsr fat_chdir
		assertZ 0
		assertA ENOTDIR

; -------------------
		setup "fat_chdir_enoent"
		lda #<test_dir_name_enoent
		ldx #>test_dir_name_enoent
		jsr fat_chdir
		assertZ 0
		assertA ENOENT

		brk

mock_read_block:
		load_block_if LBA_BEGIN, block_root_cl, @exit ; load root cl block
@exit:
		rts ; fail "mock read_block";  lba_addr

mock_not_implemented:
		fail "mock!"

data_loader	; define data loader

setUp:
		jsr __fat_init_fdarea

		set8  volumeID + VolumeID::BPB_SecPerClus, SEC_PER_CL
		set32 volumeID + VolumeID::EBPB_RootClus, ROOT_CL
		set32 volumeID+VolumeID::lba_data, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL))
		set32 volumeID+VolumeID::lba_fat, FAT_LBA		;fat lba to

		;setup fd0 (cwd) to root cluster
		set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
		set32 fd_area+(0*FD_Entry_Size)+F32_fd::SeekPos, 0
		rts

.data
	test_file_name_1: .asciiz "file01.dat"
	test_dir_name_1: .asciiz "dir01"
	test_dir_name_2: .asciiz "dir02"
	test_dir_name_enoent: .asciiz "enoent"

block_root_cl:
	fat32_dir_entry_dir 	"DIR01   ", "   ", 8
	fat32_dir_entry_dir 	"DIR02   ", "   ", 9
	fat32_dir_entry_file "FILE01  ", "DAT", 0, 0		; 0 - no cluster reserved, file length 0
	fat32_dir_entry_file "FILE02  ", "TXT", $a, 12	; $a - 1st cluster nr of file, file length 12 byte
