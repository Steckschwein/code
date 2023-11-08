.include "test_fat32.inc"

.import __fat_init_fdarea
.import fat_fopen
.import fat_close
.import fat_write
.import fat_write_byte
.import fat_mkdir
.import fat_fread_byte

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
    assertZ 1
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
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, 0, O_CREAT
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
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, 0, O_WRONLY
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
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, 0, O_RDWR
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
    setup "fat_write_byte 1 cluster";
    ldy #O_RDWR
    lda #<test_file_name_2cl
    ldx #>test_file_name_2cl
    jsr fat_fopen
    assertA EOK
    assertX FD_Entry_Size*2  ; assert FD reserved

    assertDirEntry block_data+$80
        fat32_dir_entry_file "TST_02CL", "TST", 0, 0  ; no cluster reserved yet
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, 0, O_RDWR

    jsr fat_fread_byte
    assertA 0
    assertC 1 ; eof expected

    lda #'F'
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, 0, O_RDWR ; TEST_FILE_CL reserved
    assertDirEntry block_data+$80
        fat32_dir_entry_file "TST_02CL", "TST", TEST_FILE_CL, 1  ; TEST_FILE_CL cluster reserved, filesize 1

    lda #'T'
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 2, 0, O_RDWR
    assertDirEntry block_data+$80
        fat32_dir_entry_file "TST_02CL", "TST", TEST_FILE_CL, 2  ; TEST_FILE_CL cluster, filesize 2

    lda #'W'
    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 3, 0, O_RDWR
    assertDirEntry block_data+$80
        fat32_dir_entry_file "TST_02CL", "TST", TEST_FILE_CL, 3  ; TEST_FILE_CL cluster, filesize 3

    ldy #2
:    jsr fat_write_byte
    assertC 0
    assertX FD_Entry_Size*2  ; assert FD preserved
    assertY 2
    dey
    bne :-
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 256, 0, O_RDWR
    assertDirEntry block_data+$80
        fat32_dir_entry_file "TST_02CL", "TST", TEST_FILE_CL, 256  ; TEST_FILE_CL cluster, filesize 3

    jsr fat_close

    ldy #O_RDONLY
    lda #<test_file_name_2cl
    ldx #>test_file_name_2cl
    jsr fat_fopen
    assertA EOK
    assertX FD_Entry_Size*2  ; assert FD reserved
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
    brk


data_loader  ; define data loader
data_writer ; define data writer

mock_rtc:
    m_memcpy  _rtc_ts, rtc_systime_t, 8
    rts
_rtc_ts:
    .byte 34  ; tm_sec  .byte    ;0-59
    .byte 22  ; tm_min  .byte    ;0-59
    .byte 11  ; tm_hour  .byte    ;0-23
    .byte 10  ; m_mday  .byte    ;1-31
    .byte 03  ; tm_mon  .byte  1  ;0-11 0-jan, 11-dec
    .byte 120; tm_year  .word  70  ;years since 1900
    .byte 06 ; tm_wday  .byte    ;
    rts

mock_read_block:
    tax ; mock X destruction
    debug32 "mock_read_block", lba_addr
    load_block_if LBA_BEGIN, block_root_cl, @ok ; load root cl block
    load_block_if FS_INFO_LBA, block_fsinfo, @ok

    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+0), block_data_00, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+1), block_data_01, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+2), block_data_02, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+3), block_data_03, @ok
;    cmp32_eq lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+0), @dummy_read
    cmp32_ne lba_addr, FAT_LBA, :+
      ;simulate fat block read
      m_memset block_fat+$000, $ff, $40  ; simulate reserved, next free cluster is TEST_FILE_CL ($10)
      m_memset block_fat+$100, $ff, $40  ;
      m_memset block_fat+$40, $0, 4 ;
      bra @dummy_read
:
    assert32 FAT_EOC, lba_addr ; fail

@dummy_read:
    inc read_blkptr+1 ; => same behaviour as real block read implementation
@ok:
    lda #EOK
    rts

; cluster search will always find $10 cluster
TEST_FILE_CL=$10

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
;    cmp32_eq lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+0), @dummy_write
;    cmp32_eq lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+1), @dummy_write
;    cmp32_eq lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+2), @dummy_write
;    cmp32_eq lba_addr, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+3), @dummy_write
;    cmp32_eq lba_addr, FAT_LBA, @dummy_write
;    cmp32_eq lba_addr, FAT2_LBA, @dummy_write
    store_block_if FAT_LBA, block_fat_0, @ok
    store_block_if FAT2_LBA, block_fat2_0, @ok

    assert32 FAT_EOC, lba_addr ; fail if we end up here
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

  set8 volumeID+VolumeID::BPB_SecPerClus, SEC_PER_CL
  set32 volumeID + VolumeID::EBPB_RootClus, ROOT_CL
  set32 volumeID + VolumeID::EBPB_FATSz32, (FAT2_LBA - FAT_LBA)
  set32 volumeID+VolumeID::lba_data, (LBA_BEGIN - (ROOT_CL * SEC_PER_CL))
  set32 volumeID+VolumeID::lba_fat, FAT_LBA
  set32 volumeID+VolumeID::lba_fat2, FAT2_LBA
  set32 volumeID+VolumeID::lba_fsinfo, FS_INFO_LBA

  ;setup fd0 as root cluster
  set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
  set16 fd_area+(0*FD_Entry_Size)+F32_fd::offset, 0
  set8 fd_area+(0*FD_Entry_Size)+F32_fd::flags, 0

  ;setup fd1 as test cluster
  set32 fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
  set32 fd_area+(1*FD_Entry_Size)+F32_fd::seek_pos, 0
  set16 fd_area+(1*FD_Entry_Size)+F32_fd::offset, 0
  set8 fd_area+(1*FD_Entry_Size)+F32_fd::flags, 0

  init_block block_root_cl_init, block_root_cl
  init_block block_fsinfo_init, block_fsinfo
  rts

.data
  test_file_name_1:     .asciiz "test01.tst"
  test_file_name_1cl:    .asciiz "tst_01cl.tst"
  test_file_name_2cl:    .asciiz "tst_02cl.tst"
  test_dir_name_eexist:  .asciiz "dir01"
  test_dir_name_mkdir:   .asciiz "dir03"

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
block_fat_0:  .res sd_blocksize
block_fat2_0:  .res sd_blocksize
block_root_cl:  .res sd_blocksize
block_fsinfo:  .res sd_blocksize
block_data_00:  .res sd_blocksize
block_data_01:  .res sd_blocksize
block_data_02:  .res sd_blocksize
block_data_03:  .res sd_blocksize
block_data_04:  .res sd_blocksize
block_data_06:  .res sd_blocksize
block_data_07:  .res sd_blocksize
block_data_08:  .res sd_blocksize
block_data_09:  .res sd_blocksize
block_data_0a:  .res sd_blocksize
