	.include "asmunit.inc" 	; test api
	
	.include "common.inc"
	.include "errno.inc"
	.include "fat32.inc"
	.include "zeropage.inc"
	.include "fcntl.inc"
	
	.import __calc_lba_addr
	.import __fat_isroot
	.import __fat_init_fdarea
	.import __fat_alloc_fd
	.import fat_fread
	.import fat_fopen
	
	.import asmunit_chrout
	.export krn_chrout
	krn_chrout=asmunit_chrout
	
.macro setup testname
		test testname
		jsr setUp
.endmacro

; mock defines
.export __rtc_systime_update=mock_not_implemented0
.export cluster_nr_matcher=mock_not_implemented1
.export fat_name_string=mock_not_implemented2
.export path_inverse=mock_not_implemented3
.export put_char=mock_not_implemented4

; -------------------
		setup "fat_fopen O_CREAT"
		ldy #O_CREAT
		lda #<test_file_name
		ldx #>test_file_name
		;jsr fat_fopen
		;assertA EOK
		
		brk
		
mock_not_implemented0:
		fail "mock 0"
		rts
mock_not_implemented1:
		fail "mock 1"
		rts
mock_not_implemented2:
		fail "mock 2"
		rts
mock_not_implemented3:
		fail "mock 3"
		rts
mock_not_implemented4:
		fail "mock 4"
		rts

setUp:
	.define test_start_cluster	$016a
	jsr __fat_init_fdarea

	lda #4
	sta volumeID+VolumeID::BPB + BPB::SecPerClus

	set32 volumeID + VolumeID::EBPB + EBPB::RootClus, $02
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

.bss
fat_data_read: .res 512, 0