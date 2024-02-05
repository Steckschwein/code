.include "test_fat32.inc"

.autoimport

.export dev_read_block=         mock_read_block
.export read_block=             blklayer_read_block
.export dev_write_block=        mock_not_implemented
.export write_block=            mock_not_implemented
.export write_block_buffered=   mock_not_implemented
.export write_flush=            blklayer_flush

.export __rtc_systime_update=   mock_not_implemented

debug_enabled=1

; cluster search will find following clustes
TEST_FILE_CL=$10
TEST_FILE_CL2=$19

.code
; -------------------
    setup "fat_fread_vollgas empty file 2s/cl"

    lda #<test_file_name
    ldx #>test_file_name
    ldy #O_RDONLY
    jsr fat_fopen
    assertC 0; ok

    jsr fat_fread_byte
    assertC 1
    assertA EOK ; eof reached

test_end

sec_per_cl=2

setUp:
    jsr blklayer_init
    init_volume_id sec_per_cl
    jsr __fat_init_fdarea
    ;setup fd0 (cwd) to root cluster
    jsr __fat_open_rootdir_cwd

    ; fill fat block
    m_memset block_fat_0+$000, $ff, $80  ; simulate reserved
    m_memset block_fat_0+$080, $ff, $80
    m_memset block_fat_0+$100, $ff, $80
    m_memset block_fat_0+$180, $ff, $80
    set32 block_fat_0+(TEST_FILE_CL<<2), 0 ; mark TEST_FILE_CL as free
    set32 block_fat_0+(TEST_FILE_CL2<<2), 0 ; mark TEST_FILE_CL2 as free

    init_block block_root_dir_init_00, block_root_dir_00
    init_block block_empty          , block_root_dir_01
    init_block block_empty          , block_root_dir_02
    init_block block_empty          , block_root_dir_03

    rts

data_loader  ; define data loader
data_writer

mock_not_implemented:
    fail "mock was called, not implemented yet!"

mock_read_block:
    debug32 "mock_read_block lba", lba_addr
    ; defaults to dir entry data
    load_block_if (LBA_BEGIN+0), block_root_dir_00, @ok ; load root cl block
    load_block_if (LBA_BEGIN+1), block_root_dir_01, @ok ;


    load_block_if (LBA_BEGIN - ROOT_CL * sec_per_cl + 5 * sec_per_cl + 0), test_block_data_0_0 , @ok

    ; fat block of test cluster read?
    cmp32_ne lba_addr, (FAT_LBA+(test_start_cluster>>7)), :+
      ; ... simulate fat block read - fill fat values on the fly
      set32 block_fat+((test_start_cluster+0)<<2 & (sd_blocksize-1)), (test_start_cluster+3) ; build a fragmented chain
      set32 block_fat+((test_start_cluster+3)<<2 & (sd_blocksize-1)), (test_start_cluster+7)
      set32 block_fat+((test_start_cluster+7)<<2 & (sd_blocksize-1)), FAT_EOC
      jmp @ok
:
    load_block_if (LBA_BEGIN - ROOT_CL * sec_per_cl + (test_start_cluster+0) * sec_per_cl + 0), test_block_data_0_0, @ok  ; block 0, cluster 0
    load_block_if (LBA_BEGIN - ROOT_CL * sec_per_cl + (test_start_cluster+0) * sec_per_cl + 1), test_block_data_0_1, @ok  ; block 1, cluster 0
    load_block_if (LBA_BEGIN - ROOT_CL * sec_per_cl + (test_start_cluster+3) * sec_per_cl + 0), test_block_data_1_0, @ok  ; block 0, cluster 1
    load_block_if (LBA_BEGIN - ROOT_CL * sec_per_cl + (test_start_cluster+3) * sec_per_cl + 1), test_block_data_1_1, @ok  ; block 1, cluster 1
;    load_block_if (LBA_BEGIN - ROOT_CL * sec_per_cl + (test_start_cluster+6) * sec_per_cl + 0), test_block_data_1_0, @ok
;    load_block_if (LBA_BEGIN - ROOT_CL * sec_per_cl + (test_start_cluster+6) * sec_per_cl + 1), test_block_data_1_1, @ok
    ; - for tests with 4sec/cl
    load_block_if (LBA_BEGIN - ROOT_CL * sec_per_cl + test_start_cluster * sec_per_cl + 0), test_block_data_4sec_cl, @ok

    fail "read lba not handled!"
@ok:
    clc
    rts

.data
  test_file_name: .asciiz "file01.dat"

block_root_dir_init_00:
  fat32_dir_entry_dir  "DIR01   ", "   ", 8
  fat32_dir_entry_dir  "DIR02   ", "   ", 9
  fat32_dir_entry_file "FILE01  ", "DAT", 0, 2 ; 0 - no cluster reserved, 0 size
  fat32_dir_entry_file "FILE02  ", "TXT", 5, 12  ; 5 - 1st cluster nr of file, 12 byte file size
  fat32_dir_entry_dir  ".       ", "   ", 0
  fat32_dir_entry_dir  "..      ", "   ", 0
  .res 10*DIR_Entry_Size, 0

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

block_empty:
  .res 512,0

.bss
block_fsinfo:   .res sd_blocksize

block_fat_0:    .res sd_blocksize
block_fat2_0:   .res sd_blocksize

block_root_dir_00:  .res sd_blocksize
block_root_dir_01:  .res sd_blocksize
block_root_dir_02:  .res sd_blocksize
block_root_dir_03:  .res sd_blocksize

data_read: .res 8*sd_blocksize
