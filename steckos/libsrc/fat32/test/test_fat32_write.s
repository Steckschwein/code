	.include "test_fat32.inc"

	.import __fat_init_fdarea
	.import fat_fopen
	
	.import asmunit_chrout
	krn_chrout=asmunit_chrout
	

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
		lda #<test_file_name
		ldx #>test_file_name
		;jsr fat_fopen
		;assertA EOK
		
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
		rts
mock_read_block:
		cmp32 lba_addr, $6800 ; load root cl block
		bne @err
		load_block block_root_cl
		rts
@err:
		fail "mock read_block"
mock_write_block:
		fail "mock write_block"
mock_not_implemented1:
		fail "mock 1"
mock_not_implemented2:
		fail "mock 2"
mock_not_implemented3:
		fail "mock 3"
mock_not_implemented4:
		fail "mock 4"

; fat32 geometry
.define LBA_BEGIN $00680000
.define SEC_PER_CL $01
.define ROOT_CL $02

setUp:
	.define test_start_cluster	$016a
	jsr __fat_init_fdarea

	set8 volumeID+VolumeID::BPB + BPB::SecPerClus, SEC_PER_CL
	set32 volumeID + VolumeID::EBPB + EBPB::RootClus, ROOT_CL
	set32 cluster_begin_lba, $67fe	;cl lba to $67fe
	set32 fat_lba_begin, $297e			;fat lba to
	
	;setup fd0 as root cluster
	set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
	set16 fd_area+(0*FD_Entry_Size)+F32_fd::offset, 0
	
	;setup fd1 as test cluster
	set32 fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
	set16 fd_area+(1*FD_Entry_Size)+F32_fd::offset, 0
	rts

.data
test_file_name: .asciiz "test01.tst"

block_root_cl:
	fat32_dir_entry_dir 	"DIR01   ", "   ", 8
	fat32_dir_entry_dir 	"DIR02   ", "   ", 9
	fat32_dir_entry_file "FILE01  ", "DAT", 0, 0		; 0 - no cluster reserved, 0 - size
	fat32_dir_entry_file "FILE02  ", "TXT", $a, 12	; $a - 1st cluster nr of file, 12 - byte

.bss
fat_data_read: .res 512, 0