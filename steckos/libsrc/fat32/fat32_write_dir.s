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

.autoimport

; delete a directory entry denoted by given path in A/X
;in:
;  A/X - pointer to the directory path
; out:
;  C=0 on success, C=1 and A=error code otherwise
fat_rmdir:
    jsr __fat_opendir_cwd
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
    debug "rmdir"
    rts

; in:
;   A/X - pointer to the directory name
; out:
;  C=0 on success (A=0), C=1 on error and A=error code otherwise
fat_mkdir:
    jsr __fat_opendir_cwd
    bcc @l_exit_eexist                ; open success, dir exists already
    cmp #ENOENT                       ; we expect 'no such file or directory' error, otherwise a file/dir with same name already exists
    bne @l_exit_err                   ; exit on other error

    debug16 "mkdir 1", dirptr
    copypointer dirptr, s_ptr2
    jsr string_fat_name               ; build fat name upon input string (filenameptr) and store them directly to current dirptr!
    bne @l_exit_err
    jsr __fat_alloc_fd                ; alloc a fd for the new directory - try to allocate a new fd here, right before any fat writes, cause they may fail
    bcs @l_exit                       ; and we want to avoid an error in between the different block writes
    lda #DIR_Attr_Mask_Dir            ; set type directory
    jsr __fat_set_fd_attr_dirlba      ; update dir lba addr and dir entry number within fd from lba_addr and dir_ptr which where setup during __fat_opendir_cwd from above
    jsr __fat_reserve_cluster         ; try to find and reserve next free cluster and store them in fd_area at fd (X)
    bcs @l_exit_close                 ; C=1 - fail, exit but close fd
    jsr __fat_set_fd_start_cluster    ; set start cluster to fd
    jsr __fat_set_lba_from_fd_dirlba  ; setup lba_addr from fd
    jsr __fat_write_dir_entry         ; create dir entry at current dirptr
    bcs @l_exit_close
    jsr __fat_read_direntry
    bcs @l_exit_close
    jsr __fat_write_newdir_entry      ; write the data of the newly created directory with prepared data from dirptr
@l_exit_close:
    jmp __fat_free_fd                 ; A and C are preserved
@l_exit_eexist:
    lda #EEXIST                       ; exists already
@l_exit_err:
    sec
@l_exit:
    debug "fat_mkdir"
    rts

    ; in:
    ;  X - file descriptor of directory
    ; out:
    ;  C=0 if directory is empty or contains <=2 entries ("." and ".."), C=1 otherwise
__fat_dir_isempty:
    phx
    jsr __fat_count_direntries
    cmp #3              ; >= 3 dir entries, must be more then only the "." and ".."
    bcc @l_exit
    lda #ENOTEMPTY
@l_exit:
    plx
    rts

__fat_count_direntries:
    stz s_tmp3
    SetVector @l_all, filenameptr
    jsr __fat_find_first_mask    ; find within dir given in X
    bcc @l_exit
@l_next:
    lda (dirptr)
    cmp #DIR_Entry_Deleted
    beq @l_find_next
    inc  s_tmp3
@l_find_next:
    jsr __fat_find_next
    bcs  @l_next
@l_exit:
    lda s_tmp3
    debug "f_cnt_d"
    rts
@l_all:
    .asciiz "*.*"


; create the "." and ".." entry of the new directory
; in:
;   .X - the file descriptor into fd_area of the the new dir entry
;   dirptr - set to dir entry within block_data buffer
; out:
;   C=0 on success, C=1 otherwise and A=error code
__fat_write_newdir_entry:

    jsr __fat_erase_block_fat

    ldy #F32DirEntry::Attr                                         ; copy data of the dir entry (dirptr) created beforehand to easily take over create time, mod time etc., cluster nr
@l_dir_cp:
    lda (dirptr), y
    debug16 "f wr nd", dirptr
    sta block_fat+0*.sizeof(F32DirEntry), y                        ; 1st dir entry
    sta block_fat+1*.sizeof(F32DirEntry), y                        ; 2nd dir entry
    iny
    cpy #.sizeof(F32DirEntry)
    bne @l_dir_cp

    ldy #.sizeof(F32DirEntry::Name) + .sizeof(F32DirEntry::Ext) -1  ; erase name and build the "." and ".." entries with space
    lda #$20
@l_clr_name:
    sta block_fat+0*.sizeof(F32DirEntry), y                        ; 1st dir entry
    sta block_fat+1*.sizeof(F32DirEntry), y                        ; 2nd dir entry
    dey
    bpl @l_clr_name
    lda #'.'
    sta block_fat+0*.sizeof(F32DirEntry)+F32DirEntry::Name+0        ; 1st entry "."
    sta block_fat+1*.sizeof(F32DirEntry)+F32DirEntry::Name+0        ; 2nd entry ".."
    sta block_fat+1*.sizeof(F32DirEntry)+F32DirEntry::Name+1

    ldy #FD_INDEX_TEMP_DIR                                          ; due to fat_opendir/fat_open within fat_mkdir the fd of temp dir (FD_INDEX_TEMP_DIR) represents the last visited directory which must be the parent of this one ("..") - FTW!
    debug32 "cd_cln", fd_area + FD_INDEX_TEMP_DIR + F32_fd::CurrentCluster  ; we can simpyl take over the cluster from parent to write the ".."
    debug32 "cd_sln", fd_area + FD_INDEX_TEMP_DIR + F32_fd::StartCluster  ; we can simpyl take over the cluster from parent to write the ".."
    lda fd_area+F32_fd::CurrentCluster+0,y
    sta block_fat+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusLO+0
    lda fd_area+F32_fd::CurrentCluster+1,y
    sta block_fat+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusLO+1
    lda fd_area+F32_fd::CurrentCluster+2,y
    sta block_fat+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusHI+0
    lda fd_area+F32_fd::CurrentCluster+3,y
    sta block_fat+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusHI+1

    jsr __calc_lba_addr
    jsr __fat_write_block_fat
    bcs @l_exit

    jsr __fat_erase_block_fat
    ldy volumeID+ VolumeID:: BPB_SecPerClusMask     ; Y = VolumeID::SecPerClus-1 - reamining blocks of the cluster with empty dir entries
    debug32 "mkdr er", lba_addr
    beq @l_exit
@l_erase:
    jsr __inc_lba_address                           ; next block within cluster
    jsr __fat_write_block_fat
    bcs @l_exit
    dey
    bne @l_erase                                    ; all blocks written?

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
