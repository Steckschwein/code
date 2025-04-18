.include "asmunit.inc"   ; test api
.include "debug.inc"

.include "common.inc"
.include "errno.inc"
.include "rtc.inc"
.include "fcntl.inc"
.include "fat32.inc"
.include "zeropage.inc"

.include "stdio.inc"  ;ca65 asminc

.import asmunit_chrout

.export debug_chrout=asmunit_chrout

; fat32 geometry
.define FAT_LBA   $297e
.define FAT2_LBA   $2b7e
.define FS_INFO_LBA 1 ; sector 1
.define LBA_BEGIN $6800
.define SEC_PER_CL 4
.define ROOT_CL $02 ;

.define test_start_cluster $016a

.zeropage
  tmp1: .res 1
  test_data_ptr: .res 2

.code

debug_enabled=0

.macro setup testname
    test testname
    jsr setUp
.endmacro

.macro init_volume_id sec_per_cl
  set8 volumeID+VolumeID::BPB_SecPerClus, sec_per_cl
  set8 volumeID+VolumeID::BPB_SecPerClusMask , sec_per_cl-1
  .if sec_per_cl = 8
    set8 volumeID+VolumeID::BPB_SecPerClusCount, 3
  .else
    .assert sec_per_cl <= 4, error, "sec/cl not supported here!"
    set8 volumeID+VolumeID::BPB_SecPerClusCount, (sec_per_cl / 2) ; !!! works for 4, 2, 1 only
  .endif
	set32 volumeID+VolumeID::BPB_RootClus, ROOT_CL
  set32 volumeID+VolumeID::BPB_FATSz32, (FAT2_LBA - FAT_LBA)
  set32 volumeID+VolumeID::lba_data, (LBA_BEGIN - ROOT_CL * sec_per_cl)
	set32 volumeID+VolumeID::lba_fat, FAT_LBA		;fat lba
  set32 volumeID+VolumeID::lba_fat2, FAT2_LBA
  set32 volumeID+VolumeID::lba_fsinfo, FS_INFO_LBA
  set32 volumeID+VolumeID::cluster, 0
.endmacro

.macro fd_entry_file clnr, dir_entry, dir_lba, attr, filesize, flags, status
  ; seek_pos - for write tests, we expect seek pos equals filesize (after write)
  fd_entry_file_seek clnr, dir_entry, dir_lba, attr, filesize, flags, status, filesize
.endmacro

.macro fd_entry_file_seek clnr, dir_entry, dir_lba, attr, filesize, flags, status, seekpos
  fd_entry_file_all clnr, dir_entry, dir_lba, attr, filesize, flags, status, seekpos, clnr
.endmacro

.macro fd_entry_file_all  clnr, dir_entry, dir_lba, attr, filesize, flags, status, seekpos, sclnr
  .dword sclnr      ; StartCluster
  .dword clnr       ; CurrentCluster
  .dword filesize ; FileSize
  .byte attr ; Attr
  .dword dir_lba ; DirEntryLBA ; LBA of the block where the dir entry of the file is located
  .byte dir_entry ; DirEntryPos .byte;  block offset within the block (DirEntryPos * DIR_Entry_Size)
  .dword seekpos
  .byte flags
  .byte status
.endmacro

.macro assertReadBytes _string
      .local @input, @expect
      ldy #0
:     jsr fat_fread_byte
      assertC 0
      sta @input,y
      iny
      cpy #.strlen(_string)
      bne :-
      bra :+
@input:
      .res .strlen(_string)
:     assertMemory @input, .strlen(_string)
@expect:
      .byte _string
.endmacro

.macro assertFdEntry address
    assertMemory address, FD_Entry_Size
.endmacro

.macro fat_datetime year, month, day, hour, min, sec
  .word hour<<11 | min<<5 | sec>>1
  fat_date year, month, day
.endmacro

.macro fat_date year, month, day
  .word (year-1980)<<9 | month<<5 | day
.endmacro

.macro setDirEntry address
  setMemory address, DIR_Entry_Size
.endmacro

.macro fat32_dir_entry_dir _8_3_name, _8_3_ext, cl
  fat32_dir_entry _8_3_name, _8_3_ext, DIR_Attr_Mask_Dir, cl, 0
.endmacro

.macro fat32_dir_entry_file _8_3_name, _8_3_ext, cl, fsize
  fat32_dir_entry _8_3_name, _8_3_ext, DIR_Attr_Mask_Archive, cl, fsize
.endmacro

; fat32 dir entry - $20 byte
.macro fat32_dir_entry _8_3_name, _8_3_ext, attr, cl, fsize
  .assert .strlen(_8_3_name) = 8, error, "file name length != 8 !"
  .assert .strlen(_8_3_ext) = 3, error, "ext length != 3 !"
  .byte _8_3_name      ; 8 byte
  .byte _8_3_ext      ; 3 byte
  .byte attr        ; attr
  .byte 0          ; reserved
  .byte 0          ; create time millis
  fat_datetime 2020, 4, 10, 11, 22, 34     ; created date/time
  fat_date 2020, 4, 10  ; last modified
  .word cl>>16       ; cl high
  fat_datetime 2020, 4, 10, 11, 22, 34     ; modified date/time
  .word cl & $ffff     ; cl low
  .dword fsize
.endmacro

.macro assertDirEntry address
    assertMemory address, .sizeof(F32DirEntry)
.endmacro

.macro store_block_if lba, address, lbl_ok
    cmp32_ne lba_addr, lba, :+
    lda #<address
    ldy #>address
    jsr store_test_data
    jmp lbl_ok
:
.endmacro

.macro init_block src, dst
    lda #<src
    sta sd_blkptr
    lda #>src
    sta sd_blkptr+1
    lda #<dst
    ldy #>dst
    jsr store_test_data
.endmacro

.macro data_writer
  .local @cp
store_test_data:
    sta test_data_ptr+0
    sty test_data_ptr+1
    ldy #0
    jsr @cp
    inc sd_blkptr+1
    inc test_data_ptr+1
    jsr @cp
    dec sd_blkptr+1
    rts
@cp:
    lda (sd_blkptr),y
    sta (test_data_ptr),y
    iny
    bne @cp
    rts
.endmacro

.macro load_block_if lba, address, lbl_ok
    cmp32_ne lba_addr, lba, :+
    lda #<address
    ldy #>address
    jsr load_test_data
    jmp lbl_ok
:
.endmacro

.macro data_loader
  .local @cp
load_test_data:
    sta test_data_ptr+0
    sty test_data_ptr+1
    ldy #0
    jsr @cp
    inc sd_blkptr+1
    inc test_data_ptr+1
    jsr @cp
    dec sd_blkptr+1
    rts
@cp:
    lda (test_data_ptr),y
    sta (sd_blkptr),y
    iny
    bne @cp
    rts
.endmacro
