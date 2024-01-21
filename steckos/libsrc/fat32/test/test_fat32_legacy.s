.include "test_fat32.inc"

.autoimport

; mock defines
.export dev_read_block=         mock_read_block
.export read_block=             blklayer_read_block
.export dev_write_block=        mock_write_block
.export write_block=            mock_not_implemented
.export write_block_buffered=   mock_not_implemented
.export write_flush=            blklayer_flush

.export rtc_systime_update=mock_rtc

debug_enabled=1

.code

; -------------------

    setup "fat_write O_CREAT 1 byte 4s/cl"
test_end
    ldy #O_CREAT
    lda #<test_file_name_1cl
    ldx #>test_file_name_1cl

    jsr fat_fopen
    assertCarry 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertDirEntry block_root_cl+4*DIR_Entry_Size ;expect 4th entry created
      fat32_dir_entry_file "TST_01CL", "TST", 0, 0  ; filesize 0 and no cluster reserved yet
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_CREAT, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY

    ; set file size and write ptr
    set32 fd_area + (FD_Entry_Size*2) + F32_fd::FileSize, 1; 1 block must be written
    SetVector write_target, sd_blkptr
    jsr fat_write
    assertCarry 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assert16 write_target+1*sd_blocksize, sd_blkptr ; expect write ptr updated accordingly
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 1, O_CREAT, FD_STATUS_FILE_OPEN

    jsr fat_close
    assertDirEntry block_root_cl+4*DIR_Entry_Size ; expect 4th entry updated
      fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 1

; -------------------
    setup "fat_write O_CREAT 1536+3 byte 4s/cl"
    ldy #O_CREAT
    lda #<test_file_name_1cl
    ldx #>test_file_name_1cl

    jsr fat_fopen
    assertCarry 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assertDirEntry block_root_cl+4*DIR_Entry_Size ;expect 4th entry created
      fat32_dir_entry_file "TST_01CL", "TST", 0, 0  ; filesize 0 and no cluster reserved yet
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_CREAT, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY

    ; set file size and write ptr
    set32 fd_area + (FD_Entry_Size*2) + F32_fd::FileSize, (3*sd_blocksize+3) ; 4 blocks must be written
    SetVector write_target, sd_blkptr
    jsr fat_write
    assertCarry 0
    assertX FD_Entry_Size*2  ; assert FD reserved
    assert16 write_target+4*sd_blocksize, sd_blkptr ; expect write ptr updated accordingly
    assertFdEntry fd_area + (FD_Entry_Size*2)
      fd_entry_file TEST_FILE_CL, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, (3*sd_blocksize+3), O_CREAT, FD_STATUS_FILE_OPEN

    jsr fat_close

    assertDirEntry block_root_cl+4*DIR_Entry_Size ; expect 4th entry updated
      fat32_dir_entry_file "TST_01CL", "TST", TEST_FILE_CL, 3*sd_blocksize+3


; -------------------
    setup "fat_write O_CREAT 2048+3 4s/cl" ; blocks to write > sec/cl => expect write error C=1
    ldy #O_CREAT
    lda #<test_file_name_2cl
    ldx #>test_file_name_2cl
    jsr fat_fopen
    assertCarry 0
    assertX FD_Entry_Size*2  ; assert FD reserved

    assertDirEntry block_root_cl+4*DIR_Entry_Size
        fat32_dir_entry_file "TST_02CL", "TST", 0, 0  ; no cluster reserved yet
    assertFdEntry fd_area + (FD_Entry_Size*2)
        fd_entry_file 0, $40, LBA_BEGIN, DIR_Attr_Mask_Archive, 0, O_CREAT, FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY
    ; size to 4 blocks + 3 byte ;) - we use 4 SEC_PER_CL - hence a new cluster must be reserved and the chain build
    set32 fd_area + (FD_Entry_Size*2) + F32_fd::FileSize, (4 * sd_blocksize + 3) ; size is greater then 1 cl
    SetVector write_target, sd_blkptr
    jsr fat_write
    assertCarry 1 ; write failed due to blocks to write > sec/cl => expect write error C=1
    assertX FD_Entry_Size*2  ; assert FD

    jsr fat_close

    assertDirEntry block_root_cl+4*DIR_Entry_Size
      fat32_dir_entry_file "TST_02CL", "TST", TEST_FILE_CL, (4 * sd_blocksize + 3); cluster reserved but no blocks are written, filesize is wrong here!!!

test_end

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


; cluster search will always find $10 cluster
TEST_FILE_CL=$10

mock_read_block:
    tax ; mock X destruction
    debug32 "mock_read_block lba", lba_addr
    load_block_if LBA_BEGIN, block_root_cl, @ok ; load root cl block
    load_block_if FS_INFO_LBA, block_fsinfo, @ok

    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+0), block_data_00, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+1), block_data_01, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+2), block_data_02, @ok
    load_block_if (LBA_BEGIN - (ROOT_CL * SEC_PER_CL) + (SEC_PER_CL * TEST_FILE_CL)+3), block_data_03, @ok

    cmp32_ne lba_addr, FAT_LBA, :+
      ;simulate fat block read
      m_memset block_fat+$000, $ff, $40  ; simulate reserved, next free cluster is TEST_FILE_CL ($10)
      m_memset block_fat+$100, $ff, $40  ;
      m_memset block_fat+$40, $0, 4 ;
      bra @ok
:
    fail "read lba not handled!"
@ok:
    lda #EOK
    clc
    rts

mock_write_block:
    tax ; mock destruction of X
    debug32 "mock_write_block lba", lba_addr
    debug16 "mock_write_block wptr", sd_blkptr
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

    fail "mock write invalid lba called!" ; fail if we end up here !!!
@dummy_write:
    debug "dummy write"
    inc sd_blkptr+1 ; => same behaviour as real block read implementation
@ok:
    lda #EOK
    rts


mock_not_implemented:
    fail "unexpected mock call!"

setUp:
  jsr blklayer_init
  jsr __fat_init_fdarea
  init_volume_id SEC_PER_CL ;4s/cl

  ;setup fd0 as root cluster
  set32 fd_area+(0*FD_Entry_Size)+F32_fd::CurrentCluster, 0
  set32 fd_area+(0*FD_Entry_Size)+F32_fd::SeekPos, 0
  set8 fd_area+(0*FD_Entry_Size)+F32_fd::flags, 0

  ;setup fd1 as test cluster
  set32 fd_area+(1*FD_Entry_Size)+F32_fd::CurrentCluster, test_start_cluster
  set32 fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos, 0
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

block_root_cl_init: ; mock existing files and dirs
  fat32_dir_entry_dir   "DIR01   ", "   ", 8
  fat32_dir_entry_dir   "DIR02   ", "   ", 9
  fat32_dir_entry_file  "FILE01  ", "DAT", 0, 0  ; 0 - no cluster reserved, a "touched" file with length 0
  fat32_dir_entry_file  "FILE02  ", "TXT", 0, 0
  .res .sizeof(F32DirEntry)*12, 0 ; free dir entries at 4th position

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
write_target: