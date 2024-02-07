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

;@module: fat32

.ifdef DEBUG_FAT32 ; debug switch for this module
  debug_enabled=1
.endif

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

.export fat_open
.export fat_fopen
.export fat_fread_byte
.export fat_find_first, fat_find_next
.export fat_close_all, fat_close

.export __fat_fseek_cluster
.export __fat_init_fdarea

.code

; in:
;   X - fd
;   C - C=0 read access, C=1 write access
; out:
;   C=0 on success, C=1 on error and A=error code or C=1/A=0 EOC
__fat_fseek_cluster:
    debug32 "seek cl >", fd_area+(2*FD_Entry_Size)+F32_fd::SeekPos

    bcc :+ ; C=0 read access

    jsr __fat_is_cln_zero
    bne :+
    jsr __fat_reserve_start_cluster ; start cluster zero, write access, we have to reserve the start cluster first
    bcs @l_exit
    sec   ; restore write access set C=1

:   rol   ; save read/write access, set bit 0 save in Y
    tay

    jsr __fat_set_fd_start_cluster

    ; calculate amount of clusters required for requested seek position - "SeekPos" / ($200 * "sec per cluster") => (SeekPos(3 to 1) >> 1) >> "bit(sec_per_cluster)"
    lda fd_area+F32_fd::SeekPos+3,x
    sta volumeID+VolumeID::cluster_seek_cnt+2
    lda fd_area+F32_fd::SeekPos+2,x
    sta volumeID+VolumeID::cluster_seek_cnt+1
    lda fd_area+F32_fd::SeekPos+1,x
    sta volumeID+VolumeID::cluster_seek_cnt+0

    lda volumeID+VolumeID::BPB_SecPerClusCount ; Count + 1 cause SeekPos / $200 gives amount of blocks/sectors, so we need at least one iteration
:   lsr volumeID+VolumeID::cluster_seek_cnt+2
    ror volumeID+VolumeID::cluster_seek_cnt+1
    ror volumeID+VolumeID::cluster_seek_cnt+0
    dea
    bpl :-

@l_seek:
    ; TODO check amount of free clusters before seek if file opened with r+/w+ otherwise we may fail within seek and leave with partial reserved clusters and we dont recover (yet)
    ; read fsinfo and cmp cluster_seek_cnt with fsinfo:FreeClus
    lda volumeID+VolumeID::cluster_seek_cnt+2
    ora volumeID+VolumeID::cluster_seek_cnt+1
    ora volumeID+VolumeID::cluster_seek_cnt+0
    debug32 "seek 0", volumeID+VolumeID::cluster_seek_cnt
    beq @l_exit_ok
@seek_cln:
    tya                       ; read/write access to A
    lsr                       ; restore carry
    jsr __fat_next_cln
    bcs @l_exit
    _dec24 volumeID+VolumeID::cluster_seek_cnt
    debug32 "seek c", volumeID+VolumeID::cluster_seek_cnt
    bne @seek_cln
@l_exit_ok:
    clc
@l_exit:
    lda fd_area+F32_fd::status,x
    and #<~FD_STATUS_DIRTY                 ; clear dirty
    sta fd_area+F32_fd::status,x
    debug32 "seek <", fd_area+(2*FD_Entry_Size)+F32_fd::CurrentCluster
    rts

;@name: "fat_fread_byte"
;@in: X, "offset into fd_area"
;@out: C=0 on success and A="received byte", C=1 on error and A="error code" or C=1 and A=0 (EOK) if EOF is reached
;@desc: "read byte from file"
fat_fread_byte:

    _is_file_open   ; otherwise rts C=1 and A=#EINVAL

    lda fd_area+F32_fd::Attr,x
    and #DIR_Attr_Mask_Dir		; is directory
    bne :+                    ; skip file size check

    _cmp32_x fd_area+F32_fd::SeekPos, fd_area+F32_fd::FileSize, :+
    debug16 "rd byte eof <", __volatile_ptr
    lda #EOK
    rts ; exit - EOK (0) and C=1

:   phy

    jsr __fat_prepare_data_block_access_read
    bcs @l_exit

    sta __volatile_ptr
    sty __volatile_ptr+1

    jsr __fat_inc_seekpos   ; seek+1

    lda (__volatile_ptr)    ; read byte

    clc
@l_exit:
    ply
    debug16 "rd byte <", __volatile_ptr
    rts

; open file/directory
; in:
;   A/X - pointer to zero terminated string with the file path
;   Y - file mode constants - see fcntl.inc (cc65)
;     O_RDONLY  = $01
;     O_WRONLY  = $02
;     O_RDWR    = $03
;     O_CREAT   = $10
;     O_TRUNC   = $20
;     O_APPEND  = $40
;     O_EXCL    = $80
; out:
;   X - index into fd_area of the opened file
;   A - file attr as stored in FAT32 directory entry
;   C=0 on success, C=1 and A=<error code> otherwise
fat_open:
          debug "fopen >"
          phy                          ; save open flag
          ldy #FD_INDEX_CURRENT_DIR    ; use current dir fd as start directory
          jsr __fat_open_path
          ply
          bcs @l_exit
          tya
          sta fd_area+F32_fd::flags,x
          lda fd_area+F32_fd::Attr,x
@l_exit:  debug "fopen <"
          rts

; in:
;   A/X - pointer to zero terminated string with the file path
;   Y - file mode constants - see fcntl.inc (cc65)
;     O_RDONLY  = $01
;     O_WRONLY  = $02
;     O_RDWR    = $03
;     O_CREAT   = $10
;     O_TRUNC   = $20
;     O_APPEND  = $40
;     O_EXCL    = $80
; out:
;   X - index into fd_area of the opened file
;   C=0 on success, C=1 and A=<error code> otherwise

;@name: "fat_fopen"
;@in: A, "low byte of pointer to zero terminated string with the file path"
;@in: X, "high byte of pointer to zero terminated string with the file path"
;@in: Y, "file mode constants O_RDONLY = $01, O_WRONLY = $02, O_RDWR = $03, O_CREAT = $10, O_TRUNC = $20, O_APPEND = $40, O_EXCL = $80
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@out: X, "index into fd_area of the opened file"
;@desc: "open file"
fat_fopen:
          jsr fat_open
          bcs @l_not_open
          and #DIR_Attr_Mask_Dir      ; file or directory opened?
          beq @l_exit
          jsr __fat_free_fd           ; was directory, free fd
          lda #EISDIR                 ; exit
@l_not_open:
          debug "ffopen"
          cmp #EOK                    ; C=1/A=EOK error from open was end of cluster (@see find_first/_next)
          beq @l_add_dirent           ; go on with write check
          cmp #ENOENT                 ; no such file or directory ?
          bne @l_exit_err
@l_add_dirent:
          tya                         ; get back open flags - from fat_open() above
          and #(O_CREAT | O_WRONLY | O_APPEND | O_TRUNC)  ; check write access
          beq @l_enoent
          jmp __fat_fopen_touch       ; write access, we create a new file
@l_enoent:
          lda #ENOENT                 ; no "write" flags set, exit with ENOENT
@l_exit_err:
          sec
@l_exit:  debug "ffopen <"
          rts


fat_close_all:
          ldx #(2*FD_Entry_Size)  ; skip first 2 entries, they're reserved for current dir and temp file
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
;@name: "fat_close"
;@in: X, "index into fd_area of the opened file"
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@desc: "close file, update dir entry and free file descriptor quietly"
fat_close:
    lda fd_area+F32_fd::flags,x
    and #(O_CREAT | O_WRONLY | O_APPEND | O_TRUNC) ; file write access?
    beq :+ ; read access, dir entry has not modified we skip the update
    jsr __fat_update_direntry
:   jmp __fat_free_fd

; find first dir entry
; in:
;   X - file descriptor (index into fd_area) of the directory
;   A/Y - pointer to file name matcher strategy
; out:
;   Z=1 on success (A=0), Z=0 and A=error code otherwise
;   C=0 if found and dirptr is set to the dir entry found (requires Z=1), C=1 otherwise
;@name: "fat_find_first"
;@in: A, "low byte of pointer to zero terminated string with the file path"
;@in: Y, "high byte of pointer to zero terminated string with the file path"
;@in: X, "file descriptor (index into fd_area) of the directory"
;@out: Z, "1 on success, 0 on error"
;@out: A, "error code"
;@out: C, "0 if found and dirptr is set to the dir entry found (requires Z=1), else 1"
;@desc: "find first dir entry"
fat_find_first = __fat_find_first_mask

; in:
;  X - directory fd index into fd_area
; out:
;  C=0 on success (A=0), C=1 and A=<error code> otherwise
;@name: "fat_find_next"
;@in: X, "file descriptor (index into fd_area) of the directory"
;@out: A, "error code"
;@out: C, "0 on success (A=0), C=1 and A=<error code>, else 1"
;@desc: "find next dir entry"
fat_find_next = __fat_find_next
