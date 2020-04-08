	.include "asmunit.inc" 	; test api

	.include "common.inc"
	.include "errno.inc"
	.include "fcntl.inc"
	.include "fat32.inc"
	.include "zeropage.inc"

.macro setup testname
		test testname
		jsr setUp
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
	.byte attr				; 1
	.byte 0
	.byte 122
	.dword $ED037F50 		;created date/time
	.word $7F50		 		;last access
	.word cl>>16	 		;cl high
	.dword $ED037F50 		;modified date/time
	.word cl & $ffff	 	;cl low
	.dword fsize
.endmacro

.macro load_block address
		lda #<address
		sta test_data_ptr
		lda #>address
		sta test_data_ptr+1
		jsr load_test_data
.endmacro
