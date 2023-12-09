.include "test_fat32.inc"

.autoimport

; mock defines
.export read_block=mock_read_block
.export write_block=mock_write_block
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
		assertCarry 1
		assertA ENOTDIR

; -------------------
		setup "fat_chdir_enoent"
		lda #<test_dir_name_enoent
		ldx #>test_dir_name_enoent
		jsr fat_chdir
		assertCarry 1
		assertA ENOENT

; -------------------
		setup "fat_mkdir"
		lda #<test_dir_name_new
		ldx #>test_dir_name_new
		jsr fat_mkdir
		assertCarry 0
		assertA EOK

		brk

; cluster search will find following clustes
TEST_FILE_CL=$10
TEST_FILE_CL2=$19

data_loader  ; define data loader
data_writer ; define data writer

mock_read_block:
    tax ; mock destruction of X
    debug32 "mock_read_block lba", lba_addr
		load_block_if LBA_BEGIN, block_root_cl, @ok ; load root cl block
    load_block_if (FAT_LBA+(TEST_FILE_CL>>7)), block_fat_0, @ok
    load_block_if FS_INFO_LBA, block_fsinfo, @ok

    fail "read lba not handled!"
@ok:
    lda #EOK
		rts

mock_write_block:
    tax ; mock destruction of X
    debug32 "mock_write_block lba", lba_addr
    debug16 "mock_write_block wptr", write_blkptr
    store_block_if LBA_BEGIN, block_root_cl, @ok ; write root cl block
    store_block_if FS_INFO_LBA, block_fsinfo, @ok ;
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+0), block_data_00, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+1), block_data_01, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+2), block_data_02, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+3), block_data_03, @ok

    store_block_if (FAT_LBA+(TEST_FILE_CL>>7)), block_fat_0, @ok
    store_block_if (FAT2_LBA+(TEST_FILE_CL>>7)), block_fat2_0, @ok

    fail "write lba not handled!"
@ok:
    lda #EOK
    rts


mock_not_implemented:
		fail "mock!"

setUp:
		jsr __fat_init_fdarea
    init_volume_id SEC_PER_CL

		;setup fd0 (cwd) to root cluster
		set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
		set32 fd_area+(0*FD_Entry_Size)+F32_fd::SeekPos, 0

    init_block block_root_cl_init, block_root_cl
    init_block block_fsinfo_init, block_fsinfo
		rts

.data
	test_file_name_1: .asciiz "file01.dat"
	test_dir_name_1: .asciiz "dir01"
	test_dir_name_2: .asciiz "dir02"
	test_dir_name_enoent: .asciiz "enoent"
  test_dir_name_new: .asciiz "dir new"

block_root_cl_init:
	fat32_dir_entry_dir 	"DIR01   ", "   ", 8
	fat32_dir_entry_dir 	"DIR02   ", "   ", 9
	fat32_dir_entry_file "FILE01  ", "DAT", 0, 0		; 0 - no cluster reserved, file length 0
	fat32_dir_entry_file "FILE02  ", "TXT", 10, 12	; $a - 1st cluster nr of file, file length 12 byte
  .res 512-(4*DIR_Entry_Size),0

block_fsinfo_init:
  .byte "RRaA"
  .res 480, 0
  .byte "rrAa"
  .dword $100 ; edge case, 32bit add/sub
  .dword $02
  .res 12,0
  .byte 0,0,$55,$aa

.bss
block_fat_0:    .res sd_blocksize
block_fat2_0:   .res sd_blocksize
block_root_cl:  .res sd_blocksize
block_fsinfo:   .res sd_blocksize
block_data_00:  .res sd_blocksize
block_data_01:  .res sd_blocksize
block_data_02:  .res sd_blocksize
block_data_03:  .res sd_blocksize
