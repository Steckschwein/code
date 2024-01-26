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


.ifdef DEBUG_FAT32_WRITE_DIR ; debug switch for this module
  debug_enabled=1
.endif

.include "zeropage.inc"
.include "common.inc"
.include "fat32.inc"
.include "rtc.inc"
.include "errno.inc"  ; from ca65 api
.include "fcntl.inc"  ; from ca65 api
.include "debug.inc"

.export fat_mkdir
.export fat_rmdir

;@module: fat32
.autoimport

; delete a directory entry denoted by given path in A/X
;in:
;  A/X - pointer to the directory path
; out:
;  C=0 on success, C=1 and A=error code otherwise

;@name: "fat_rmdir"
;@in: A, "low byte of pointer to directory string"
;@in: X, "high byte of pointer to directory string"
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@desc: "delete a directory entry denoted by given path in A/X"
fat_rmdir:
    jsr fat_opendir
    bcs @l_exit
    debugdirentry
    jsr __fat_is_dot_dir
    beq @l_err_einval
    jsr __fat_dir_isempty
    bcs @l_exit
    jmp __fat_unlink
@l_err_einval:
    lda #EINVAL
    sec
@l_exit:
    debug "rmdir <"
    rts

; in:
;   A/X - pointer to the directory name
; out:
;   C=0 on success (A=0), C=1 on error and A=error code otherwise
;@name: "fat_rmdir"
;@in: A, "low byte of pointer to directory string"
;@in: X, "high byte of pointer to directory string"
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@desc: "create directory denoted by given path in A/X"
fat_mkdir:
        ldy #O_CREAT
        jsr fat_opendir
        bcs :+
        lda #EEXIST                       ; C=0 - open success, file/dir exists already, exit
@l_exit_err:
        sec
        rts
:       cmp #ENOENT                       ; we expect 'no such file or directory' error
        beq @l_add_dirent
        cmp #EOK                          ; or error from open was end of cluster (@see find_first/_next)?
        bne @l_exit_err                   ; exit on other error

        debug "fat mkd pba >"
        sec                               ; if eoc we have to prepare block access first to write new dir entry
        jsr __fat_prepare_block_access
@l_add_dirent:
        debug16 "fat mkd >", dirptr
        debug32 "fat mkd >", fd_area+FD_INDEX_TEMP_FILE+F32_fd::SeekPos

        jsr __fat_alloc_fd                ; allocate a dedicated fd for the new directory
        bcs @l_exit

        jsr __fat_set_fd_dirlba           ; save the dir entry lba and offset to new allocated fd

        jsr __fat_reserve_start_cluster   ; reserve a cluster for the new directory and store them in fd_area with X at F32_fd::StartCluster
        bcs @l_exit_close

        lda #DIR_Attr_Mask_Dir            ; set type directory
        sta fd_area+F32_fd::Attr,x
        jsr __fat_add_direntry            ; create and write new directory entry
        bcs @l_exit_close

        jsr __fat_write_new_direntry      ; write the data of the newly created directory with prepared data from dirptr
@l_exit_close:
        jsr __fat_free_fd
@l_exit:
        debug "fat mkdir <"
        rts

; in:
;   X - file descriptor of directory
; out:
;   C=0 if directory is empty or contains <=2 entries ("." and ".."), C=1 otherwise
__fat_dir_isempty:
    phx
    jsr __fat_count_direntries
    cmp #3              ; >= 3 dir entries, must be more then only the "." and ".."
    bcc @l_exit
    lda #ENOTEMPTY
@l_exit:
    plx
    rts


; in:
;  X - file descriptor of directory
; out:
;  A - number of directory entries (with "." and "..")
__fat_count_direntries:
    lda #<@match_always
    ldy #>@match_always
    jsr __fat_find_first_mask    ; find within dir given in X
    bcs @l_exit
    ldy #0
@l_next:
    lda (dirptr)
    cmp #DIR_Entry_Deleted
    beq @l_find_next
    iny
@l_find_next:
    phy
    jsr __fat_find_next
    ply
    bcc @l_next
@l_exit:
    tya
    debug "f_cnt_d"
    rts
@match_always:
    clc
    lda (dirptr)
    beq :+  ; deleted, C=0 no match
    sec
:   rts


; create the "." and ".." entry of the new directory
; in:
;   .X - the file descriptor into fd_area of the dir entry
;   dirptr - set to dir entry within block_data buffer
; out:
;   C=0 on success, C=1 otherwise and A=error code
__fat_write_new_direntry:

    jsr __fat_erase_block_fat

    ldy #F32DirEntry::Attr                                   ; copy data of the dir entry (dirptr) created beforehand to easily take over create time, mod time etc., cluster nr
@l_dir_cp:
    lda (dirptr), y
    debug16 "f wr nd", dirptr
    sta block_fat+0*DIR_Entry_Size, y                        ; 1st dir entry
    sta block_fat+1*DIR_Entry_Size, y                        ; 2nd dir entry
    iny
    cpy #DIR_Entry_Size
    bne @l_dir_cp

    ldy #.sizeof(F32DirEntry::Name) + .sizeof(F32DirEntry::Ext) -1  ; fill name with ' ' and build the "." and ".." entries
    lda #' '
@l_clr_name:
    sta block_fat+0*DIR_Entry_Size, y                        ; 1st dir entry
    sta block_fat+1*DIR_Entry_Size, y                        ; 2nd dir entry
    dey
    bne @l_clr_name
    lda #'.'
    sta block_fat+0*DIR_Entry_Size+F32DirEntry::Name+0        ; 1st entry "."
    sta block_fat+1*DIR_Entry_Size+F32DirEntry::Name+0        ; 2nd entry ".."
    sta block_fat+1*DIR_Entry_Size+F32DirEntry::Name+1

    ; use the fd of the temp dir (FD_INDEX_TEMP_FILE) - represents the last visited directory which must be the parent of this one ("..") - we can easily derrive the parent cluster. FTW!
    debug32 "cd_sln", fd_area + FD_INDEX_TEMP_FILE + F32_fd::StartCluster
    debug32 "cd_cln", fd_area + FD_INDEX_TEMP_FILE + F32_fd::CurrentCluster

    lda fd_area + FD_INDEX_TEMP_FILE + F32_fd::StartCluster+0
    sta block_fat+1*DIR_Entry_Size+F32DirEntry::FstClusLO+0
    lda fd_area + FD_INDEX_TEMP_FILE + F32_fd::StartCluster+1
    sta block_fat+1*DIR_Entry_Size+F32DirEntry::FstClusLO+1
    lda fd_area + FD_INDEX_TEMP_FILE + F32_fd::StartCluster+2
    sta block_fat+1*DIR_Entry_Size+F32DirEntry::FstClusHI+0
    lda fd_area + FD_INDEX_TEMP_FILE + F32_fd::StartCluster+3
    sta block_fat+1*DIR_Entry_Size+F32DirEntry::FstClusHI+1

    jsr __fat_set_fd_start_cluster
    jsr __calc_lba_addr
    jsr __fat_write_block_fat
    bcs @l_exit

    jsr __fat_erase_block_fat

    ldy volumeID+ VolumeID:: BPB_SecPerClusMask     ; Y = VolumeID::SecPerClus-1 - reamining blocks of the cluster with empty dir entries
    beq @l_exit_ok
    debug32 "mkdr er", lba_addr
@l_erase:
    jsr __inc_lba_address                           ; next block within cluster
    jsr __fat_write_block_fat
    bcs @l_exit
    dey
    bne @l_erase                                    ; all blocks written?
@l_exit_ok:
    tya ; Y=0 => A=EOK
@l_exit:
    debug "fat_wr_nd"
    rts


__fat_erase_block_fat:
    ldy #0                      ; safely, fill the new dir block with 0 to mark end-of-directory
    tya
@l_erase:
    sta block_fat+$000, y
    sta block_fat+$100, y
    iny
    bne @l_erase
    rts



__fat_is_dot_dir:
    lda #'.'
    cmp (dirptr)
    bne @l_exit
    ldy #10
    lda #' '
@l_next:
    cmp (dirptr),y
    bne @l_exit
    dey
    bne @l_next
@l_exit:
    rts
