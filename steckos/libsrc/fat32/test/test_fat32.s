.include "test_fat32.inc"

.autoimport

debug_enabled=1

.code
; -------------------
		setup "__fat_init_fdarea / isOpen"	; test init fd area
    	jsr __fat_init_fdarea
		ldx #(2*FD_Entry_Size)
:		lda fd_area,x
    assertA $0
		inx
		cpx #(FD_Entry_Size*FD_Entries_Max)
		bne :-

; -------------------
		setup "__fat_alloc_fd"
		jsr __fat_alloc_fd
    assertCarry 0
		assertX (2*FD_Entry_Size); expect x point to first fd entry which is 2*FD_Entry_Size, cause the first 2 entries are reserved
		assert32 0, (2*FD_Entry_Size)+fd_area+F32_fd::CurrentCluster
		assert32 0, (2*FD_Entry_Size)+fd_area+F32_fd::FileSize
		assert32 0, (2*FD_Entry_Size)+fd_area+F32_fd::SeekPos
		assert8 $0, (2*FD_Entry_Size)+fd_area+F32_fd::flags
    assert8 FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY, (2*FD_Entry_Size)+fd_area+F32_fd::status

; -------------------
		setup "__fat_alloc_fd with error"
    ldy #FD_Entries_Max-2 ; -2 => 2 entries for cd and temp dir

:		jsr __fat_alloc_fd
    assertCarry 0
		dey
		bne :-
		jsr __fat_alloc_fd
    assertCarry 1
		assertA EMFILE

; -------------------
		setup "__fat_is_cln_zero"

		ldx #(0*FD_Entry_Size)
		jsr __fat_is_cln_zero
		assertZero 1		; expect fd0 - "is root"
		assertX (0*FD_Entry_Size)

		ldx #(1*FD_Entry_Size)
		jsr __fat_is_cln_zero
		assertZero 0		; expect fd0 - "is not root"
		assertX (1*FD_Entry_Size)

; -------------------
		setup "__calc_lba_addr with root"
		ldx #(0*FD_Entry_Size)
		jsr __calc_lba_addr
		assertX (0*FD_Entry_Size)
		assert32 LBA_BEGIN, lba_addr

; -------------------
		setup "__calc_lba_addr with some clnr"
		ldx #(1*FD_Entry_Size)
		jsr __calc_lba_addr
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * SEC_PER_CL + test_start_cluster * SEC_PER_CL, lba_addr ; expect $67fe + (clnr * sec/cl) => $67fe + $16a * 1 = $6968

; -------------------
		setup "__calc_lba_addr 8s/cl +10 blocks"
		ldx #(1*FD_Entry_Size)
    init_volume_id 8

		jsr __calc_lba_addr
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * 8 + test_start_cluster * 8 + 0, lba_addr ; expect $68f0 + (clnr * sec/cl) => $67f0 + $16a *8 + 10 = $7340

		lda #$02*7 ; 7 blocks offset
		sta fd_area+F32_fd::SeekPos+1,x
		jsr __calc_lba_addr
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * 8 + test_start_cluster * 8 + 7, lba_addr ; expect $68f0 + (clnr * sec/cl) => $67f0 + $16a *8 + 10 = $7347

		lda #$02*2 ; 2 blocks
		sta fd_area+F32_fd::SeekPos+1,x
		jsr __calc_lba_addr
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * 8 + test_start_cluster * 8 + 2, lba_addr ; expect $68f0 + (clnr * sec/cl) => $67f0 + $16a *8 + 10 = $7342

; -------------------
		setup "fat_fopen O_RDONLY ENOENT"

		ldy #O_RDONLY
		lda #<test_file_name_enoent
		ldx #>test_file_name_enoent
		jsr fat_fopen
		assertC 1
		assertA ENOENT

; -------------------
		setup "fat_fopen O_RDONLY overflow"

    ldy #FD_Entries_Max-2 ; -2 => 2 entries for cd and temp dir
:   phy
		ldy #O_RDONLY
		lda #<test_file_name_1
		ldx #>test_file_name_1
		jsr fat_fopen
		assertCarry 0
		ply
    dey
    bne :-

		ldy #O_RDONLY
		lda #<test_file_name_1
		ldx #>test_file_name_1
		jsr fat_fopen
		assertA EMFILE
		assertCarry 1

; -------------------
		setup "fat_fopen O_RDONLY"

		ldy #O_RDONLY
		lda #<test_file_name_1
		ldx #>test_file_name_1
		jsr fat_fopen
		assertCarry 0
		assertX FD_Entry_Size*2
		assertDirEntry block_data+2*DIR_Entry_Size ; offset see below
			fat32_dir_entry_file "FILE01  ", "DAT", 0, 0

; -------------------
		setup "fat_fopen O_RWONLY"

		ldy #O_RDONLY
		lda #<test_file_name_2
		ldx #>test_file_name_2
		jsr fat_fopen
		assertCarry 0
		assertX 2*FD_Entry_Size
		assertDirEntry block_data+3*DIR_Entry_Size ; offset see below
			fat32_dir_entry_file "FILE02  ", "TXT", $0a, 12

; -------------------
		setup "fat_fread_byte with error"
		ldx #(2*FD_Entry_Size) ; use fd(2) - i/o error cause not open
		jsr fat_fread_byte
		assertA EINVAL
		assertCarry 1; expect error
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged

; -------------------
		setup "fat_fread_byte empty file"
		;setup fd2 with test cluster, but 0 filesize
		set8 fd_area+(2*FD_Entry_Size)+F32_fd::status, FD_STATUS_FILE_OPEN
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
		set8 fd_area+(2*FD_Entry_Size)+F32_fd::Attr, DIR_Attr_Mask_Archive
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos, 0
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, 0 ; empty file

		ldx #(2*FD_Entry_Size) ; 0 byte file
		jsr fat_fread_byte
		assertCarry 1; expect "error"
		assertA EOK ; EOF
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged
		assert32 0, fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos
    assert8 FD_STATUS_FILE_OPEN, fd_area+(2*FD_Entry_Size)+F32_fd::status

; -------------------
		setup "fat_fread_byte touched file"
		set8 fd_area+(2*FD_Entry_Size)+F32_fd::status, FD_STATUS_FILE_OPEN
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster, 0 ; touched file, no cluster reserved
		set8 fd_area+(2*FD_Entry_Size)+F32_fd::Attr, DIR_Attr_Mask_Archive
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos, 0
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, 0

		ldx #(2*FD_Entry_Size)
		jsr fat_fread_byte
		assertCarry 1; expect "error"
		assertA EOK ; EOF
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged
		assert32 0, fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos
    assert8 FD_STATUS_FILE_OPEN, fd_area+(2*FD_Entry_Size)+F32_fd::status

; -------------------
		setup "fat_fread_byte 1 byte 4s/cl"
		ldx #(1*FD_Entry_Size)
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA '4' ; see test_block_data_4sec_cl
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * SEC_PER_CL + test_start_cluster * SEC_PER_CL, lba_addr ; expect $67fe + (clnr * sec/cl) => $67fe + $16a * 1 = $6968
		assert32 $16a, fd_area+(1*FD_Entry_Size)+F32_fd::StartCluster
		assert32 $16a, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster
		assert32 1, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos
    assert8 FD_STATUS_FILE_OPEN, fd_area+(1*FD_Entry_Size)+F32_fd::status

; -------------------
		setup "fat_fread_byte 2 byte 4s/cl"
		ldx #(1*FD_Entry_Size)
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA '4'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA 's'
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * SEC_PER_CL + test_start_cluster * SEC_PER_CL, lba_addr
		assert32 $16a, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster
		assert32 2, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos
    assert8 FD_STATUS_FILE_OPEN, fd_area+(1*FD_Entry_Size)+F32_fd::status

; -------------------
		setup "fat_fread_byte 4 bytes 4s/cl"
		ldx #(1*FD_Entry_Size)
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA '4'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA 's'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA '/'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA 'c'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA 'l'
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * SEC_PER_CL + test_start_cluster * SEC_PER_CL, lba_addr
		assert32 $16a, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster
		assert32 5, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos

; -------------------
		setup "fat_fread_byte 2 blocks 2s/cl"
		init_volume_id 2

		ldx #(1*FD_Entry_Size)
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA 'B'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA '0'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA '/'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA 'C'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA '0'

		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * 2 + test_start_cluster * 2, lba_addr
		assert32 test_start_cluster, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster
		assert32 5, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos

		ldy #251
:		jsr fat_fread_byte
		dey
		bne :-
		assertCarry 0; ok
:		jsr fat_fread_byte
		assertCarry 0; ok
		dey
		bne :-

		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * 2 + test_start_cluster * 2, lba_addr
		assert32 test_start_cluster, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster ; - no new cluster selected
		assert32 $0200, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos ; seek pos at begin of next block

		jsr fat_fread_byte
		assertCarry 0; ok
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * 2 + test_start_cluster * 2 + 1, lba_addr ; lba +1
		assert32 test_start_cluster, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster ; - no new cluster selected
		assert32 $0201, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos


; -------------------
		setup "fat_fread_byte 3 blocks 2s/cl"
    init_volume_id 2

		set32 fd_area+(1*FD_Entry_Size)+F32_fd::FileSize, (512*2+5) ; setup filesize
		assert32 0, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos

		ldx #(1*FD_Entry_Size)
		jsr fat_fread_byte
		assertCarry 0
		assertA 'B'
		assert32 1, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * 2 + test_start_cluster * 2, lba_addr
		assert32 test_start_cluster, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster ; - no new cluster selected

		jsr fat_fread_byte
		assertCarry 0
		assertA '0'
		assert32 2, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos
		assertX (1*FD_Entry_Size)

		jsr fat_fread_byte
		assertCarry 0
		assertA '/'
		assertX (1*FD_Entry_Size)

		jsr fat_fread_byte
		assertCarry 0
		assertA 'C'
		assertX (1*FD_Entry_Size)

		jsr fat_fread_byte
		assertCarry 0
		assertA '0'
		assertX (1*FD_Entry_Size)

		ldy #251
:		jsr fat_fread_byte
		assertCarry 0
		dey
    bne :-

		jsr fat_fread_byte
		assertCarry 0
		assertA 'A'
		assertX (1*FD_Entry_Size)
		assert32 $101, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos

:		jsr fat_fread_byte
		assertCarry 0
    cmp32_ne fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos, $300, :- ; read until seek pos reached

		jsr fat_fread_byte
		assertCarry 0
		assertA 'B'
		assertX (1*FD_Entry_Size)
		assert32 $301, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos

:		jsr fat_fread_byte
		assertCarry 0
    cmp32_ne fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos, $400, :- ; read until seek pos reached
		assert32 test_start_cluster, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster

		jsr fat_fread_byte
		assertCarry 0
		assertA 'B'
		assert32 $401, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos
		jsr fat_fread_byte
		assertCarry 0
		assertA '0'
		assert32 $402, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos
		jsr fat_fread_byte
		assertCarry 0
		assertA '/'
		assert32 $403, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos
		jsr fat_fread_byte
		assertCarry 0
		assertA 'C'
		assert32 $404, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos
		jsr fat_fread_byte
		assertCarry 0
		assertA '1'
		assert32 $405, fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos

		jsr fat_fread_byte
		assertCarry 1

		assert32 (512*2+5), fd_area+(1*FD_Entry_Size)+F32_fd::FileSize
		assert32 (512*2+5), fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos ; expect position at EOF (filesize)
		assert32 test_start_cluster+3, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster

		jsr fat_fread_byte
		assertCarry 1

		brk

setUp:
  ldx #0
	jsr __fat_init_fdarea
	init_volume_id SEC_PER_CL

	;setup fd0 as root cluster
	set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
	set8 fd_area+(0*FD_Entry_Size)+F32_fd::Attr, DIR_Attr_Mask_Dir
	set32 fd_area+(0*FD_Entry_Size)+F32_fd::SeekPos, 0
	;setup fd1 with test cluster
	set8 fd_area+(1*FD_Entry_Size)+F32_fd::status, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY
  set32 fd_area+(1*FD_Entry_Size)+F32_fd::StartCluster, test_start_cluster
	set32 fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
	set8 fd_area+(1*FD_Entry_Size)+F32_fd::Attr, DIR_Attr_Mask_Archive
	set32 fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos, 0
	set8 fd_area+(1*FD_Entry_Size)+F32_fd::flags, O_RDONLY
	set32 fd_area+(1*FD_Entry_Size)+F32_fd::FileSize, $1000

	rts

.export read_block=mock_read_block
.export __rtc_systime_update=   mock_not_implemented
.export sd_read_multiblock=     mock_not_implemented
.export write_block=            mock_not_implemented
.export cluster_nr_matcher=     mock_not_implemented
.export fat_name_string=        mock_not_implemented
.export path_inverse=           mock_not_implemented
.export put_char=               mock_not_implemented

data_loader	; define data loader

mock_not_implemented:
		fail "mock was called, not implemented yet!"

mock_read_block:
		debug32 "mock_read_block lba", lba_addr
		cpx #(1*FD_Entry_Size)
		bcs :+
		lda #EINVAL
		rts
:
		; defaults to dir entry data
		load_block_if LBA_BEGIN, block_root_cl, @exit ; load root cl block

		; fat block of test cluster read?
		cmp32_ne lba_addr, (FAT_LBA+(test_start_cluster>>7)), :+
			; ... simulate fat block read, just fill some values which are reached if the fat32 implementation is correct ;)
			set32 block_fat+((test_start_cluster+0)<<2 & (sd_blocksize-1)), (test_start_cluster+3) ; build a fragmented chain
			set32 block_fat+((test_start_cluster+3)<<2 & (sd_blocksize-1)), (test_start_cluster+7)
			set32 block_fat+((test_start_cluster+7)<<2 & (sd_blocksize-1)), FAT_EOC
      jmp @exit_inc
:
		; data block read?
		; - for tests with 2sec/cl
		load_block_if (LBA_BEGIN - ROOT_CL * 2 + (test_start_cluster+0) * 2 + 0), test_block_data_0_0, @exit  ; block 0, cluster 0
		load_block_if (LBA_BEGIN - ROOT_CL * 2 + (test_start_cluster+0) * 2 + 1), test_block_data_0_1, @exit  ; block 1, cluster 0
		load_block_if (LBA_BEGIN - ROOT_CL * 2 + (test_start_cluster+3) * 2 + 0), test_block_data_1_0, @exit  ; block 0, cluster 1
		load_block_if (LBA_BEGIN - ROOT_CL * 2 + (test_start_cluster+3) * 2 + 1), test_block_data_1_1, @exit  ; block 1, cluster 1
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
	fat32_dir_entry_file "FILE01  ", "DAT", 0, 0 ; 0 - no cluster reserved, 0 size
	fat32_dir_entry_file "FILE02  ", "TXT", 10, 12	; 10 - 1st cluster nr of file, 12 byte file size

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
