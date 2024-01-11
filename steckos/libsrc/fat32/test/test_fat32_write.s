.include "test_fat32.inc"

.autoimport

; mock defines
.export dev_read_block=         mock_read_block
.export read_block=             blklayer_read_block
.export dev_write_block=        mock_write_block
.export write_block=            blklayer_write_block
.export write_flush=            blklayer_flush

.export rtc_systime_update=mock_rtc

debug_enabled=1

; cluster search will find following clustes
TEST_FILE_CL10=$10
TEST_FILE_CL19=$19

.code
;    jmp single_test
; -------------------
    setup "fat_fopen O_RDWR EISDIR"
    ldy #O_RDWR
    lda #<test_dir_name_eexist
    ldx #>test_dir_name_eexist
    jsr fat_fopen
    assertC 1
    assertA EISDIR


; -------------------
    setup "fat_fopen O_CREAT"
    ldy #O_CREAT
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertDirEntry (block_root_dir_00+(4*DIR_Entry_Size)) ;expect 4th entry created
      fat32_dir_entry_file "TEST01  ", "TST", 0, 0    ; 0 - no cluster reserved yet, file length 0
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_CREAT, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY
    jsr fat_close


; -------------------
    setup "fat_fopen O_WRONLY"
    ldy #O_WRONLY
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertDirEntry (block_root_dir_00+(4*DIR_Entry_Size)) ;expect 4th entry created
      fat32_dir_entry_file "TEST01  ", "TST", 0, 0    ; 0 - no cluster reserved yet, file length 0
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_WRONLY, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY
    jsr fat_close


; -------------------
    setup "fat_fopen O_RDWR"
    ldy #O_RDWR
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertDirEntry (block_root_dir_00+(4*DIR_Entry_Size)) ;expect 4th entry created
      fat32_dir_entry_file "TEST01  ", "TST", 0, 0    ; 0 - no cluster reserved yet, file length 0
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY
    jsr fat_close


; -------------------
		setup "fat_open end of block (4s/cl)"
    ldy #O_RDWR
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertA EOK
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertDirEntry (block_root_dir_00+(4*DIR_Entry_Size)) ;expect 4th entry created
      fat32_dir_entry_file "TEST01  ", "TST", 0, 0    ; 0 - no cluster reserved yet, file length 0
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY
    jsr fat_close


; -------------------
		setup "fat_open end of last block in cl (4s/cl)" ; expect new dirent at the end of last block in cluster

    ; fill directory blocks
    .repeat 16, i
      setDirEntry block_root_dir_00+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK0_%02d", i), "   ", 0
      setDirEntry block_root_dir_01+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK1_%02d", i), "   ", 0
      setDirEntry block_root_dir_02+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK2_%02d", i), "   ", 0
    .endrepeat
    .repeat 15, i
      setDirEntry block_root_dir_03+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK3_%02d", i), "   ", 0
    .endrepeat

    ldy #O_RDWR
		lda #<test_file_name_1
		ldx #>test_file_name_1
		jsr fat_fopen
		assertC 0
		assertA EOK
    assertDirEntry block_root_dir_03+15*DIR_Entry_Size
      fat32_dir_entry_file "TEST01  ", "TST", 0, 0    ; 0 - no cluster reserved yet, file length 0
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, $1e0>>1, LBA_BEGIN+3, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY

    assert32 $100, block_fsinfo+F32FSInfo::FreeClus
    assert32 ROOT_CL, block_fsinfo+F32FSInfo::LastClus

; -------------------
		setup "fat_open in next cl (4s/cl)"  ; test whether dirent is created in the next cluster of the directory
    ; fill directory blocks until all blocks of the cluster are reserved
    .repeat 16, i
      setDirEntry block_root_dir_00+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK0_%02d", i), "   ", 0
      setDirEntry block_root_dir_01+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK1_%02d", i), "   ", 0
      setDirEntry block_root_dir_02+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK2_%02d", i), "   ", 0
      setDirEntry block_root_dir_03+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK3_%02d", i), "   ", 0
    .endrepeat

    set32 block_fat_0+(ROOT_CL<<2 & (sd_blocksize-1)), (TEST_FILE_CL10) ; the cl chain for root directory - root ($02) => $10
    set32 block_fat_0+(TEST_FILE_CL10<<2 & (sd_blocksize-1)), FAT_EOC

    ldy #O_RDWR
		lda #<test_file_name_1
		ldx #>test_file_name_1
		jsr fat_fopen
		assertC 0
		assertA EOK
    assertDirEntry block_data_cl10_00+0*DIR_Entry_Size  ; expect dirent at begin of 2nd directory block
      fat32_dir_entry_file "TEST01  ", "TST", 0, 0    ; 0 - no cluster reserved yet, file length 0
    assert8 0, block_data_cl10_00+1*DIR_Entry_Size ; expect next dirent end of dir
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, 0, LBA_BEGIN-ROOT_CL*SEC_PER_CL+TEST_FILE_CL10*SEC_PER_CL, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY

    assert32 $100, block_fsinfo+F32FSInfo::FreeClus
    assert32 ROOT_CL, block_fsinfo+F32FSInfo::LastClus


; -------------------
		setup "fat_fopen in next cl build cl chain (4s/cl)"  ; test whether dirent is created in the next cluster of the directory and whether cluster chain is maintained correctly
    ; fill directory blocks until all blocks of the cluster are reserved
    .repeat 16, i
      setDirEntry block_root_dir_00+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK0_%02d", i), "   ", 0
      setDirEntry block_root_dir_01+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK1_%02d", i), "   ", 0
      setDirEntry block_root_dir_02+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK2_%02d", i), "   ", 0
      setDirEntry block_root_dir_03+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK3_%02d", i), "   ", 0
    .endrepeat

    ldy #O_RDWR
		lda #<test_file_name_1
		ldx #>test_file_name_1
		jsr fat_fopen
		assertC 0
		assertA EOK
    assertDirEntry block_data_cl10_00+0*DIR_Entry_Size  ; expect dirent at begin of 2nd directory block
      fat32_dir_entry_file "TEST01  ", "TST", 0, 0    ; 0 - no cluster reserved yet, file length 0
    assert8 0, block_data_cl10_00+1*DIR_Entry_Size ; expect next dirent end of dir
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, 0, LBA_BEGIN-ROOT_CL*SEC_PER_CL+TEST_FILE_CL10*SEC_PER_CL, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY

    assert32 TEST_FILE_CL10,  block_fat_0+(ROOT_CL<<2 & (sd_blocksize-1)); assert cl chain for root directory - root ($02) => $10
    assert32 FAT_EOC,       block_fat_0+(TEST_FILE_CL10<<2 & (sd_blocksize-1))

    assert32 $ff, block_fsinfo+F32FSInfo::FreeClus
    assert32 TEST_FILE_CL10, block_fsinfo+F32FSInfo::LastClus


; -------------------
    setup "fat_write_byte 1 byte 4s/cl";
    ldy #O_RDWR
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertA EOK
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertDirEntry block_root_dir_00+4*DIR_Entry_Size
        fat32_dir_entry_file "TEST01  ", "TST", 0, 0  ; no cluster reserved yet
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY

    ldy #$31
    lda #'F'
    jsr fat_write_byte
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertC 0
    assertY $31 ; preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, O_RDWR, FD_STATUS_FILE_OPEN

    jsr fat_close

    assertDirEntry block_root_dir_00+4*DIR_Entry_Size
        fat32_dir_entry_file "TEST01  ", "TST", TEST_FILE_CL10, 1

    ldy #O_RDONLY
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, O_RDONLY, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY, 0

    jsr fat_fread_byte
    assertC 0
    assertA 'F'
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, O_RDONLY, FD_STATUS_FILE_OPEN

    jsr fat_close

; -------------------
    setup "fat_write_byte 2 byte 4s/cl";
    ldy #O_RDWR
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertA EOK
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved

    assertDirEntry block_root_dir_00+$80
        fat32_dir_entry_file "TEST01  ", "TST", 0, 0  ; no cluster reserved yet
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY

    ldy #$31
    lda #'F'
    jsr fat_write_byte
    assertC 0
    assertY $31
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, O_RDWR, FD_STATUS_FILE_OPEN ; TEST_FILE_CL10 reserved

    lda #'T'
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2, O_RDWR, FD_STATUS_FILE_OPEN

    jsr fat_close

    assertDirEntry block_root_dir_00+$80
      fat32_dir_entry_file "TEST01  ", "TST", TEST_FILE_CL10, 2  ; TEST_FILE_CL10 cluster, filesize 2

    ldy #O_RDONLY
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2, O_RDONLY, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY, 0

    jsr fat_fread_byte
    assertC 0
    assertA 'F'
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2, O_RDONLY, FD_STATUS_FILE_OPEN, 1

    jsr fat_fread_byte
    assertC 0
    assertA 'T'
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2, O_RDONLY, FD_STATUS_FILE_OPEN, 2

    jsr fat_fread_byte
    assertC 1
    assertA EOK

    jsr fat_close


; -------------------
    setup "fat_write_byte 513 byte 4s/cl";

    ldy #O_RDWR
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertA EOK
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved

    assertDirEntry block_root_dir_00+$80
        fat32_dir_entry_file "TEST01  ", "TST", 0, 0  ; no cluster reserved yet
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY

    ldy #$31
    lda #'F'
    jsr fat_write_byte
    assertC 0
    assertY $31
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, O_RDWR, FD_STATUS_FILE_OPEN ; TEST_FILE_CL10 reserved

    lda #'T'
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2, O_RDWR, FD_STATUS_FILE_OPEN

    lda #'W'
    ldy #$71
    jsr fat_write_byte
    assertY $71
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 3, O_RDWR, FD_STATUS_FILE_OPEN

    ldy #252
:   tya
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    dey
    bne :-
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 255, O_RDWR, FD_STATUS_FILE_OPEN

    lda #'0'
    ldy #$71
    jsr fat_write_byte
    assertY $71
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 256, O_RDWR, FD_STATUS_FILE_OPEN

    ldy #0
:   tya
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    dey
    bne :-

    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 512, O_RDWR, FD_STATUS_FILE_OPEN

    lda #'X'
    jsr fat_write_byte
    assertC 0
    lda #'Y'
    jsr fat_write_byte
    assertC 0
    lda #'Z'
    jsr fat_write_byte
    assertC 0

    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 515, O_RDWR, FD_STATUS_FILE_OPEN

    jsr fat_close

    assertDirEntry block_root_dir_00+$80
      fat32_dir_entry_file "TEST01  ", "TST", TEST_FILE_CL10, 515

    ldy #O_RDONLY
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_seek TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 515, O_RDONLY, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY, 0

    jsr fat_fread_byte
    assertC 0
    assertA 'F'
    jsr fat_fread_byte
    assertC 0
    assertA 'T'
    jsr fat_fread_byte
    assertC 0
    assertA 'W'
    jsr fat_close


; -------------------
    setup "fat_write_byte 2049 byte 4s/cl";
    ldy #O_RDWR
    lda #<test_file_name_2
    ldx #>test_file_name_2
    jsr fat_fopen
    assertA EOK
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY, 0
    assertDirEntry block_root_dir_00+$80
      fat32_dir_entry_file "TEST02  ", "TST", 0, 0 ; no cluster reserved yet

    ldy #0  ; write 2048 byte
:   tya
    jsr fat_write_byte
    jsr fat_write_byte

    jsr fat_write_byte
    jsr fat_write_byte

    jsr fat_write_byte
    jsr fat_write_byte

    jsr fat_write_byte
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    dey
    bne :-

    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2048, O_RDWR, FD_STATUS_FILE_OPEN ; TEST_FILE_CL10 reserved

    lda #'X'
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_all TEST_FILE_CL19, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2049, O_RDWR, FD_STATUS_FILE_OPEN, 2049, TEST_FILE_CL10 ; TEST_FILE_CL19 selected, TEST_FILE_CL10 start cluster

    jsr fat_close

    ; dir entry is written on close
    assertDirEntry block_root_dir_00+$80
      fat32_dir_entry_file "TEST02  ", "TST", TEST_FILE_CL10, 2049  ; TEST_FILE_CL10 cluster reserved, filesize 2k+1

    ldy #O_RDONLY
    lda #<test_file_name_2
    ldx #>test_file_name_2
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_seek TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2049, O_RDONLY, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY, 0

    jsr fat_fread_byte
    assertC 0
    assertA 0
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_seek TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2049, O_RDONLY, FD_STATUS_FILE_OPEN, 1

    jsr fat_close


; -------------------
single_test:
    setup "fat_write seek 2048+512 4s/cl";

    ldy #O_RDWR
    lda #<test_file_name_2
    ldx #>test_file_name_2
    jsr fat_fopen
    assertA EOK
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY, 0
    assertDirEntry block_root_dir_00+$80
      fat32_dir_entry_file "TEST02  ", "TST", 0, 0 ; no cluster reserved yet

    set32 test_seek+Seek::Offset, (2048+512) ; set to begin of block 1 in next cluster
    lda #<test_seek
    ldy #>test_seek
		jsr fat_fseek
		assertC 0
		assertX FD_Entry_Size*2 ; assert FD prreserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_all 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY, (2048+512), 0

    lda #'X'
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_all TEST_FILE_CL19, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, (2048+512+1), O_RDWR, FD_STATUS_FILE_OPEN, (2048+512+1), TEST_FILE_CL10

    jsr fat_close

    assertDirEntry block_root_dir_00+$80
      fat32_dir_entry_file "TEST02  ", "TST", TEST_FILE_CL10, (2048+512+1)

    ldy #O_RDONLY
    lda #<test_file_name_2
    ldx #>test_file_name_2
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_all TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, (2048+512+1), O_RDONLY, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY, 0, TEST_FILE_CL10

    set32 test_seek+Seek::Offset, (2048+512) ; set to begin of block 1 in next cluster
    lda #<test_seek
    ldy #>test_seek
		jsr fat_fseek
		assertC 0
		assertX FD_Entry_Size*2 ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_all TEST_FILE_CL10, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, (2048+512+1), O_RDONLY, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY, (2048+512), TEST_FILE_CL10

    jsr fat_fread_byte
    assertC 0
    assertA 'X'
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_all TEST_FILE_CL19, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, (2048+512+1), O_RDONLY, FD_STATUS_FILE_OPEN, (2048+512+1), TEST_FILE_CL10

    jsr fat_fread_byte
    assertC 1
    assertA EOK ; eoc

    jsr fat_close

test_end


data_loader  ; define data loader
data_writer ; define data writer

mock_rtc:
    m_memcpy  _rtc_ts, rtc_systime_t, 8
    rts


test_seek:
  .byte SEEK_SET
  .dword 0

mock_read_block:
    tax ; mock X destruction
    debug32 "mock_read_block lba", lba_addr
		load_block_if (LBA_BEGIN+0), block_root_dir_00, @ok ; load root cl block
    load_block_if (LBA_BEGIN+1), block_root_dir_01, @ok ;
    load_block_if (LBA_BEGIN+2), block_root_dir_02, @ok ;
    load_block_if (LBA_BEGIN+3), block_root_dir_03, @ok ;

    load_block_if FS_INFO_LBA, block_fsinfo, @ok
    load_block_if (FAT_LBA+(TEST_FILE_CL10>>7)), block_fat_0, @ok
    load_block_if (FAT2_LBA+(TEST_FILE_CL10>>7)), block_fat2_0, @ok

		load_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + TEST_FILE_CL10 * SEC_PER_CL + 0), block_data_cl10_00 , @ok
		load_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + TEST_FILE_CL10 * SEC_PER_CL + 1), block_data_cl10_01 , @ok
		load_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + TEST_FILE_CL10 * SEC_PER_CL + 2), block_data_cl10_02 , @ok
		load_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + TEST_FILE_CL10 * SEC_PER_CL + 3), block_data_cl10_03 , @ok

    load_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + TEST_FILE_CL19 * SEC_PER_CL + 0), block_data_cl19_00, @ok
    load_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + TEST_FILE_CL19 * SEC_PER_CL + 1), block_data_cl19_01, @ok

    fail "read lba not handled!"

@exit_inc:
    inc sd_blkptr+1 ; => same behaviour as real block read implementation
@ok:
    lda #EOK
    rts

mock_write_block:
    tax ; mock destruction of X
    debug32 "mock_write_block lba", lba_addr
    debug16 "mock_write_block wptr", sd_blkptr
    store_block_if (LBA_BEGIN+0), block_root_dir_00, @ok
    store_block_if (LBA_BEGIN+1), block_root_dir_01, @ok
    store_block_if (LBA_BEGIN+3), block_root_dir_03, @ok

    store_block_if FS_INFO_LBA, block_fsinfo, @ok ;

    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL10)+0), block_data_cl10_00, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL10)+1), block_data_cl10_01, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL10)+2), block_data_cl10_02, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL10)+3), block_data_cl10_03, @ok

    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL19)+0), block_data_cl19_00, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL19)+1), block_data_cl19_01, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL19)+2), block_data_cl19_02, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL19)+3), block_data_cl19_03, @ok

    store_block_if (FAT_LBA+(TEST_FILE_CL10>>7)), block_fat_0, @ok
    store_block_if (FAT2_LBA+(TEST_FILE_CL10>>7)), block_fat2_0, @ok

    fail "write lba not handled!"
@ok:
    lda #EOK
    rts

mock_not_implemented1:
    fail "mock cluster_nr_matcher called!"
mock_not_implemented2:
    fail "mock fat_name_string called!"
mock_not_implemented3:
    fail "mock path_inverse called!"
mock_not_implemented4:
    fail "mock put_char called!"

setUp:
  jsr blklayer_init
  jsr __fat_init_fdarea
  init_volume_id SEC_PER_CL

  ;setup fd0 (cwd) to root cluster
  ldx #FD_INDEX_CURRENT_DIR
  jsr __fat_open_rootdir

  ; fill fat block
  m_memset block_fat_0+$000, $ff, $80  ; simulate reserved
  m_memset block_fat_0+$080, $ff, $80
  m_memset block_fat_0+$100, $ff, $80
  m_memset block_fat_0+$180, $ff, $80
  set32 block_fat_0+(TEST_FILE_CL10<<2), 0 ; mark TEST_FILE_CL10 as free
  set32 block_fat_0+(TEST_FILE_CL19<<2), 0 ; mark TEST_FILE_CL19 as free

  init_block block_root_dir_00_init, block_root_dir_00
  init_block block_fsinfo_init, block_fsinfo
  rts


.data
  test_file_name_1:     .asciiz "test01.tst"
  test_file_name_2:     .asciiz "test02.tst"
  test_file_name_3:     .asciiz "test03.tst"
  test_dir_name_eexist: .asciiz "dir01"
  test_dir_name_mkdir:  .asciiz "dir03"

block_root_dir_00_init:
  fat32_dir_entry_dir   "DIR01   ", "   ", 8
  fat32_dir_entry_dir   "DIR02   ", "   ", 9
  fat32_dir_entry_file "FILE01  ", "DAT", 0, 0    ; 0 - no cluster reserved, file length 0
  fat32_dir_entry_file "FILE02  ", "TXT", $a, 12  ; $a - 1st cluster nr of file, file length 12 byte
  .res .sizeof(F32DirEntry)*12, 0

block_fsinfo_init:
  .byte "RRaA"
  .res 480, 0
  .byte "rrAa"
  .dword $100 ; edge case, 32bit add/sub
  .dword $02
  .res 12,0
  .byte 0,0,$55,$aa

_rtc_ts:
    .byte 34  ; tm_sec  .byte    ;0-59
    .byte 22  ; tm_min  .byte    ;0-59
    .byte 11  ; tm_hour  .byte   ;0-23
    .byte 10  ; m_mday  .byte    ;1-31
    .byte 03  ; tm_mon  .byte    ;0-11 0-jan, 11-dec
    .byte 120; tm_year  .word  70  ;years since 1900
    .byte 06 ; tm_wday  .byte    ;
    rts

.bss
block_fsinfo:   .res sd_blocksize

block_fat_0:    .res sd_blocksize
block_fat2_0:   .res sd_blocksize

block_root_dir_00:  .res sd_blocksize
block_root_dir_01:  .res sd_blocksize
block_root_dir_02:  .res sd_blocksize
block_root_dir_03:  .res sd_blocksize

block_data_cl10_00:  .res sd_blocksize
block_data_cl10_01:  .res sd_blocksize
block_data_cl10_02:  .res sd_blocksize
block_data_cl10_03:  .res sd_blocksize

block_data_cl19_00:  .res sd_blocksize
block_data_cl19_01:  .res sd_blocksize
block_data_cl19_02:  .res sd_blocksize
block_data_cl19_03:  .res sd_blocksize
