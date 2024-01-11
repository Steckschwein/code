.include "test_fat32.inc"

.autoimport

.export dev_read_block=         mock_read_block
.export read_block=             blklayer_read_block
.export dev_write_block=        mock_not_implemented
.export write_block=            mock_not_implemented
.export write_flush=            blklayer_flush

.export __rtc_systime_update=mock_not_implemented

debug_enabled=1

.code

; -------------------
		setup "fat_fseek empty file"
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, 0 ; empty file
    set32 test_seek+Seek::Offset, 2

		ldx #(2*FD_Entry_Size) ; 0 byte file
    lda #<test_seek
    ldy #>test_seek
		jsr fat_fseek
		assertCarry 0; no error
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged
		assert32 2, fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos
		assert32 0, fd_area+(2*FD_Entry_Size)+F32_fd::FileSize
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::StartCluster
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster

; -------------------
		setup "fat_fseek filesize"
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, (512*3+5)
    set32 test_seek+Seek::Offset, (512*3+5)

		ldx #(2*FD_Entry_Size)
    lda #<test_seek
    ldy #>test_seek
		jsr fat_fseek
		assertCarry 0
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged
		assert32 512*3+5, fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos
		assert32 512*3+5, fd_area+(2*FD_Entry_Size)+F32_fd::FileSize
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::StartCluster
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster

; -------------------
		setup "fat_fseek 0 empty file" ;
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, 0 ; empty file
    set32 test_seek+Seek::Offset, 0

		ldx #(2*FD_Entry_Size) ; 0 byte file
    lda #<test_seek
    ldy #>test_seek
		jsr fat_fseek
		assertCarry 0
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged
		assert32 0, fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos
		assert32 0, fd_area+(2*FD_Entry_Size)+F32_fd::FileSize
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::StartCluster
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster

; -------------------
		setup "fat_fseek to filesize-1 2s/cl"
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, (512*3+5)
    set32 test_seek+Seek::Offset, (512*3+4)

		ldx #(2*FD_Entry_Size)
    lda #<test_seek
    ldy #>test_seek
		jsr fat_fseek
		assertCarry 0
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged
		assert32 (512*3+5), fd_area+(2*FD_Entry_Size)+F32_fd::FileSize
		assert32 (512*3+4), fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::StartCluster
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster

		jsr fat_fread_byte
		assertCarry 0 ; last byte
    assertA '1'

		jsr fat_fread_byte
		assertCarry 1
    assertA EOK ; eof expected


; -------------------
		setup "fat_fseek to end of 2nd cl 2s/cl"
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, (512*4+5)
    set32 test_seek+Seek::Offset, (512*3+511)

		ldx #(2*FD_Entry_Size)
    lda #<test_seek
    ldy #>test_seek
		jsr fat_fseek
		assertCarry 0
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged
		assert32 (512*3+511), fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos
		assert32 (512*4+5), fd_area+(2*FD_Entry_Size)+F32_fd::FileSize
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::StartCluster
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster

		jsr fat_fread_byte
		assertCarry 0
		assert32 test_start_cluster+3, fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster

		jsr fat_fread_byte
		assertCarry 0
    assertA 'B'
		assert32 test_start_cluster+7, fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster

		jsr fat_fread_byte
		assertCarry 0
    assertA '0'
		jsr fat_fread_byte
		assertCarry 0
    assertA '/'
		jsr fat_fread_byte
		assertCarry 0
    assertA 'C'
		jsr fat_fread_byte
		assertCarry 0
    assertA '2'

		jsr fat_fread_byte
		assertCarry 1
    assertA EOK ; eof expected


; -------------------
		setup "fat_fseek to start next cl 2s/cl"
		set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, (512*2+5)
    set32 test_seek+Seek::Offset, (512*2)

		ldx #(2*FD_Entry_Size)
    lda #<test_seek
    ldy #>test_seek
		jsr fat_fseek
		assertCarry 0
		assertX (2*FD_Entry_Size); expect X unchanged, and read address still unchanged
		assert32 (512*2), fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos
		assert32 (512*2+5), fd_area+(2*FD_Entry_Size)+F32_fd::FileSize
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::StartCluster
		assert32 test_start_cluster, fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster

		jsr fat_fread_byte
		assertCarry 0
		assert32 test_start_cluster+3, fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster

    assertA 'B'
		jsr fat_fread_byte
		assertCarry 0
    assertA '0'
		jsr fat_fread_byte
		assertCarry 0
    assertA '/'
		jsr fat_fread_byte
		assertCarry 0
    assertA 'C'
		jsr fat_fread_byte
		assertCarry 0
    assertA '1'

		jsr fat_fread_byte
		assertCarry 1
    assertA EOK ; eof expected

test_end

setUp:
  jsr blklayer_init
	jsr __fat_init_fdarea
	init_volume_id 2

	;setup fd0 as root cluster
	set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
	set8 fd_area+(0*FD_Entry_Size)+F32_fd::Attr, DIR_Attr_Mask_Dir
	set32 fd_area+(0*FD_Entry_Size)+F32_fd::SeekPos, 0
	;setup fd2 with test cluster
	set32 fd_area+(2*FD_Entry_Size)+F32_fd::StartCluster, test_start_cluster
  set32 fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
	set8 fd_area+(2*FD_Entry_Size)+F32_fd::Attr, DIR_Attr_Mask_Archive
	set32 fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos, 0
	set32 fd_area+(2*FD_Entry_Size)+F32_fd::FileSize, $1000
  set8 fd_area+(2*FD_Entry_Size)+F32_fd::status, FD_STATUS_FILE_OPEN
  set8 fd_area+(2*FD_Entry_Size)+F32_fd::flags, O_RDONLY

	rts

data_loader	; define data loader

mock_not_implemented:
		fail "mock was called, not implemented yet!"

mock_read_block:
		debug32 "mock_read_block lba", lba_addr
		cpx #(2*FD_Entry_Size)
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
		load_block_if (LBA_BEGIN - ROOT_CL * 2 + (test_start_cluster+7) * 2 + 0), test_block_data_2_0, @exit
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
		inc sd_blkptr+1 ; => same behavior as real block read implementation
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

test_seek:
  .byte SEEK_SET
  .dword 0

test_block_data_0_0:
  .byte "B0/C0",0; block 0, cluster 0
	.res 256-6,0
  .byte "A"
	.res 256-1,0
test_block_data_0_1:
  .byte "B1/C0",1; block 1, cluster 0
	.res 256-6,0
  .byte "B"
	.res 256-1,0
test_block_data_1_0:
  .byte "B0/C1",2; block 0, cluster 1
	.res 256-6,0
  .byte "C"
	.res 256-1,0
test_block_data_1_1:
  .byte "B1/C1","%"; block 1, cluster 1
	.res 256-6,0
  .byte "D"
	.res 256-1,0
test_block_data_2_0:
  .byte "B0/C2","&"; block 0, cluster 2
	.res 256-6,0
  .byte "E"
	.res 256-1,0

test_block_data_4sec_cl:
	.byte "4s/cl"
	.res 250,0

.bss
data_read: .res 8*sd_blocksize
