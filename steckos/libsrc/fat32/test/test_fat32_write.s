.include "test_fat32.inc"

.autoimport

; mock defines
.export read_block=mock_read_block
.export write_block=mock_write_block
.export rtc_systime_update=mock_rtc
.export cluster_nr_matcher=mock_not_implemented1
.export fat_name_string=mock_not_implemented2
.export path_inverse=mock_not_implemented3
.export put_char=mock_not_implemented4

debug_enabled=1

.code

; -------------------
    setup "fat_mkdir_eexist"
    lda #<test_dir_name_eexist
    ldx #>test_dir_name_eexist
    jsr fat_mkdir
    assertC 1
    assertA EEXIST

; -------------------
    setup "fat_mkdir_new"

    assert32 $100, block_fsinfo+F32FSInfo::FreeClus
    lda #<test_dir_name_mkdir
    ldx #>test_dir_name_mkdir
    jsr fat_mkdir
    assertCarry 0
    assertA EOK
    assertDirEntry (block_root_cl+(4*DIR_Entry_Size)) ;expect 4th entry created
      fat32_dir_entry_dir "DIR03   ", "   ", TEST_FILE_CL
    assert32 $ff, block_fsinfo+F32FSInfo::FreeClus
    assert32 TEST_FILE_CL, block_fsinfo+F32FSInfo::LastClus

; -------------------
    setup "fat_fopen O_CREAT"
    ldy #O_CREAT
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertA EOK
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertDirEntry (block_root_cl+(4*DIR_Entry_Size)) ;expect 4th entry created
      fat32_dir_entry_file "TEST01  ", "TST", 0, 0    ; 0 - no cluster reserved yet, file length 0
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_CREAT, FD_FILE_OPEN
    jsr fat_close

; -------------------
    setup "fat_fopen O_WRONLY"
    ldy #O_WRONLY
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertA EOK
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertDirEntry (block_root_cl+(4*DIR_Entry_Size)) ;expect 4th entry created
      fat32_dir_entry_file "TEST01  ", "TST", 0, 0    ; 0 - no cluster reserved yet, file length 0
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_WRONLY, FD_FILE_OPEN
    jsr fat_close

; -------------------
    setup "fat_fopen O_RDWR"
    ldy #O_RDWR
    lda #<test_file_name_1
    ldx #>test_file_name_1
    jsr fat_fopen
    assertA EOK
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertDirEntry (block_root_cl+(4*DIR_Entry_Size)) ;expect 4th entry created
      fat32_dir_entry_file "TEST01  ", "TST", 0, 0    ; 0 - no cluster reserved yet, file length 0
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_FILE_OPEN
    jsr fat_close

; -------------------
    setup "fat_fopen O_RDWR EISDIR"
    ldy #O_RDWR
    lda #<test_dir_name_eexist
    ldx #>test_dir_name_eexist
    jsr fat_fopen
    assertC 1
    assertA EISDIR

; -------------------
    setup "fat_write_byte 1 byte 4s/cl";
    ldy #O_RDWR
    lda #<test_file_name_1cl
    ldx #>test_file_name_1cl
    jsr fat_fopen
    assertA EOK
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertDirEntry block_data+$80
        fat32_dir_entry_file "TST_01CL", "TST", 0, 0  ; no cluster reserved yet
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_FILE_OPEN

    ldy #$31
    lda #'F'
    jsr fat_write_byte
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertC 0
    assertY $31 ; preserved
    assertDirEntry block_data+$80
        fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 1
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, O_RDWR, FD_FILE_OPEN

    jsr fat_close

    ldy #O_RDONLY
    lda #<test_file_name_1cl
    ldx #>test_file_name_1cl
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, O_RDONLY, FD_FILE_OPEN, 0

    jsr fat_fread_byte
    assertC 0
    assertA 'F'
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, O_RDONLY, FD_FILE_OPEN

    jsr fat_close

; -------------------
    setup "fat_write_byte 2 byte 4s/cl";
    ldy #O_RDWR
    lda #<test_file_name_1cl
    ldx #>test_file_name_1cl
    jsr fat_fopen
    assertA EOK
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD reserved

    assertDirEntry block_data+$80
        fat32_dir_entry_file "TST_01CL", "TST", 0, 0  ; no cluster reserved yet
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_FILE_OPEN

    ldy #$31
    lda #'F'
    jsr fat_write_byte
    assertC 0
    assertY $31
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertDirEntry block_data+$80
      fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 1  ; TEST_FILE_CL cluster reserved, filesize 1
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, O_RDWR, FD_FILE_OPEN ; TEST_FILE_CL reserved

    lda #'T'
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2
    assertDirEntry block_data+$80
      fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 2  ; TEST_FILE_CL cluster, filesize 2
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2, O_RDWR, FD_FILE_OPEN

    jsr fat_close

    ldy #O_RDONLY
    lda #<test_file_name_1cl
    ldx #>test_file_name_1cl
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2, O_RDONLY, FD_FILE_OPEN, 0

    jsr fat_fread_byte
    assertC 0
    assertA 'F'
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2, O_RDONLY, FD_FILE_OPEN, 1

    jsr fat_fread_byte
    assertC 0
    assertA 'T'
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2, O_RDONLY, FD_FILE_OPEN, 2

    jsr fat_fread_byte
    assertC 1
    assertA EOK

    jsr fat_close

; -------------------
    setup "fat_write_byte 513 byte 4s/cl";
    ldy #O_RDWR
    lda #<test_file_name_1cl
    ldx #>test_file_name_1cl
    jsr fat_fopen
    assertA EOK
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD reserved

    assertDirEntry block_data+$80
        fat32_dir_entry_file "TST_01CL", "TST", 0, 0  ; no cluster reserved yet
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_FILE_OPEN

    ldy #$31
    lda #'F'
    jsr fat_write_byte
    assertC 0
    assertY $31
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertDirEntry block_data+$80
      fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 1  ; TEST_FILE_CL cluster reserved, filesize 1
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, O_RDWR, FD_FILE_OPEN ; TEST_FILE_CL reserved

    lda #'T'
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2
    assertDirEntry block_data+$80
      fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 2  ; TEST_FILE_CL cluster, filesize 2
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2, O_RDWR, FD_FILE_OPEN

    lda #'W'
    ldy #$71
    jsr fat_write_byte
    assertY $71
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertDirEntry block_data+$80
      fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 3  ; TEST_FILE_CL cluster, filesize 3
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 3, O_RDWR, FD_FILE_OPEN

    ldy #252
:   tya
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    dey
    bne :-
    assertDirEntry block_data+$80
      fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 255  ; TEST_FILE_CL cluster, filesize 255
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 255, O_RDWR, FD_FILE_OPEN

    lda #'0'
    ldy #$71
    jsr fat_write_byte
    assertY $71
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertDirEntry block_data+$80
      fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 256  ; TEST_FILE_CL cluster, filesize 256
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 256, O_RDWR, FD_FILE_OPEN

    ldy #0
:   tya
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    dey
    bne :-

    assertDirEntry block_root_cl+$80
      fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 512
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 512, O_RDWR, FD_FILE_OPEN

    lda #'X'
    jsr fat_write_byte
    assertC 0
    lda #'Y'
    jsr fat_write_byte
    assertC 0
    lda #'Z'
    jsr fat_write_byte
    assertC 0

    assertDirEntry block_root_cl+$80
      fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 515
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 515, O_RDWR, FD_FILE_OPEN

    jsr fat_close

    ldy #O_RDONLY
    lda #<test_file_name_1cl
    ldx #>test_file_name_1cl
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_seek TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 515, O_RDONLY, FD_FILE_OPEN, 0

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
    lda #<test_file_name_2cl
    ldx #>test_file_name_2cl
    jsr fat_fopen
    assertA EOK
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_FILE_OPEN, 0
    assertDirEntry block_root_cl+$80
      fat32_dir_entry_file "TST_02CL", "TST", 0, 0 ; no cluster reserved yet

    ldy #0
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

    assertDirEntry block_root_cl+$80
      fat32_dir_entry_file "TST_02CL", "TST", TEST_FILE_CL, 2048  ; TEST_FILE_CL cluster reserved, filesize 2k
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2048, O_RDWR, FD_FILE_OPEN ; TEST_FILE_CL reserved

    lda #'X'
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertDirEntry block_root_cl+$80
      fat32_dir_entry_file "TST_02CL", "TST", TEST_FILE_CL, 2049  ; TEST_FILE_CL cluster reserved, filesize 2k+1
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL+1, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2049, O_RDWR, FD_FILE_OPEN ; TEST_FILE_CL+1 selected

    jsr fat_close

    ldy #O_RDONLY
    lda #<test_file_name_2cl
    ldx #>test_file_name_2cl
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_seek TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2049, O_RDONLY, FD_FILE_OPEN, 0

    jsr fat_fread_byte
    assertC 0
    assertA 0
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_seek TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2049, O_RDONLY, FD_FILE_OPEN, 1

    jsr fat_close

; -------------------
    setup "fat_write_byte seek 2049 4s/cl";

    ldy #O_RDWR
    lda #<test_file_name_2cl
    ldx #>test_file_name_2cl
    jsr fat_fopen
    assertA EOK
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_FILE_OPEN, 0
    assertDirEntry block_root_cl+$80
      fat32_dir_entry_file "TST_02CL", "TST", 0, 0 ; no cluster reserved yet

    set32 test_seek+Seek::Offset, (2048+512) ; set to beginn of block 1 in next cluster
    lda #<test_seek
    ldy #>test_seek
		jsr fat_fseek
		assertCarry 0
		assertX (FD_Entry_Size*2); expect X unchanged, and read address still unchanged
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, (2048+512), O_RDWR, FD_FILE_OPEN, (2048+512)
    assertDirEntry block_root_cl+$80
      fat32_dir_entry_file "TST_02CL", "TST", TEST_FILE_CL, 0

    lda #'X'
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file_seek 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_RDWR, FD_FILE_OPEN,
    assertDirEntry block_root_cl+$80
      fat32_dir_entry_file "TST_02CL", "TST", 0, 0 ; no cluster reserved yet


    jsr fat_close

    ldy #O_RDONLY
    lda #<test_file_name_2cl
    ldx #>test_file_name_2cl
    jsr fat_fopen
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_seek TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2049, O_RDONLY, FD_FILE_OPEN, 0

    set32 test_seek+Seek::Offset, (2048+512) ; set to beginn of block 1 in next cluster
    lda #<test_seek
    ldy #>test_seek
		jsr fat_fseek
		assertCarry 0
		assertX (FD_Entry_Size*2); expect X unchanged, and read address still unchanged

    jsr fat_fread_byte
    assertC 0
    assertA 0
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file_seek TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2049, O_RDONLY, FD_FILE_OPEN, 1

    jsr fat_close

    brk


data_loader  ; define data loader
data_writer ; define data writer

; cluster search will find following clustes
TEST_FILE_CL=$10
TEST_FILE_CL2=$19

mock_rtc:
    m_memcpy  _rtc_ts, rtc_systime_t, 8
    rts


test_seek:
  .byte SEEK_SET
  .dword 0

_rtc_ts:
    .byte 34  ; tm_sec  .byte    ;0-59
    .byte 22  ; tm_min  .byte    ;0-59
    .byte 11  ; tm_hour  .byte   ;0-23
    .byte 10  ; m_mday  .byte    ;1-31
    .byte 03  ; tm_mon  .byte    ;0-11 0-jan, 11-dec
    .byte 120; tm_year  .word  70  ;years since 1900
    .byte 06 ; tm_wday  .byte    ;
    rts

mock_read_block:
    tax ; mock X destruction
    debug32 "mock_read_block lba", lba_addr
    load_block_if LBA_BEGIN, block_root_cl, @ok ; load root cl block
    load_block_if FS_INFO_LBA, block_fsinfo, @ok

    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+0), block_data_00, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+1), block_data_01, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+2), block_data_02, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+3), block_data_03, @ok
    ; 2nd cluster
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL2)+0), block_data_10, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL2)+1), block_data_11, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL2)+2), block_data_12, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL2)+3), block_data_13, @ok

    load_block_if (FAT_LBA+(TEST_FILE_CL>>7)), block_fat_0, @ok
    load_block_if (FAT2_LBA+(TEST_FILE_CL>>7)), block_fat2_0, @ok
:
    fail "read lba not handled!"

@exit_inc:
    inc read_blkptr+1 ; => same behaviour as real block read implementation
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
    ; 2nd cluster
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL2)+0), block_data_10, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL2)+1), block_data_11, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL2)+2), block_data_12, @ok
    store_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL2)+3), block_data_13, @ok
;    cmp32_eq lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+0), @dummy_write
;    cmp32_eq lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+1), @dummy_write
;    cmp32_eq lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+2), @dummy_write
;    cmp32_eq lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+3), @dummy_write
;    cmp32_eq lba_addr, FAT_LBA, @dummy_write
;    cmp32_eq lba_addr, FAT2_LBA, @dummy_write
    store_block_if (FAT_LBA+(TEST_FILE_CL>>7)), block_fat_0, @ok
    store_block_if (FAT2_LBA+(TEST_FILE_CL>>7)), block_fat2_0, @ok

    fail "write lba not handled!"
@dummy_write:
    debug "dummy write"
    inc write_blkptr+1 ; => same behaviour as real block read implementation
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
  jsr __fat_init_fdarea

  ; fill fat block_fat
  m_memset block_fat_0+$000, $ff, $80  ; simulate reserved
  m_memset block_fat_0+$080, $ff, $80
  m_memset block_fat_0+$100, $ff, $80
  m_memset block_fat_0+$180, $ff, $80
  set32 block_fat_0+(TEST_FILE_CL<<2), 0 ; mark TEST_FILE_CL as free
  set32 block_fat_0+((TEST_FILE_CL2)<<2), 0 ; mark TEST_FILE_CL2 as free

  set_sec_per_cl SEC_PER_CL
  set32 volumeID + VolumeID::EBPB_RootClus, ROOT_CL
  set32 volumeID + VolumeID::EBPB_FATSz32, (FAT2_LBA - FAT_LBA)
  set32 volumeID+VolumeID::lba_fat, FAT_LBA
  set32 volumeID+VolumeID::lba_fat2, FAT2_LBA
  set32 volumeID+VolumeID::lba_fsinfo, FS_INFO_LBA

  ;setup fd0 as root cluster
  set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
  set32 fd_area+(0*FD_Entry_Size)+F32_fd::seek_pos, 0
  set8 fd_area+(0*FD_Entry_Size)+F32_fd::flags, 0

  ;setup fd1 as test cluster
  set32 fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
  set32 fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos, 0
  set8 fd_area+(1*FD_Entry_Size)+F32_fd::flags, 0

  init_block block_root_cl_init, block_root_cl
  init_block block_fsinfo_init, block_fsinfo
  rts


.data
  test_file_name_1:     .asciiz "test01.tst"
  test_file_name_1cl:   .asciiz "tst_01cl.tst"
  test_file_name_2cl:   .asciiz "tst_02cl.tst"
  test_dir_name_eexist: .asciiz "dir01"
  test_dir_name_mkdir:  .asciiz "dir03"

block_root_cl_init:
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

.bss
block_fat_0:    .res sd_blocksize
block_fat2_0:   .res sd_blocksize
block_root_cl:  .res sd_blocksize
block_fsinfo:   .res sd_blocksize
block_data_00:  .res sd_blocksize
block_data_01:  .res sd_blocksize
block_data_02:  .res sd_blocksize
block_data_03:  .res sd_blocksize
block_data_10:  .res sd_blocksize
block_data_11:  .res sd_blocksize
block_data_12:  .res sd_blocksize
block_data_13:  .res sd_blocksize
block_data_20:  .res sd_blocksize
block_data_21:  .res sd_blocksize
