	.include "test_fat32.inc"

	.import __calc_lba_addr
	.import __fat_is_cln_zero
	.import __fat_init_fdarea
	.import __fat_alloc_fd
	.import fat_fopen
	.import fat_fread_byte

.code
; -------------------
		setup "__fat_init_fdarea / isOpen"	; test init fd area
    	jsr __fat_init_fdarea
		ldx #(2*FD_Entry_Size)
:		lda fd_area,x
    	assertA $ff
		inx
		cpx #(FD_Entry_Size*FD_Entries_Max)
		bne :-

; -------------------
		setup "__fat_alloc_fd"
		jsr __fat_alloc_fd
		assertX (2*FD_Entry_Size); expect x point to first fd entry which is 2*FD_Entry_Size, cause the first 2 entries are reserved
		assert32 0, (2*FD_Entry_Size)+fd_area+F32_fd::CurrentCluster
		assert32 0, (2*FD_Entry_Size)+fd_area+F32_fd::FileSize
		assert8 0, (2*FD_Entry_Size)+fd_area+F32_fd::seek_pos

; -------------------
		setup "__fat_alloc_fd with error"
    	ldy #FD_Entries_Max-2 ; -2 => 2 entries for cd and temp dir
:
		jsr __fat_alloc_fd
		assertZ 1
		assertA EOK
		dey
		bne :-
		jsr __fat_alloc_fd
		assertZ 0
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

		setup "__calc_lba_addr with some clnr"
		ldx #(1*FD_Entry_Size)
		jsr __calc_lba_addr
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * SEC_PER_CL + test_start_cluster * SEC_PER_CL, lba_addr ; expect $67fe + (clnr * sec/cl) => $67fe + $16a * 1 = $6968

; -------------------
		setup "__calc_lba_addr 8s/cl +10 blocks"
		ldx #(1*FD_Entry_Size)
		set8 volumeID+VolumeID::BPB_SecPerClus, 8
		set32 volumeID+VolumeID::lba_data, (LBA_BEGIN - ROOT_CL * 8)
		lda #($02*10) ; 10 blocks offset
		sta fd_area+F32_fd::seek_pos+1,x

		jsr __calc_lba_addr
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * 8 + test_start_cluster * 8 + 10, lba_addr ; expect $68f0 + (clnr * sec/cl) => $67f0 + $16a *8 + 10 = $734a


; -------------------
		setup "fat_fopen O_RDONLY ENOENT"

		ldy #O_RDONLY
		lda #<test_file_name_enoent
		ldx #>test_file_name_enoent
		jsr fat_fopen
		assertC 1
		assertA ENOENT

; -------------------
		setup "fat_fopen O_RDONLY"

		ldy #O_RDONLY
		lda #<test_file_name_1
		ldx #>test_file_name_1
		jsr fat_fopen
		assertA EOK
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
		assertA EOK
		assertCarry 0
		assertX 2*FD_Entry_Size
		assertDirEntry block_data+3*DIR_Entry_Size ; offset see below
			fat32_dir_entry_file "FILE02  ", "TXT", $0a, 12

; -------------------
		setup "fat_fread_byte with error"
		ldx #(2*FD_Entry_Size) ; use fd(2) - i/o error
		jsr fat_fread_byte
		assertA EINVAL
		assertCarry 1; expect error
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged

; -------------------
		setup "fat_fread_byte empty file"
		;setup fd2 with test cluster, but 0 filesize
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
		set8 fd_area+(2*FD_Entry_Size)+F32_fd::Attr, DIR_Attr_Mask_Archive
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::seek_pos, 0
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, 0 ; empty file

		ldx #(2*FD_Entry_Size) ; 0 byte file
		jsr fat_fread_byte
		assertCarry 1; expect "error"
		assertA EOK ; EOF
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged
		assert32 0, fd_area+(2*FD_Entry_Size)+F32_fd::seek_pos

; -------------------
		setup "fat_fread_byte touched file"
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster, 0 ; touched file, no cluster reserved
		set8 fd_area+(2*FD_Entry_Size)+F32_fd::Attr, DIR_Attr_Mask_Archive
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::seek_pos, 0
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, 0

		ldx #(2*FD_Entry_Size)
		jsr fat_fread_byte
		assertCarry 1; expect "error"
		assertA EOK ; EOF
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged
		assert32 0, fd_area+(2*FD_Entry_Size)+F32_fd::seek_pos

; -------------------
		setup "fat_fread_byte 1 byte 4s/cl"
		ldx #(1*FD_Entry_Size)
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA '4' ; see test_block_data_4sec_cl
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * SEC_PER_CL + test_start_cluster * SEC_PER_CL, lba_addr ; expect $67fe + (clnr * sec/cl) => $67fe + $16a * 1 = $6968
		assert32 $16a, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster
		assert32 1, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos

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
		assert32 2, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos

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
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * SEC_PER_CL + test_start_cluster * SEC_PER_CL, lba_addr
		assert32 $16a, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster
		assert32 4, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos

; -------------------
		setup "fat_fread_byte 2 blocks 2s/cl"
		set_sec_per_cl 2

		ldx #(1*FD_Entry_Size)
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA 'F'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA 'T'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA 'W'
		jsr fat_fread_byte
		assertCarry 0; ok
		assertA '!'

		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * 2 + test_start_cluster * 2, lba_addr
		assert32 test_start_cluster, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster
		assert32 4, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos

		lda #252
		sta tmp1
:		jsr fat_fread_byte
		dec tmp1
		bne :-
		assertCarry 0; ok
:		jsr fat_fread_byte
		assertCarry 0; ok
		dec tmp1
		bne :-

		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * 2 + test_start_cluster * 2, lba_addr
		assert32 test_start_cluster, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster ; - no new cluster selected
		assert32 $0200, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos ; seek pos at end of begin of next block

		jsr fat_fread_byte
		assertCarry 0; ok
		assertX (1*FD_Entry_Size)
		assert32 LBA_BEGIN - ROOT_CL * 2 + test_start_cluster * 2 + 1, lba_addr ; lba +1
		assert32 test_start_cluster, fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster ; - no new cluster selected
		assert32 $0201, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos


; -------------------
		setup "fat_fread_byte 4 blocks 2s/cl"
		set_sec_per_cl 2
		set32 fd_area+(1*FD_Entry_Size)+F32_fd::FileSize, 513 ; setup filesize 513byte

		assert32 0, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos

		ldx #(1*FD_Entry_Size)
		jsr fat_fread_byte
		assertCarry 0
		assertA 'F'
		assert32 1, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos
		assertX (1*FD_Entry_Size)

		jsr fat_fread_byte
		assertCarry 0
		assertA 'T'
		assert32 2, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos
		assertX (1*FD_Entry_Size)

		jsr fat_fread_byte
		assertCarry 0
		assertA 'W'
		assertX (1*FD_Entry_Size)

		jsr fat_fread_byte
		assertCarry 0
		assertA '!'
		assertX (1*FD_Entry_Size)

		lda #252
		sta tmp1
:		jsr fat_fread_byte
		assertCarry 0
		dec tmp1
		bne :-

		jsr fat_fread_byte
		assertCarry 0
		assertA '2'
		assertX (1*FD_Entry_Size)
		assert32 $101, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos

		jsr fat_fread_byte
		assertCarry 0
		assertA 'n'
		assertX (1*FD_Entry_Size)
		assert32 $102, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos

		jsr fat_fread_byte
		assertCarry 0
		assertA 'd'
		assertX (1*FD_Entry_Size)
		assert32 $103, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos

:		jsr fat_fread_byte
		bcc :-	; read until EOF
		assertCarry 1
		assertA 0

		jsr fat_fread_byte
		assertCarry 1

		assert32 513, fd_area+(1*FD_Entry_Size)+F32_fd::FileSize
		assert32 513, fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos ; expect position at EOF (filesize)

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
		debug32 "mock_read_block", lba_addr
		cpx #(1*FD_Entry_Size)
		bcs :+
		lda #EINVAL
		rts
:
		; defaults to dir entry data
		load_block_if LBA_BEGIN, block_root_cl, @exit ; load root cl block

		; fat block $2980 read?
		cmp32_ne lba_addr, $2980, :+
			; yes... simulate fat block read, just fill some values which are reached if the fat32 implementation is correct ;)
			set32 block_fat+((test_start_cluster+0)<<2 & (sd_blocksize-1)), (test_start_cluster+1) ; build the chain
			set32 block_fat+((test_start_cluster+1)<<2 & (sd_blocksize-1)), (test_start_cluster+2)
			set32 block_fat+((test_start_cluster+2)<<2 & (sd_blocksize-1)), (test_start_cluster+3)
			set32 block_fat+((test_start_cluster+3)<<2 & (sd_blocksize-1)), FAT_EOC
:
		; data block read?
		; - for tests with 2sec/cl
		load_block_if (LBA_BEGIN - ROOT_CL * 2 + test_start_cluster * 2 + 0), test_block_data, @exit
		; - for tests with 4sec/cl
		load_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + test_start_cluster * SEC_PER_CL + 0), test_block_data_4sec_cl, @exit

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
	fat32_dir_entry_file "FILE02  ", "TXT", $a, 12	; $a - 1st cluster nr of file, 12 - byte file size

test_block_data:
	.byte "FTW!"
	.res 252,0
	.byte "2nd half block"

test_block_data_4sec_cl:
	.byte "4s/cl"
	.res 252,0

.bss
data_read: .res 8*sd_blocksize
