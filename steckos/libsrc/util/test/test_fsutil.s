.include "asmunit.inc" 	; unit test api

.include "fat32.inc"

.autoimport
.export dirent
.code


    test "fat_entry_filesize"

    ldy #42

    jsr print_filesize
    assertOut ">64k "
    assertY 42
 

    test "fat_entry_wrtdate"

    ldy #F32DirEntry::WrtDate

    jsr print_fat_date
    assertY F32DirEntry::WrtDate
    assertOut "00.0"

    test "fat_entry_wrttime"

    ldy #F32DirEntry::WrtTime+1
    
    jsr print_fat_time
    assertOut "00:0"


    test "fat_entry_filename"

    jsr print_filename
    assertOut "foobar.baz "


	brk

cnt: 	.byte $04
dirs:	.byte $00
files:	.byte $00
dirent:
    .byte "FOOBAR  BAZ" ; filename+ext
    .byte 0             ; attribute
    .byte 0             ; Reserved
    .byte 0             ; CrtTimeMillis
    .word $0000         ; CrtTimeMillis
    .word $0000         ; CrtDate
    .word $0000         ; LstModDate
    .word $0000         ; FstClusHI
    .word $0000         ; WrtTime
    .word $0000         ; WrtDate
    .word $0000         ; FstClusLO
    .dword 246543       ; $03c30f
