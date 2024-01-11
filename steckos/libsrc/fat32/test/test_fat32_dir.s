.include "test_fat32.inc"

.autoimport

; mock defines
.export dev_read_block=         mock_read_block
.export read_block=             blklayer_read_block
.export dev_write_block=        mock_write_block
.export write_block=            blklayer_write_block

.export rtc_systime_update=mock_rtc

debug_enabled=1

; cluster search will find following clustes
TEST_FILE_CL=$10
TEST_FILE_CL2=$19

.code

; -------------------
		setup "fat_chdir_enotdir"
		lda #<test_file_name_1
		ldx #>test_file_name_1
		jsr fat_chdir
		assertCarry 1
		assertA ENOTDIR

; -------------------
		setup "fat_chdir_enoent"
		lda #<test_dir_name_enoent
		ldx #>test_dir_name_enoent
		jsr fat_chdir
		assertCarry 1
		assertA ENOENT

; -------------------
		setup "fat_chdir ."
		lda #<test_dir_name_dot
		ldx #>test_dir_name_dot
		jsr fat_chdir
		assertCarry 0
		assertA EOK

; -------------------
		setup "fat_chdir .."
		lda #<test_dir_name_dotdot
		ldx #>test_dir_name_dotdot
		jsr fat_chdir
		assertCarry 0
		assertA EOK

; -------------------
		setup "fat_mkdir eexist"
		lda #<test_dir_name_eexist
		ldx #>test_dir_name_eexist
		jsr fat_mkdir
		assertCarry 1
		assertA EEXIST

; -------------------
		setup "fat_mkdir"
		lda #<test_dir_name_new
		ldx #>test_dir_name_new
		jsr fat_mkdir
		assertCarry 0
		assertA EOK
    assertDirEntry block_root_dir_00+14*DIR_Entry_Size
      fat32_dir_entry_dir "DIRTEST ", "EXT", TEST_FILE_CL
    assertDirEntry block_data_cl10_00+0*DIR_Entry_Size
      fat32_dir_entry_dir ".       ", "   ", TEST_FILE_CL
    assertDirEntry block_data_cl10_00+1*DIR_Entry_Size
      fat32_dir_entry_dir "..      ", "   ", 0
    assert8 0, block_data_cl10_00+2*DIR_Entry_Size

    assert32 $ff, block_fsinfo+F32FSInfo::FreeClus
    assert32 $10, block_fsinfo+F32FSInfo::LastClus

; -------------------
		setup "fat_mkdir numeric"
		lda #<test_dir_name_numeric
		ldx #>test_dir_name_numeric
		jsr fat_mkdir
		assertCarry 0
		assertA EOK
    assertDirEntry block_root_dir_00+14*DIR_Entry_Size
      fat32_dir_entry_dir "12345678", "9AB", TEST_FILE_CL
    assertDirEntry block_data_cl10_00+0*DIR_Entry_Size
      fat32_dir_entry_dir ".       ", "   ", TEST_FILE_CL
    assertDirEntry block_data_cl10_00+1*DIR_Entry_Size
      fat32_dir_entry_dir "..      ", "   ", 0
    assert8 0, block_data_cl10_00+2*DIR_Entry_Size

    assert32 $ff, block_fsinfo+F32FSInfo::FreeClus
    assert32 $10, block_fsinfo+F32FSInfo::LastClus


; -------------------
		setup "fat_mkdir end of block (4s/cl)"

    setDirEntry block_root_dir_00+14*DIR_Entry_Size
      fat32_dir_entry_dir "DIR0D   ", "   ", 0

		lda #<test_dir_name_new
		ldx #>test_dir_name_new
		jsr fat_mkdir
		assertCarry 0
		assertA EOK
    assertDirEntry block_root_dir_00+15*DIR_Entry_Size  ; expect new dirent at end of 1st block
      fat32_dir_entry_dir "DIRTEST ", "EXT", TEST_FILE_CL
    assert8 0, block_root_dir_01+0*DIR_Entry_Size  ; expect eod at begin of 2nd block

    assertDirEntry block_data_cl10_00+0*DIR_Entry_Size
      fat32_dir_entry_dir ".       ", "   ", TEST_FILE_CL
    assertDirEntry block_data_cl10_00+1*DIR_Entry_Size
      fat32_dir_entry_dir "..      ", "   ", 0
    assert8 0, block_data_cl10_00+2*DIR_Entry_Size

    assert32 $ff, block_fsinfo+F32FSInfo::FreeClus
    assert32 $10, block_fsinfo+F32FSInfo::LastClus


; -------------------
		setup "fat_mkdir end of last block in cl (4s/cl)" ; expect new dirent at the end of last block in cluster

    ; fill directory blocks
    .repeat 2, i
      setDirEntry block_root_dir_00+(14+i)*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK0_%02d", i), "   ", 0
    .endrepeat
    .repeat 16, i
      setDirEntry block_root_dir_01+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK1_%02d", i), "   ", 0
      setDirEntry block_root_dir_02+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK2_%02d", i), "   ", 0
    .endrepeat
    .repeat 15, i
      setDirEntry block_root_dir_03+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK3_%02d", i), "   ", 0
    .endrepeat

		lda #<test_dir_name_new
		ldx #>test_dir_name_new
		jsr fat_mkdir
		assertCarry 0
		assertA EOK
    assertDirEntry block_root_dir_03+15*DIR_Entry_Size
      fat32_dir_entry_dir "DIRTEST ", "EXT", TEST_FILE_CL
    ; end of cluster, read to next dir entry end up in eoc

    assertDirEntry block_data_cl10_00+0*DIR_Entry_Size
      fat32_dir_entry_dir ".       ", "   ", TEST_FILE_CL
    assertDirEntry block_data_cl10_00+1*DIR_Entry_Size
      fat32_dir_entry_dir "..      ", "   ", 0

    assert32 $ff, block_fsinfo+F32FSInfo::FreeClus
    assert32 $10, block_fsinfo+F32FSInfo::LastClus


; -------------------
		setup "fat_mkdir in next cl (4s/cl)"  ; test whether dirent is created in the next cluster of the directory
    ; fill directory blocks until all blocks of the cluster are reserved
    .repeat 2, i
      setDirEntry block_root_dir_00+(14+i)*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK0_%02d", i), "   ", 0
    .endrepeat
    .repeat 16, i
      setDirEntry block_root_dir_01+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK1_%02d", i), "   ", 0
      setDirEntry block_root_dir_02+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK2_%02d", i), "   ", 0
      setDirEntry block_root_dir_03+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK3_%02d", i), "   ", 0
    .endrepeat

    set32 block_fat_0+(ROOT_CL<<2 & (sd_blocksize-1)), (TEST_FILE_CL) ; the cl chain for root directory - root ($02) => $10
    set32 block_fat_0+(TEST_FILE_CL<<2 & (sd_blocksize-1)), FAT_EOC

		lda #<test_dir_name_new
		ldx #>test_dir_name_new
		jsr fat_mkdir
		assertCarry 0
		assertA EOK
    assertDirEntry block_data_cl10_00+0*DIR_Entry_Size  ; expect dirent at begin of 2nd directory block
      fat32_dir_entry_dir "DIRTEST ", "EXT", TEST_FILE_CL2
    assert8 0, block_data_cl10_00+1*DIR_Entry_Size ; expect next dirent end of dir

    assertDirEntry block_data_cl19_00+0*DIR_Entry_Size
      fat32_dir_entry_dir ".       ", "   ", TEST_FILE_CL2
    assertDirEntry block_data_cl19_00+1*DIR_Entry_Size
      fat32_dir_entry_dir "..      ", "   ", 0 ; root cluster

    assert32 $ff, block_fsinfo+F32FSInfo::FreeClus
    assert32 TEST_FILE_CL2, block_fsinfo+F32FSInfo::LastClus


; -------------------
		setup "fat_mkdir in next cl build cl chain (4s/cl)"  ; test whether dirent is created in the next cluster of the directory and whether cluster chain is maintained correctly
    ; fill directory blocks until all blocks of the cluster are reserved
    .repeat 2, i
      setDirEntry block_root_dir_00+(14+i)*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK0_%02d", i), "   ", 0
    .endrepeat
    .repeat 16, i
      setDirEntry block_root_dir_01+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK1_%02d", i), "   ", 0
      setDirEntry block_root_dir_02+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK2_%02d", i), "   ", 0
      setDirEntry block_root_dir_03+i*DIR_Entry_Size
        fat32_dir_entry_dir .sprintf("BLCK3_%02d", i), "   ", 0
    .endrepeat

		lda #<test_dir_name_new
		ldx #>test_dir_name_new
		jsr fat_mkdir
		assertCarry 0
		assertA EOK
    assertDirEntry block_data_cl10_00+0*DIR_Entry_Size  ; expect dirent at begin of 2nd directory block
      fat32_dir_entry_dir "DIRTEST ", "EXT", TEST_FILE_CL2
    assert8 0, block_data_cl10_00+1*DIR_Entry_Size ; expect next dirent end of dir

    assertDirEntry block_data_cl19_00+0*DIR_Entry_Size
      fat32_dir_entry_dir ".       ", "   ", TEST_FILE_CL2
    assertDirEntry block_data_cl19_00+1*DIR_Entry_Size
      fat32_dir_entry_dir "..      ", "   ", 0 ; root cluster

    assert32 TEST_FILE_CL,  block_fat_0+(ROOT_CL<<2 & (sd_blocksize-1)); assert cl chain for root directory - root ($02) => $10
    assert32 FAT_EOC,       block_fat_0+(TEST_FILE_CL<<2 & (sd_blocksize-1))

    assert32 TEST_FILE_CL,  block_fat2_0+(ROOT_CL<<2 & (sd_blocksize-1)); assert cl chain for root directory - root ($02) => $10
    assert32 FAT_EOC,       block_fat2_0+(TEST_FILE_CL<<2 & (sd_blocksize-1))

    assert32 $fe, block_fsinfo+F32FSInfo::FreeClus
    assert32 TEST_FILE_CL2, block_fsinfo+F32FSInfo::LastClus

test_end

data_loader  ; define data loader
data_writer ; define data writer

mock_rtc:
    m_memcpy  _rtc_ts, rtc_systime_t, 8
    rts

mock_read_block:
    tax ; mock destruction of X
    debug32 "mock_read_block lba", lba_addr
    debug16 "mock_read_block blkptr", sd_blkptr

		load_block_if (LBA_BEGIN+0), block_root_dir_00, @ok ; load root cl block
    load_block_if (LBA_BEGIN+1), block_root_dir_01, @ok ;
    load_block_if (LBA_BEGIN+2), block_root_dir_02, @ok ;
    load_block_if (LBA_BEGIN+3), block_root_dir_03, @ok ;

		load_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + TEST_FILE_CL * SEC_PER_CL + 0), block_data_cl10_00 , @ok

    load_block_if FS_INFO_LBA, block_fsinfo, @ok
    load_block_if (FAT_LBA+(TEST_FILE_CL>>7)), block_fat_0, @ok
    load_block_if (FAT_LBA+(TEST_FILE_CL2>>7)), block_fat_0, @ok

    fail "read lba not handled!"
@ok:
    lda #EOK
		rts

mock_write_block:
    tax ; mock destruction of X
    debug32 "mock_write_block lba", lba_addr
    debug16 "mock_write_block blkptr", sd_blkptr
    store_block_if (LBA_BEGIN+0), block_root_dir_00, @ok
    store_block_if (LBA_BEGIN+1), block_root_dir_01, @ok

    store_block_if (LBA_BEGIN+3), block_root_dir_03, @ok

    store_block_if FS_INFO_LBA, block_fsinfo, @ok ;
    store_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + SEC_PER_CL * TEST_FILE_CL+0), block_data_cl10_00, @ok
    store_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + SEC_PER_CL * TEST_FILE_CL+1), block_data_cl10_01, @ok
    store_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + SEC_PER_CL * TEST_FILE_CL+2), block_data_cl10_02, @ok
    store_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + SEC_PER_CL * TEST_FILE_CL+3), block_data_cl10_03, @ok

    store_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + SEC_PER_CL * TEST_FILE_CL2+0), block_data_cl19_00, @ok
    store_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + SEC_PER_CL * TEST_FILE_CL2+1), block_data_cl19_01, @ok
    store_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + SEC_PER_CL * TEST_FILE_CL2+2), block_data_cl19_02, @ok
    store_block_if (LBA_BEGIN - ROOT_CL * SEC_PER_CL + SEC_PER_CL * TEST_FILE_CL2+3), block_data_cl19_03, @ok

    store_block_if (FAT_LBA+(TEST_FILE_CL>>7)), block_fat_0, @ok
    store_block_if (FAT2_LBA+(TEST_FILE_CL>>7)), block_fat2_0, @ok

    fail "write lba not handled!"
@ok:
    lda #EOK
    rts


mock_not_implemented:
		fail "mock!"

setUp:
    jsr blklayer_init

    init_volume_id SEC_PER_CL
		jsr __fat_init_fdarea
		;setup fd0 (cwd) to root cluster
    ldx #FD_INDEX_CURRENT_DIR
    jsr __fat_open_rootdir

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

    init_block block_empty, block_data_cl10_00
    init_block block_empty, block_data_cl10_01
    init_block block_empty, block_data_cl10_02
    init_block block_empty, block_data_cl10_03

    init_block block_empty, block_data_cl19_00
    init_block block_empty, block_data_cl19_01
    init_block block_empty, block_data_cl19_02
    init_block block_empty, block_data_cl19_03

    init_block block_fsinfo_init, block_fsinfo

		rts

.data
	test_file_name_1:       .asciiz "file01.dat"
	test_dir_name_1:        .asciiz "dir01"
	test_dir_name_eexist:   .asciiz "dir02"
	test_dir_name_enoent:   .asciiz "enoent"
  test_dir_name_new:      .asciiz "dirtest.ext"
  test_dir_name_numeric:  .asciiz "12345678.9ab"
  test_dir_name_dot:      .asciiz "."
  test_dir_name_dotdot:   .asciiz ".."

block_root_dir_init_00:
	fat32_dir_entry_dir 	".       ", "   ", 0
	fat32_dir_entry_dir 	"..      ", "   ", 0
	fat32_dir_entry_dir 	"DIR02   ", "   ", 0
	fat32_dir_entry_dir 	"DIR03   ", "   ", 0
	fat32_dir_entry_dir 	"DIR04   ", "   ", 0
	fat32_dir_entry_dir 	"DIR05   ", "   ", 0
	fat32_dir_entry_dir 	"DIR06   ", "   ", 0
	fat32_dir_entry_dir 	"DIR07   ", "   ", 0
	fat32_dir_entry_dir 	"DIR08   ", "   ", 0
	fat32_dir_entry_dir 	"DIR09   ", "   ", 0
	fat32_dir_entry_dir 	"DIR0A   ", "   ", 0
	fat32_dir_entry_dir 	"DIR0B   ", "   ", 0
	fat32_dir_entry_dir 	"DIR0C   ", "   ", 0
	fat32_dir_entry_file "FILE01  ", "DAT", 0, 0		; 0 - no cluster reserved, file length 0
  .res DIR_Entry_Size,0
  .res DIR_Entry_Size,0

block_empty:
  .res 512,0

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
