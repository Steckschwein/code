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
.export fat_update_direntry

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
              bcs @exit
              debugdirentry
              jsr __fat_is_dot_dir
              beq @err_einval
              jsr __fat_dir_isempty
              bcs @err_exit
              jmp __fat_unlink
@err_einval:  lda #EINVAL
@err_exit:    sec
              jsr __fat_free_fd
@exit:        debug "rmdir <"
              rts

; in:
;   A/X - pointer to the directory name
; out:
;   C=0 on success (A=0), C=1 on error and A=error code otherwise
;@name: "fat_mkdir"
;@in: A, "low byte of pointer to directory string"
;@in: X, "high byte of pointer to directory string"
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@desc: "create directory denoted by given path in A/X"
fat_mkdir:
        ldy #O_RDONLY
        jsr fat_open
        bcs :+
        jsr __fat_free_fd                 ; C=0 - open success file/dir exists already
        lda #EEXIST                       ; EEXIST and exit

:       cmp #ENOENT                       ; we expect 'no such file or directory' error
        beq @l_add_dirent
        cmp #EOK                          ; C=1/A=EOK was end of cluster from fat_opendir
        beq :+                            ; exit on other error
        sec
        rts

:       debug "mkd pba >"
        sec                               ; EOC of current directory reached, we have to reserve a new block to write the new dir entry into
        jsr __fat_prepare_data_block_access
        bcs @l_exit
        sta dirptr
        sty dirptr+1
@l_add_dirent:
        debug16 "mkd dirp >", dirptr
        debug32 "mkd seek >", fd_area+FD_INDEX_TEMP_FILE+F32_fd::SeekPos

        jsr __fat_alloc_fd                ; allocate a dedicated fd for the new directory
        bcs @l_exit

        lda #DIR_Attr_Mask_Dir            ; set type directory
        jsr __fat_set_fd_dirlba_attr      ; dirptr and lba_addr set from opendir() - save them in the new allocated fd

        jsr __fat_reserve_start_cluster   ; reserve a cluster for the new directory and store them in fd_area with X at F32_fd::StartCluster
        bcs @l_exit_close

        jsr __fat_add_direntry            ; create and write new directory entry
        bcs @l_exit_close

        jsr __fat_write_new_direntry      ; finally write data of newly created directory with prepared data from dirptr
@l_exit_close:
        jsr __fat_free_fd
@l_exit:
        debug "mkd <"
        rts


__fat_write_new_direntry:
        ; create the "." and ".." entry of the new directory
        ; TODO FIXME - for ".." dir entry all date and time fields must be set to the same value as that for the containing directory
        jsr __fat_erase_block_fat

        ldy #DIR_Entry_Size-1                                   ; copy data of the dir entry (dirptr) created beforehand to easily take over create time, mod time, cluster nr etc.,
@l_dir_cp:
        lda (dirptr), y
        sta block_fat+0*DIR_Entry_Size, y                       ; 1st dir entry
        sta block_fat+1*DIR_Entry_Size, y                       ; 2nd dir entry
        lda #' '
        sta block_fat+0*DIR_Entry_Size-(F32DirEntry::Attr), y   ; erase name:ext 1st dir entry - Note: we erase some more bytes, saves a loop and values are copied over above
        sta block_fat+1*DIR_Entry_Size-(F32DirEntry::Attr), y   ; erase name:ext 2nd dir entry
        dey
        cpy #F32DirEntry::Attr-1
        bne @l_dir_cp
        lda #'.'
        sta block_fat+0*DIR_Entry_Size+F32DirEntry::Name+0      ; 1st entry "."
        sta block_fat+1*DIR_Entry_Size+F32DirEntry::Name+0      ; 2nd entry ".."
        sta block_fat+1*DIR_Entry_Size+F32DirEntry::Name+1

        ; use the fd of the temp dir (FD_INDEX_TEMP_FILE) - represents the last visited directory which must be the parent of this one ("..") - we can easily derrive the parent cluster. FTW!
        debug32 "dirnt scl", fd_area + FD_INDEX_TEMP_FILE + F32_fd::StartCluster
        lda fd_area + FD_INDEX_TEMP_FILE + F32_fd::StartCluster+0
        sta block_fat+1*DIR_Entry_Size+F32DirEntry::FstClusLO+0
        lda fd_area + FD_INDEX_TEMP_FILE + F32_fd::StartCluster+1
        sta block_fat+1*DIR_Entry_Size+F32DirEntry::FstClusLO+1
        lda fd_area + FD_INDEX_TEMP_FILE + F32_fd::StartCluster+2
        sta block_fat+1*DIR_Entry_Size+F32DirEntry::FstClusHI+0
        lda fd_area + FD_INDEX_TEMP_FILE + F32_fd::StartCluster+3
        sta block_fat+1*DIR_Entry_Size+F32DirEntry::FstClusHI+1

        debug "dirnt fat"
        debugdirentry
        jsr __fat_set_fd_start_cluster
        jsr __calc_lba_addr
        jsr __fat_write_block_fat
        bcs @l_exit

        jsr __fat_erase_block_fat

        ldy volumeID + VolumeID::BPB_SecPerClusMask     ; Y = VolumeID::SecPerClus-1 - reamining blocks of the cluster with empty dir entries
        beq @l_exit_ok
@l_erase:
        debug32 "dirnt lba", lba_addr
        jsr __inc_lba_address                           ; next block within cluster
        jsr __fat_write_block_fat
        bcs @l_exit
        dey
        bne @l_erase                                    ; all blocks written?
@l_exit_ok:
        tya ; Y=0 => A=EOK
@l_exit:
        debug "<"
        rts


__fat_erase_block_fat:
              ldy #0                      ; safely, fill the new dir block with 0 to mark end-of-directory
              tya
@l_erase:     sta block_fat+$000, y
              sta block_fat+$100, y
              iny
              bne @l_erase
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
    txa
    tay
    ldx #FD_INDEX_TEMP_FILE
    jsr __fat_clone_fd
    ldy #$ff
@l_next:
    iny
    phy
    lda #<block_data
    ldy #>block_data
    jsr fat_readdir
    ply
    bcc @l_next
@l_exit:
    tya
    debug "f cnt d"
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


;@desc: update direntry given as pointer (A/Y) to FAT32 directory entry structure for file fd (X).
;@name: fat_update_direntry
;@in: X - file descriptor to fd_area of the file
;@in: A/Y - pointer to direntry buffer with updated direntry data of type F32DirEntry
;@out: C - C = 0 on success (A=0), C = 1 and A = <error code> otherwise. C=1/A=EOK if end of directory is reached
fat_update_direntry:
              _is_file_open

              sta __volatile_ptr
              sty __volatile_ptr+1
              debugdumpptr "dirent >", __volatile_ptr

              jsr __fat_read_direntry
              bcs @exit
              debugdirentry
              debugdumpptr "dirent <", __volatile_ptr

              ldy #EBADF  ; prepare if error
              lda fd_area+F32_fd::flags,x
              and #(O_CREAT | O_WRONLY | O_APPEND | O_TRUNC) ; file write access?
              beq @exit_err

              ldy #F32DirEntry::Attr

              lda (__volatile_ptr),y
              and #DIR_Attr_Mask_LongFilename ; long filename?
              cmp #DIR_Attr_Mask_LongFilename
              beq @exit_einval
              and #DIR_Attr_Mask_System|DIR_Attr_Mask_Volume
              bne @exit_einval

              lda (__volatile_ptr),y
              ora (dirptr),y  ; file type changed?
              and #DIR_Attr_Mask_Dir|DIR_Attr_Mask_Archive ; exit EINVAL
              cmp #DIR_Attr_Mask_Dir|DIR_Attr_Mask_Archive
              beq @exit_einval

:             lda (__volatile_ptr),y
              sta (dirptr),y
              dey
              bpl :-
              ; jsr __fat_set_direntry_modify_datetime - timestamp is maintained during fat_close()
              jmp __fat_write_block_data

@exit_einval: ldy #EINVAL
@exit_err:    tya
              sec
@exit:        rts
