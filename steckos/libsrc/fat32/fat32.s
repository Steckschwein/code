; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.


.ifdef DEBUG_FAT32 ; debug switch for this module
  debug_enabled=1
.endif

; TODO OPTIMIZATIONS
;  1. avoid fat block read - calculate fat lba address, but before reading a the fat block, compare the new lba_addr with the previously saved fat_lba
;
.include "zeropage.inc"
.include "common.inc"
.include "fat32.inc"
.include "rtc.inc"
.include "errno.inc"  ; from ca65 api
.include "fcntl.inc"  ; from ca65 api
.include "stdio.inc"  ; from ca65 api

.include "debug.inc"

.importzp __volatile_tmp

.autoimport

.export fat_fopen
.export fat_fread_byte
.export fat_fseek
.export fat_find_first, fat_find_next
.export fat_close_all, fat_close

.export __fat_fseek_cluster
.export __fat_init_fdarea

.code

    ;  seek n bytes within file denoted by the given FD
    ;in:
    ;  X   - offset into fd_area
    ;  A/Y - pointer to seek_struct - @see fat32.inc
    ;out:
    ;  C=0 on success (A=0), C=1 and A=<error code> or C=1 and A=0 (EOK) if EOF reached
fat_fseek:

    _is_file_open   ; otherwise rts C=1 and A=#EINVAL
    _is_file_dir    ; otherwise rts C=1 and A=#EISDIR

    sta __volatile_ptr
    sty __volatile_ptr+1

    ldy #Seek::Whence
    lda (__volatile_ptr),y
    cmp #SEEK_SET
    ; TODO support SEEK_CUR, SEEK_END
    beq @l_filesize
@l_exit_err:
    lda #EINVAL
    sec
    rts
@l_filesize:
    ; check requested seek_pos < FileSize
    ldy #Seek::Offset+3
    lda (__volatile_ptr),y
    cmp fd_area+F32_fd::FileSize+3,x
    debug16 "fseek 0", __volatile_ptr
    beq :+
    bcs @l_exit_err
:   dey
    lda (__volatile_ptr),y
    cmp fd_area+F32_fd::FileSize+2,x
    debug16 "fseek 1", __volatile_ptr
    beq :+
    bcs @l_exit_err
:   dey
    lda (__volatile_ptr),y
    cmp fd_area+F32_fd::FileSize+1,x
    debug16 "fseek 2", __volatile_ptr
    beq :+
    bcs @l_exit_err
:   dey
    lda (__volatile_ptr),y
    cmp fd_area+F32_fd::FileSize+0,x
    debug16 "fseek 3", __volatile_ptr
    bcs @l_exit_err
    ; save seek pos
:   sta fd_area+F32_fd::seek_pos+0,x
    iny
    lda (__volatile_ptr),y
    sta fd_area+F32_fd::seek_pos+1,x
    iny
    lda (__volatile_ptr),y
    sta fd_area+F32_fd::seek_pos+2,x
    iny
    lda (__volatile_ptr),y
    sta fd_area+F32_fd::seek_pos+3,x
    debug32 "fseek s", fd_area+F32_fd::seek_pos+$17
;in:
;  X - offset into fd_area
;out:
;  C=0 on success (A=0), C=1 and A=error code otherwise
__fat_fseek_cluster:
    ; calculate amount of cluster chain iterations by "seek_pos" / ($200 * "sec per cluster") => (seek_pos(3 to 1) >> 1) >> "bit(sec_per_cluster)"
    lda fd_area+F32_fd::seek_pos+3,x
    sta volumeID+VolumeID::temp_dword+2
    lda fd_area+F32_fd::seek_pos+2,x
    sta volumeID+VolumeID::temp_dword+1
    lda fd_area+F32_fd::seek_pos+1,x
    sta volumeID+VolumeID::temp_dword+0

    lda volumeID+VolumeID::BPB_SecPerClus
@calc_cln:
    tay
    lsr volumeID+VolumeID::temp_dword+2
    ror volumeID+VolumeID::temp_dword+1
    ror volumeID+VolumeID::temp_dword+0
    tya
    lsr
    bne @calc_cln

    lda fd_area+F32_fd::StartCluster+0,x
    sta fd_area+F32_fd::CurrentCluster+0,x
    lda fd_area+F32_fd::StartCluster+1,x
    sta fd_area+F32_fd::CurrentCluster+1,x
    lda fd_area+F32_fd::StartCluster+2,x
    sta fd_area+F32_fd::CurrentCluster+2,x
    lda fd_area+F32_fd::StartCluster+3,x
    sta fd_area+F32_fd::CurrentCluster+3,x
@seek_cln:
    lda volumeID+VolumeID::temp_dword+2
    ora volumeID+VolumeID::temp_dword+1
    ora volumeID+VolumeID::temp_dword+0
    debug32 "seek cln", volumeID+VolumeID::temp_dword
    beq @l_exit_ok
    debug32 "seek cl >", fd_area+F32_fd::CurrentCluster+$17 ; $17 => fd_area offset fd=2
    jsr __fat_next_cln
    bcs @l_exit
    _dec24 volumeID+VolumeID::temp_dword
    bra @seek_cln
@l_exit_ok:
    debug32 "seek cl <", fd_area+F32_fd::CurrentCluster+$17
    clc
@l_exit:
    rts
@l_exit_err:
    lda #ENOSYS
    sec
    rts


;in:
;  X - offset into fd_area
;out:
;  C=0 on success and A=<byte>, C=1 on error and A=<error code> or C=1 and A=0 (EOK) if EOF reached
fat_fread_byte:

    _is_file_open   ; otherwise rts C=1 and A=#EINVAL
    _is_file_dir    ; otherwise rts C=1 and A=#EISDIR

    _cmp32_x fd_area+F32_fd::seek_pos, fd_area+F32_fd::FileSize, :+
    lda #EOK
    rts ; exit - EOK (0) and C=1

:   phy
    jsr __fat_prepare_access
    bcs @l_exit

    lda (__volatile_ptr)
    _inc32_x fd_area+F32_fd::seek_pos
    clc
@l_exit:
    ply
    debug16 "rd_ex", __volatile_ptr
    rts

; in:
;  A/X - pointer to zero terminated string with the file path
;    Y - file mode constants - see fcntl.inc (cc65)
;    O_RDONLY  = $01
;    O_WRONLY  = $02
;    O_RDWR    = $03
;    O_CREAT    = $10
;    O_TRUNC    = $20
;    O_APPEND  = $40
;    O_EXCL    = $80
; out:
;  .X - index into fd_area of the opened file
;  C=0 on success (A=0), C=1 and A=error code otherwise
fat_fopen:
    sty __volatile_tmp        ; save open flag
    ldy #FD_INDEX_CURRENT_DIR    ; use current dir fd as start directory
    jsr __fat_open_path
    bne @l_error
    lda fd_area + F32_fd::Attr, x
    and #DIR_Attr_Mask_Dir      ; regular file or directory?
    beq @l_atime                ; not dir, update atime if desired, exit ok
    lda #EISDIR                 ; was directory, we must not free any fd
@l_error:
    cmp #ENOENT                 ; no such file or directory ?
    bne @l_exit_err             ; other error, then exit
    lda __volatile_tmp          ; check if we should create a new file
    and #(O_CREAT | O_WRONLY | O_APPEND | O_TRUNC)
    bne :+
    lda #ENOENT                 ; no "write" flags set, exit with ENOENT
@l_exit_err:
    sec
    rts

:   debug "r+"
    copypointer dirptr, s_ptr2
    jsr string_fat_name        ; build fat name upon input string (filenameptr)
    bne @l_exit_err
    jsr __fat_alloc_fd        ; alloc a fd for the new file we want to create to make sure we get one before
    bcs @l_exit_err          ; we do any sd block writes which may result in various errors

    lda __volatile_tmp        ; save file open flags
    sta fd_area + F32_fd::flags, x
    lda #DIR_Attr_Mask_Archive    ; create as regular file with archive bit set
    jsr __fat_set_fd_attr_dirlba  ; update dir lba addr and dir entry number within fd from lba_addr and dir_ptr which where setup during __fat_opendir_cwd from above
    jsr __fat_write_dir_entry    ; create dir entry at current dirptr
    bcc @l_exit_ok
    jmp fat_close          ; free the allocated file descriptor if there where errors, C=1 and A are preserved
@l_atime:
;    jsr __fat_set_direntry_modify_datetime
;    lda #EOK                ; A=0 (EOK)
    clc
@l_exit_ok:
    debug "fop"
    rts

fat_close_all:
    ldx #(2*FD_Entry_Size)  ; skip first 2 entries, they're reserved for current and temp dir
__fat_init_fdarea:
    lda #$ff
@l1:
    sta fd_area + F32_fd::CurrentCluster, x
    inx
    cpx #(FD_Entry_Size*FD_Entries_Max)
    bne @l1
    rts

    ; free file descriptor quietly
    ; in:
    ;  X - offset into fd_area
fat_close = __fat_free_fd

    ; find first dir entry
    ; in:
    ;  X - file descriptor (index into fd_area) of the directory
    ;  filenameptr  - with file name to search
    ; out:
    ;  Z=1 on success (A=0), Z=0 and A=error code otherwise
    ;  C=1 if found and dirptr is set to the dir entry found (requires Z=1), C=0 otherwise
fat_find_first:
    txa                    ; use the given fd as source (Y)
    tay
    ldx #FD_INDEX_TEMP_DIR          ; we use the temp dir with a copy of given fd, cause F32_fd::CurrentCluster is adjusted if end of cluster is reached
    jsr __fat_clone_fd
    jmp __fat_find_first_mask

fat_find_next = __fat_find_next