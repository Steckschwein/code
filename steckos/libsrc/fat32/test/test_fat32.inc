.include "asmunit.inc" 	; test api

.include "common.inc"
.include "errno.inc"
.include "rtc.inc"
.include "fcntl.inc"
.include "fat32.inc"
.include "zeropage.inc"

.import asmunit_chrout
.export chrout=asmunit_chrout

; fat32 geometry
.define LBA_BEGIN $00006800
.define FAT_LBA $297e
.define SEC_PER_CL 1
.define ROOT_CL $02

.zeropage
	test_data_ptr: .res 2

.code

.macro setup testname
		test testname
		jsr setUp
.endmacro

.macro fd_entry_file dir_entry, dir_lba, attr
	.dword 0; CurrentCluster
	.dword 0; FileSize
	.byte attr; Attr
	.dword dir_lba; DirEntryLBA ; LBA of the block where the dir entry of the file is located
	.byte dir_entry; DirEntryPos .byte;  block offset within the block (DirEntryPos * DIR_Entry_Size)
	.byte 0; offset          .byte;  7Bit block number of the CurrentCluster
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

.macro fat32_dir_entry_dir _8_3_name, _8_3_ext, cl
	fat32_dir_entry _8_3_name, _8_3_ext, DIR_Attr_Mask_Dir, cl, 0
.endmacro

.macro fat32_dir_entry_file _8_3_name, _8_3_ext, cl, fsize
	fat32_dir_entry _8_3_name, _8_3_ext, DIR_Attr_Mask_Archive, cl, fsize
.endmacro

; fat32 dir entry - $20 byte
.macro fat32_dir_entry _8_3_name, _8_3_ext, attr, cl, fsize
	.assert .strlen(_8_3_name) = 8, error, "file name size"
	.assert .strlen(_8_3_ext) = 3, error, "ext size"

	.byte _8_3_name		; 8 byte
	.byte	_8_3_ext			; 3 byte
	.byte attr				; attr
	.byte 0					; reserved
	.byte 0					; create time millis
	fat_datetime 2020, 4, 10, 11, 22, 34 		; created date/time
	fat_date 2020, 4, 10	; last modified
	.word cl>>16	 		; cl high
	fat_datetime 2020, 4, 10, 11, 22, 34 		; modified date/time
	.word cl & $ffff	 	; cl low
	.dword fsize
.endmacro

.macro assertDirEntry address
		assertMemory address, 32
.endmacro

.macro load_block address
		lda #<address
		sta test_data_ptr
		lda #>address
		sta test_data_ptr+1
		jsr load_test_data
.endmacro

.macro data_loader
load_test_data:
		lda #0
		ldy #0
@l0:	lda (test_data_ptr),y
		sta (read_blkptr), y
		iny
		bne @l0
		rts
.endmacro
