	.include "test_fat32.inc"

	.import __calc_lba_addr
	.import __fat_is_cln_zero
	.import __fat_init_fdarea
	.import __fat_alloc_fd
	.import fat_fopen
	.import fat_fread_byte

.code


; -------------------
		setup "fat_fseek empty file"
		;setup fd2 with test cluster, but 0 filesize
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
		set8 fd_area+(2*FD_Entry_Size)+F32_fd::Attr, DIR_Attr_Mask_Archive
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::seek_pos, 0
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, 0 ; empty file

		ldx #(2*FD_Entry_Size) ; 0 byte file
		jsr fat_fseek
		assertCarry 1; expect "error"
		assertA EOF ; EOF
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged
		assert32 0, fd_area+1*FD_Entry_Size)+F32_fd::seek_pos
		assert32 test_start_cluster+3, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster

		brk

setUp:
	jsr __fat_init_fdarea
	set_sec_per_cl SEC_PER_CL
	set32 volumeID + VolumeID::EBPB_RootClus, ROOT_CL
	set32 volumeID + VolumeID::lba_fat, FAT_LBA		;fat lba

	;setup fd0 as root cluster
	set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
	set8 fd_area+(0*FD_Entry_Size)+F32_fd::Attr, DIR_Attr_Mask_Dir
	set32 fd_area+(0*FD_Entry_Size)+F32_fd::seek_pos, 0
	;setup fd1 with test cluster
	set32 fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
	set8 fd_area+(1*FD_Entry_Size)+F32_fd::Attr, DIR_Attr_Mask_Archive
	set32 fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos, 0
	set32 fd_area+(1*FD_Entry_Size)+F32_fd::FileSize, $1000

	rts

.export __rtc_systime_update=mock_not_implemented
.export read_block=mock_read_block
.export sd_read_multiblock=mock_not_implemented
.export write_block=mock_not_implemented
.export cluster_nr_matcher=mock_not_implemented
.export fat_name_string=mock_not_implemented
.export path_inverse=mock_not_implemented
.export put_char=mock_not_implemented

data_loader	; define data loader

mock_not_implemented:
		fail "mock was called, not implemented yet!"

debug_enabled=1

mock_read_block:
		debug32 "mock_read_block lba", lba_addr
		cpx #(1*FD_Entry_Size)
		bcs :+
		lda #EINVAL
		rts
:
		; defaults to dir entry data
		load_block_if LBA_BEGIN, block_root_cl, @exit ; load root cl block

		; fat block $2980 read?
		cmp32_ne lba_addr, FAT_LBA+2, :+
			; ... simulate fat block read, just fill some values which are reached if the fat32 implementation is correct ;)
			set32 block_fat+((test_start_cluster+0)<<2), (test_start_cluster+3) ; build a fragmented chain
			set32 block_fat+((test_start_cluster+3)<<2), (test_start_cluster+6)
			set32 block_fat+((test_start_cluster+6)<<2), FAT_EOC
      jmp @exit_inc
:
		; data block read?
		; - for tests with 2sec/cl
		load_block_if (LBA_BEGIN - ROOT_CL * 2 + (test_start_cluster+0) * 2 + 0), test_block_data_0_0, @exit
		load_block_if (LBA_BEGIN - ROOT_CL * 2 + (test_start_cluster+0) * 2 + 1), test_block_data_0_1, @exit
		load_block_if (LBA_BEGIN - ROOT_CL * 2 + (test_start_cluster+3) * 2 + 0), test_block_data_1_0, @exit
		load_block_if (LBA_BEGIN - ROOT_CL * 2 + (test_start_cluster+3) * 2 + 1), test_block_data_1_1, @exit
;		load_block_if (LBA_BEGIN - ROOT_CL * 2 + (test_start_cluster+6) * 2 + 0), test_block_data_1_0, @exit
;		load_block_if (LBA_BEGIN - ROOT_CL * 2 + (test_start_cluster+6) * 2 + 1), test_block_data_1_1, @exit
		; - for tests with 4sec/cl
		load_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + test_start_cluster * SEC_PER_CL + 0), test_block_data_4sec_cl, @exit

    ; end up here is no valid data
    ldy #0
:   tya
    sta block_data+$000,y
    sta block_data+$100,y
    iny
    bne :-

@exit_inc:
		inc read_blkptr+1 ; => same behavior as real block read implementation
@exit:
		lda #EOK
		rts

.data
test_file_name_1: .asciiz "file01.dat"
test_file_name_2: .asciiz "file02.txt"
test_file_name_enoent:	.asciiz "enoent.tst"

block_root_cl:
	fat32_dir_entry_dir  "DIR01   ", "   ", 8
	fat32_dir_entry_dir  "DIR02   ", "   ", 9
	fat32_dir_entry_file "FILE01  ", "DAT", 0, 0 ; 0 - no cluster reserved, 0 - size
	fat32_dir_entry_file "FILE02  ", "TXT", 10, 12	; 10 - 1st cluster nr of file, 12 - byte file size

test_block_data_0_0:
  .byte "B0/C0"; block 0, cluster 0
	.res 256-5,0
  .byte "A"
	.res 256-1,0
test_block_data_0_1:
  .byte "B1/C0"; block 1, cluster 0
	.res 256-5,0
  .byte "B"
	.res 256-1,0
test_block_data_1_0:
  .byte "B0/C1"; block 0, cluster 1
	.res 256-5,0
  .byte "C"
	.res 256-1,0
test_block_data_1_1:
  .byte "B1/C1"; block 1, cluster 1
	.res 256-5,0
  .byte "D"
	.res 256-1,0

test_block_data_4sec_cl:
	.byte "4s/cl"
	.res 250,0

.bss
data_read: .res 8*sd_blocksize
