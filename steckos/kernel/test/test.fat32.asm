	.include "asmunit.inc" 	; test api
	
	.include "common.inc"
	.include "errno.inc"
	.include "fat32.inc"
	.include "zeropage.inc"
	
	
	.import __calc_lba_addr
	.import __fat_isroot
	.import fat_alloc_fd
	.import fat_fread
	
	.import asmunit_chrout
	.export krn_chrout
	krn_chrout=asmunit_chrout
	
.macro setup testname
		test_name testname
		jsr setUp
.endmacro
	
.segment "KERNEL"	; test must be placed into kernel segment, cuz we wanna use the same linker config

; -------------------		
		setup "fat_alloc_fd"	; test init
		lda #$ff
		ldx #(2*FD_Entry_Size)
:		sta fd_area,x
		inx
		cpx #(3*FD_Entry_Size)
		bne :-
		jsr fat_alloc_fd
		assertX (2*FD_Entry_Size)
		assert32 0, (2*FD_Entry_Size)+fd_area+F32_fd::CurrentCluster
		assert32 0, (2*FD_Entry_Size)+fd_area+F32_fd::FileSize
		assert16 0, (2*FD_Entry_Size)+fd_area+F32_fd::offset

; -------------------		
		setup "__fat_isroot"
		
		ldx #(0*FD_Entry_Size)
		jsr __fat_isroot
		assertZero 1		; expect fd0 - "is root"
		assertX (0*FD_Entry_Size)

		ldx #(1*FD_Entry_Size)
		jsr __fat_isroot
		assertZero 0		; expect fd0 - "is not root"
		assertX (1*FD_Entry_Size)
		
; -------------------		
		setup "__calc_lba_addr with root"
		ldx #(0*FD_Entry_Size)
		jsr __calc_lba_addr
		assertX (0*FD_Entry_Size)
		assert32 $00006800, lba_addr ; expect $67fe + $2 => the root dir lba
		
		setup "__calc_lba_addr with some clnr"
		ldx #(1*FD_Entry_Size)
		jsr __calc_lba_addr
		assertX (1*FD_Entry_Size)
		assert32 $00006968, lba_addr ; expect $67fe + (clnr * sec/cl) => $67fe + $16a * 1 = $6968		
		
; -------------------		
		setup "__calc_lba_addr 8s/cl +10 blocks"
		ldx #(1*FD_Entry_Size)
		lda #8
		sta volumeID+VolumeID::BPB + BPB::SecPerClus	
		lda #10 ; 10 blocks offset
		sta fd_area+F32_fd::offset+0,x

		jsr __calc_lba_addr
		assertX (1*FD_Entry_Size)
		assert32 $00007358, lba_addr ; expect $67fe + (clnr * sec/cl) + 10 => $67fe + $16a * 8 + 10 = $7358
				
; -------------------		
		setup "fat_fread 0 blocks 1sec/cl"
		ldx #(1*FD_Entry_Size)
		SetVector data_read, read_blkptr
		ldy #0
		jsr fat_fread
		assertZero 1
		assertA EOK
		assertX (1*FD_Entry_Size)
		assertY 0					; nothing read		
		
; -------------------		
		setup "fat_fread 1 blocks 1sec/cl"
		SetVector data_read, read_blkptr
		ldy #1
		ldx #(1*FD_Entry_Size)
		jsr fat_fread
		assertZero 1
		assertA EOK
		assertX (1*FD_Entry_Size)
		assertY 1
		assert32 $00006968, lba_addr ; expect $67fe + (clnr * sec/cl) => $67fe + $016a * 1= $6968
		assert16 data_read+$0200, read_blkptr
		assert32 $16a, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster
		assert8 1, fd_area+(1*FD_Entry_Size)+F32_fd::offset
		
; -------------------		
		setup "fat_fread 2 blocks 1sec/cl"
		SetVector data_read, read_blkptr
		ldy #2	; 2 blocks
		ldx #(1*FD_Entry_Size)
		jsr fat_fread
		assertZero 1
		assertA EOK
		assertX (1*FD_Entry_Size)
		assertY 2
		assert32 $00006969, lba_addr ; expect $67fe + (clnr * sec/cl) => $67fe + $016b * 1= $6969
		assert32 $16b, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster
;		assert16 data_read+$0200, read_blkptr
;		assert8 1, fd_area+(1*FD_Entry_Size)+F32_fd::offset+0

; -------------------		
		setup "fat_fread 4 blocks 1sec/cl"
		SetVector data_read, read_blkptr
		ldy #2	; 2 blocks
		ldx #(1*FD_Entry_Size)
		jsr fat_fread
		assertZero 1
		assertA EOK
		assertX (1*FD_Entry_Size)
		assertY 4
		assert32 $0000696b, lba_addr ; expect $67fe + (clnr * sec/cl) => $67fe + $016d * 1= $696b
		assert32 $16d, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster
		
		brk

setUp:
	.define test_start_cluster	$016a
	
	lda #1
	sta volumeID+VolumeID::BPB + BPB::SecPerClus

	set32 volumeID + VolumeID::EBPB + EBPB::RootClus, $02
	set32 cluster_begin_lba, $67fe	;cl lba to $67fe
	set32 fat_lba_begin, $297e			;fat lba to 	
	
	;setup fd0 as root cluster
	set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
	set16 fd_area+(0*FD_Entry_Size)+F32_fd::offset, 0
	
	;setup fd1 as with test cluster
	set32 fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
	set16 fd_area+(1*FD_Entry_Size)+F32_fd::offset, 0
	
	rts

.export __rtc_systime_update=mock
.export read_block=mock_read_block
.export sd_read_multiblock=mock
.export write_block=mock
.export dirname_mask_matcher=mock
.export cluster_nr_matcher=mock
.export fat_name_string=mock
.export path_inverse=mock
.export put_char=mock
.export string_fat_mask=mock
.export string_fat_name=mock


mock:
		fail "mock was called!"

		rts

mock_read_block:
	;debug32 "m_rd", lba_addr
	phx
	cmp32 lba_addr, $2980	;fat block $2980 read?
	bne :+
	;simulate fat block read, just fill some values which are reached if the fat32 implementation is correct ;)
	set32 block_fat+(test_start_cluster<<2 & (sd_blocksize-1)), (test_start_cluster+1)
	assert32 $016b, block_fat+$01a8
:		
	plx
	inc read_blkptr+1	; same behaviour as real implementation
	lda #EOK
	rts
		
data_read: .res 512, 0

.segment "ASMUNIT"
