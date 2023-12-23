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
    debug "fat fseek"
    cmp #SEEK_SET
    ; TODO support SEEK_CUR, SEEK_END
    bne @l_exit_err
    ; save new seek pos
    ldy #Seek::Offset
    lda (__volatile_ptr),y
    sta fd_area+F32_fd::SeekPos+0,x
    iny
    lda (__volatile_ptr),y
    sta fd_area+F32_fd::SeekPos+1,x
    iny
    lda (__volatile_ptr),y
    sta fd_area+F32_fd::SeekPos+2,x
    iny
    lda (__volatile_ptr),y
    sta fd_area+F32_fd::SeekPos+3,x

    lda #FD_STATUS_DIRTY                 ; set dirty - @see __fat_prepare_block_access
    ora fd_area+F32_fd::status,x
    sta fd_area+F32_fd::status,x

    lda #EOK
    clc
    rts
@l_exit_err:
    lda #EINVAL
    sec
    rts

; in:
;   X - fd
;   C - C=0 read access, C=1 write access
__fat_fseek_cluster:
    debug "seek >"
    ; calculate amount of clusters required for requested seek position - "SeekPos" / ($200 * "sec per cluster") => (SeekPos(3 to 1) >> 1) >> "bit(sec_per_cluster)"
    lda fd_area+F32_fd::SeekPos+3,x
    sta volumeID+VolumeID::temp_dword+2
    lda fd_area+F32_fd::SeekPos+2,x
    sta volumeID+VolumeID::temp_dword+1
    lda fd_area+F32_fd::SeekPos+1,x
    sta volumeID+VolumeID::temp_dword+0

    lda volumeID+VolumeID::BPB_SecPerClus ; TODO pre calc loop count
:   tay
    lsr volumeID+VolumeID::temp_dword+2
    ror volumeID+VolumeID::temp_dword+1
    ror volumeID+VolumeID::temp_dword+0
    tya
    lsr
    bne :-

    jsr __fat_open_start_cluster

    ; TODO check amount of free clusters before seek if file opened with r+/w+ otherwise we may fail within seek and leave with partial reserved clusters and we dont recover (yet)
    ; read fsinfo and cmp temp_dword with fsinfo:FreeClus
    lda volumeID+VolumeID::temp_dword+2
    ora volumeID+VolumeID::temp_dword+1
    ora volumeID+VolumeID::temp_dword+0
    debug32 "seek cnt", volumeID+VolumeID::temp_dword
    beq @l_exit_ok
@seek_cln:
    jsr __fat_next_cln
    bcs @l_exit
    _dec24 volumeID+VolumeID::temp_dword
    debug32 "seek nxt", volumeID+VolumeID::temp_dword
    bne @seek_cln
@l_exit_ok:
    lda fd_area+F32_fd::status,x
    and #<~FD_STATUS_DIRTY                 ; clear dirty
    sta fd_area+F32_fd::status,x
    clc
@l_exit:
    debug32 "seek < seek", fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos
    debug32 "seek < cl", fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster
    rts


;in:
;  X - offset into fd_area
;out:
;  C=0 on success and A=<byte>, C=1 on error and A=<error code> or C=1 and A=0 (EOK) if EOF reached
fat_fread_byte:

    _is_file_open   ; otherwise rts C=1 and A=#EINVAL
    _is_file_dir    ; otherwise rts C=1 and A=#EISDIR

    _cmp32_x fd_area+F32_fd::SeekPos, fd_area+F32_fd::FileSize, :+
    lda #EOK
    rts ; exit - EOK (0) and C=1

:   phy

    jsr __fat_prepare_block_access_read
    bcs @l_exit

    sta __volatile_ptr
    sty __volatile_ptr+1

    lda (__volatile_ptr)
    _inc32_x fd_area+F32_fd::SeekPos
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
;    O_CREAT   = $10
;    O_TRUNC   = $20
;    O_APPEND  = $40
;    O_EXCL    = $80
; out:
;   .X - index into fd_area of the opened file
;   C=0 on success, C=1 and A=<error code> otherwise
fat_fopen:
    sty __volatile_tmp           ; save open flag
    debug8 "fopen vtmp", __volatile_tmp
    ldy #FD_INDEX_CURRENT_DIR    ; use current dir fd as start directory
    jsr __fat_open_path
    bcs @l_error
    lda fd_area+F32_fd::Attr,x
    and #DIR_Attr_Mask_Dir      ; file or directory?
    beq @l_open                 ; no ok, file opened
    lda #EISDIR                 ; was directory, we must not free any fd
@l_error:
    cmp #ENOENT                 ; no such file or directory ?
    bne @l_exit_err             ; other error, exit
    lda __volatile_tmp          ; check if we should create a new file
    and #(O_CREAT | O_WRONLY | O_APPEND | O_TRUNC)
    bne @l_touch
    lda #ENOENT                 ; no "write" flags set, exit with ENOENT
@l_exit_err:
    sec
    rts
@l_open:
    lda __volatile_tmp
    sta fd_area+F32_fd::flags,x
    clc
    rts
@l_touch:
    jmp __fat_fopen_touch


fat_close_all:
    ldx #(2*FD_Entry_Size)  ; skip first 2 entries, they're reserved for current and temp dir
__fat_init_fdarea:
    stz fd_area,x
    inx
    cpx #(FD_Entry_Size*FD_Entries_Max)
    bne __fat_init_fdarea
    rts

; close file, update dir entry and free file descriptor quietly
; in:
;   X - offset into fd_area
; out:
;   C=0 on success, C=1 on error with A=<error code>
fat_close:
    jsr __fat_update_direntry
    jmp __fat_free_fd

; find first dir entry
; in:
;   X - file descriptor (index into fd_area) of the directory
;   filenameptr  - with file name to search
; out:
;   Z=1 on success (A=0), Z=0 and A=error code otherwise
;   C=0 if found and dirptr is set to the dir entry found (requires Z=1), C=1 otherwise
fat_find_first:
    jsr __fat_clone_fd_temp_fd
    jmp __fat_find_first_mask

fat_find_next = __fat_find_next
