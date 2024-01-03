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


.ifdef DEBUG_FAT32_CORE ; debug switch for this module
  debug_enabled=1
.endif

; TODO OPTIMIZATIONS
;   1. __calc_lba_addr - check whether we can skip the cluster_begin adc if we can proof that the cluster_begin is a multiple of sec/cl. if so we can setup the lba_addr as a cluster number, we can safe one addition => a + (b * c) => with a = n * c => n * c + b * c => c * (n + b)
;
.include "zeropage.inc"
.include "common.inc"
.include "fat32.inc"
.include "rtc.inc"
.include "errno.inc"  ; from ca65 api
.include "fcntl.inc"  ; from ca65 api

.include "debug.inc"

; external deps - block layer
.autoimport

.export __fat_read_cluster_block_and_select
.export __fat_find_first
.export __fat_find_first_mask
.export __fat_find_next
.export __fat_alloc_fd
.export __fat_clone_fd
.export __fat_free_fd
.export __fat_is_cln_zero
.export __fat_is_start_cln_zero
.export __fat_next_cln
.export __fat_open_path
.export __fat_open_rootdir
.export __fat_prepare_block_access
.export __fat_prepare_block_access_read
.export __fat_read_block_data
.export __fat_read_block_fat
.export __fat_seek_next_dirent
.export __fat_set_fd_attr_dirlba
.export __fat_set_fd_dirlba
.export __fat_set_fd_start_cluster
.export __fat_set_fd_start_cluster_seek_pos
.export __fat_save_lba_addr
.export __fat_set_root_clus_lba_addr
.export __calc_lba_addr
.export __fat_shift_lba_addr
.export __inc_lba_address


; in:
;  .X - file descriptor (index into fd_area) of the directory
; out:
;   C=0 on success and entry was found, C=1 and A=<error code> otherwise
__fat_find_first_mask:
    SetVector (volumeID+VolumeID::fat_dirname_mask), s_ptr2  ; build fat dir entry mask from user input
    jsr string_fat_mask
    SetVector dirname_mask_matcher, volumeID+VolumeID::fat_vec_matcher

; in:
;  .X - file descriptor (index into fd_area) of the directory to search
; out:
;  C=0 if dir entry was found with dirptr pointing to that entry, C=1 and A=<error code> otherwise or A=EOK if end of directory or EOC
__fat_find_first:
    jsr __fat_set_fd_start_cluster_seek_pos  ; set start cluster to current, reset seek pos

__ff_loop:
    jsr __fat_prepare_block_access_read
    bcs __ff_exit
    sta dirptr
    sty dirptr+1

__ff_match:
    lda (dirptr)
    debug16 "ff match dirptr", dirptr
    beq __ff_exit_enoent        ; first byte of dir entry is $00 (end of directory)

    ldy #F32DirEntry::Attr      ; else check if long filename entry
    lda (dirptr),y              ; we are only going to filter those here (or maybe not?)
    cmp #DIR_Attr_Mask_LongFilename
    beq __fat_find_next

    jsr __fat_matcher       ; call matcher strategy
    bcs __ff_found          ; if C=1 we had a match

; in:
;  X - directory fd index into fd_area
; out:
;  C=0 on success (A=0), C=1 and A=<error code> otherwise
__fat_find_next:
    jsr __fat_seek_next_dirent
    debug32 "ff nxt seek <", fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos
    .assert >block_data & $01 = 0, error, "block_data address must be $0200 aligned!"
    lda dirptr+1 ; block_data start at $?200 ?
    and #$01
    ora dirptr
    beq __ff_loop
    bra __ff_match
__ff_exit_enoent:
    lda #ENOENT
    sec ; nothing found C=1 and return
__ff_exit:
    debug "ff exit <"
    rts
__ff_found:
    clc
    debug "ff fnd <"
    rts


__fat_seek_next_dirent:
    clc
    lda fd_area+F32_fd::SeekPos+0,x
    adc #DIR_Entry_Size
    sta fd_area+F32_fd::SeekPos+0,x
    sta dirptr+0
    lda fd_area+F32_fd::SeekPos+1,x
    adc #0
    sta fd_area+F32_fd::SeekPos+1,x
    and #$01
    ora #>block_data
    sta dirptr+1
    lda fd_area+F32_fd::SeekPos+2,x
    adc #0
    sta fd_area+F32_fd::SeekPos+2,x
    lda fd_area+F32_fd::SeekPos+3,x
    adc #0
    sta fd_area+F32_fd::SeekPos+3,x
    rts


; open a path to a file or directory starting from current directory
; in:
;   A/X - pointer to string with the file path
;   Y  - file descriptor of fd_area denoting the start directory. usually FD_INDEX_CURRENT_DIR is used
; out:
;   X - index into fd_area of the opened file. if a directory was opened then X == FD_INDEX_TEMP_DIR
;   C - C=0 on success (A=0), C=1 and A=<error code> otherwise
;   dirptr - last visited directory entry
;   lba_addr - last visited directory block
;   Note: regardless of return value, the dirptr points to the last visited directory entry and the corresponding lba_addr is set to the block where the dir entry resides.
;      furthermore the filenameptr points to the last inspected path fragment of the given input path
__fat_open_path:
    sta s_ptr1
    stx s_ptr1+1              ; save path arg given in a/x

    ldx #FD_INDEX_TEMP_DIR    ; we use the temp dir fd to not clobber the given directory (.Y), maybe we will run into an error
    jsr __fat_clone_fd        ; Y is given as param

    ldy #0                    ; trim wildcard at the beginning
@l1:
    lda (s_ptr1), y
    cmp #' '+1
    bcs @l2
    iny
    bne @l1
    bra @l_err_einval    ; overflow, >255 chars
@l2:
    SetVector filename_buf, filenameptr  ; filenameptr to filename_buf
@l3:  ;  parse input path fragments into filename_buf try to change dirs accordingly
    ldx #0
@l_parse_1:
    lda (s_ptr1), y
    beq @l_openfile
    cmp #' '           ;TODO FIXME support file/dir name with spaces? it's beyond 8.3 file support
    beq @l_openfile
    cmp #'/'
    beq @l_open_dir

    sta filename_buf, x
    iny
    inx
    cpx #8+1+3 + 1          ; buffer overflow ? - only 8.3 file support yet
    bne @l_parse_1
    bra @l_err_einval
@l_open_dir:
    cpx #0                  ; empty string, we came from '/' match
    bne :+
    ldx #FD_INDEX_TEMP_DIR  ; use fd of the temp directory
    jsr __fat_open_rootdir
    bcc @l_next

:   stz filename_buf, x     ; \0 terminate the current path fragment
    jsr __fat_open_file     ; return with X as offset into fd_area with new allocated file descriptor
    bcs @l_exit
@l_next:
    iny
    bne @l3                 ;overflow - <path argument> exceeds 255 chars
@l_err_einval:
    lda #EINVAL
    sec
@l_exit:
    rts
@l_openfile:
    cpx #0                  ; empty string, then we're done
    bne :+
    clc
    rts
:   stz filename_buf, x      ;\0 terminate the current path fragment

;in:
;  filenameptr - ptr to the filename
;out:
;  X - index into fd_area of the opened file
;  C - C=0 on success (A=0), C=1 and A=<error code> otherwise
__fat_open_file:
    phy
    ldx #FD_INDEX_TEMP_DIR
    jsr __fat_find_first_mask
    bcs @l_exit

    ldy #F32DirEntry::Attr
    lda (dirptr),y
    and #DIR_Attr_Mask_Dir    ; directory?
    bne :+                    ; yes, do not allocate a new fd, use index (X) which is already set to FD_INDEX_TEMP_DIR and just update the fd data
    jsr __fat_alloc_fd        ; no, then regular file and we allocate a new fd for them
    bcs @l_exit
    ;save 32 bit cluster number from dir entry
:   ldy #F32DirEntry::FstClusHI +1
    lda (dirptr),y
    and #$0f      ; cluster nr must be 0x?ffffff7
    sta fd_area + F32_fd::StartCluster + 3, x
    dey
    lda (dirptr),y
    sta fd_area + F32_fd::StartCluster + 2, x

    ldy #F32DirEntry::FstClusLO +1
    lda (dirptr),y
    sta fd_area + F32_fd::StartCluster + 1, x
    dey
    lda (dirptr),y
    sta fd_area + F32_fd::StartCluster + 0, x

    ldy #F32DirEntry::FileSize + 3
    lda (dirptr),y
    sta fd_area + F32_fd::FileSize + 3, x
    dey
    lda (dirptr),y
    sta fd_area + F32_fd::FileSize + 2, x
    dey
    lda (dirptr),y
    sta fd_area + F32_fd::FileSize + 1, x
    dey
    lda (dirptr),y
    sta fd_area + F32_fd::FileSize + 0, x

    ldy #F32DirEntry::Attr
    lda (dirptr),y
    sta fd_area + F32_fd::Attr, x

    jsr __fat_set_fd_dirlba

    jsr __fat_set_fd_start_cluster_seek_pos
    ; TODO use jsr __fat_set_fd_start_cluster if alloc_fd is used also for directories
@l_exit:
    ply
    rts

; clone source file descriptor with offset y into fd_area to target fd with x
; in:
;   Y - source file descriptor (offset into fd_area)
;   X - target file descriptor (offset into fd_area)
__fat_clone_fd:
    phx
    lda #FD_Entry_Size
    sta s_tmp1
@l1:
    lda fd_area, y
    sta fd_area, x
    inx
    iny
    dec s_tmp1
    bne @l1
    plx
    rts


__fat_prepare_block_access_read:
    clc
; prepare read/write access by fetching the appropriate block from device
; in:
;   X - file descriptor
;   C - C=0 read access, C=1 write access
; out:
;   C=0 on success, C=1 on error with A=<error code>
;   A/Y pointer to data block for read/write access
__fat_prepare_block_access:

    bit fd_area+F32_fd::status,x      ; dirty?
    debug "fp ba >"
    bvs @l_seek

    php ; save carry given as parameter

    lda fd_area+F32_fd::SeekPos+1,x
    lsr
    debug32 "fp ba 0 >", fd_area+(1*FD_Entry_Size)+F32_fd::SeekPos
    bcs @l_restore_read                       ; not at block start (multiple of $02??)
    and volumeID+VolumeID::BPB_SecPerClusMask ; otherwise mask with sec per cluster mask
    ora fd_area+F32_fd::SeekPos+0,x           ; and test whether SeekPos is at the beginning of a block (multiple of $??00) ?
    debug "fp ba 1 >"
    bne @l_restore_read                       ; not at the beginning of a cluster, just read the block

    plp                                       ; restore carry
    debug "fp ba 2 >"
    jsr __fat_next_cln                        ; select next cluster, carry denotes read/write access
    debug "fp ba 2 <"
    bcc @l_read                               ; exit on error or EOC (C=1)
    rts
@l_restore_read:
    pla
@l_read:
    jsr __calc_lba_addr
    jsr __fat_read_block_data
    bcs @l_exit
    .assert >block_data & $01 = 0, error, "block_data must be $0200 aligned!"
    lda fd_area+F32_fd::SeekPos+1,x
    and #$01
    ora #>block_data
    tay
    lda fd_area+F32_fd::SeekPos+0,x
@l_exit:
    rts
@l_seek:
    jsr __fat_fseek_cluster                   ; yes, then we have to seek first to ensure correct cluster is selected, Carry is given as param for read/write access
    bcc @l_read
    rts


; update the dir entry position and dir lba_addr of the given file descriptor
; in:
;  .A - file attr
;  .X - file descriptor
; out:
;  updated file descriptor, DirEntryLBA and DirEntryPos setup accordingly
__fat_set_fd_attr_dirlba:
    sta fd_area + F32_fd::Attr, x
__fat_set_fd_dirlba:
    lda lba_addr + 3
    sta fd_area + F32_fd::DirEntryLBA + 3, x
    lda lba_addr + 2
    sta fd_area + F32_fd::DirEntryLBA + 2, x
    lda lba_addr + 1
    sta fd_area + F32_fd::DirEntryLBA + 1, x
    lda lba_addr + 0
    sta fd_area + F32_fd::DirEntryLBA + 0, x

    lda dirptr+1
    .assert >block_data & $01 = 0, error, "block_data must be $0200 aligned!"
    lsr         ; div 2 (DIR_Entry_Size), just bit 0 of high byte must be taken into account. dirptr must be $0200 aligned
    lda dirptr
    ror
    sta fd_area + F32_fd::DirEntryPos, x
    rts


; out:
; .X - with index to fd_area
;  C - C=0 on success (A=0), C=1 and A=<error code> otherwise
__fat_alloc_fd:
    ldx #(2*FD_Entry_Size)                    ; skip 2 entries, they're reserved for current and temp dir
:   lda fd_area + F32_fd::status,x            ; bit 7 not set means unused, init and return current x as offset
    bpl __fat_init_fd

    txa
    clc
    adc #FD_Entry_Size
    tax

    cpx #(FD_Entry_Size*FD_Entries_Max)
    bne :-
    lda #EMFILE                         ; Too many open files, no free file descriptor found
    rts

; in:
;   .X - fd for open the root directory
; out:
;   C=0 on success
__fat_open_rootdir:
    jsr __fat_init_fd
    lda #DIR_Attr_Mask_Dir
    sta fd_area + F32_fd::Attr,x
    rts

; in:
;  .X - with index to fd_area
__fat_init_fd:
    ; init fd with all 0 - Note: start cluster with root cluster nr 0 and not RootClus - the RootClus offset is compensated within calc_lba_addr (@see Note)
    phx
    lda #FD_Entry_Size
:   stz fd_area,x
    inx
    dec
    bne :-
    plx
    lda #FD_STATUS_FILE_OPEN | FD_STATUS_DIRTY
    sta fd_area + F32_fd::status,x ; set reserved (7) and dirty (6)
    clc
    rts


; free file descriptor quietly
; in:
;  X - offset into fd_area
__fat_free_fd:
    debug "fat_free <"
    stz fd_area + F32_fd::status,x
    rts

; check whether cluster of fd is the root cluster number - 0x00000000 (not VolumeID::RootClus due to lba calc optimization)
; in:
;  X - file descriptor
; out:
;  Z=1 if it is the root cluster, Z=0 otherwise
__fat_is_cln_zero:
    lda fd_area+F32_fd::CurrentCluster+3,x      ; check whether current cluster is the root dir cluster nr (0x00000000) as initial set by fat_alloc_fd
    ora fd_area+F32_fd::CurrentCluster+2,x
    ora fd_area+F32_fd::CurrentCluster+1,x
    ora fd_area+F32_fd::CurrentCluster+0,x
    rts

__fat_is_start_cln_zero:
    lda fd_area+F32_fd::StartCluster+3,x        ; check whether start cluster is the root dir cluster nr (0x00000000) as initial set by fat_alloc_fd
    ora fd_area+F32_fd::StartCluster+2,x
    ora fd_area+F32_fd::StartCluster+1,x
    ora fd_area+F32_fd::StartCluster+0,x
    rts

; internal read block
; requires: lba_addr already calculated
; out:
;   C=0 on success, C=1 on error
__fat_read_block_fat:
    lda #>block_fat
    bra :+
__fat_read_block_data:
    lda #>block_data
:   sta read_blkptr+1
    stz read_blkptr+0

    debug32 "fat_rb lba", lba_addr
    debug32 "fat_rb lba last", volumeID+VolumeID::lba_addr_last
    cmp32 volumeID+VolumeID::lba_addr_last, lba_addr, @l_read
    clc
    rts

@l_read:
    phx
;    debug16 "fat_rb_ptr", read_blkptr
    jsr read_block
    dec read_blkptr+1    ; TODO FIXME clarification with TW - read_block increments block ptr highbyte - which is a sideeffect and should be avoided
    plx
    cmp #EOK
    beq __fat_save_lba_addr
    sec
    rts

__fat_save_lba_addr:
    lda lba_addr+0
    sta volumeID+VolumeID::lba_addr_last+0
    lda lba_addr+1
    sta volumeID+VolumeID::lba_addr_last+1
    lda lba_addr+2
    sta volumeID+VolumeID::lba_addr_last+2
    lda lba_addr+3
    sta volumeID+VolumeID::lba_addr_last+3
    clc ; success
    rts

    ; in:
    ;  X - file descriptor
    ; out:
    ;  lba_addr setup with lba address from given file descriptor
    ;  A - with bit 0-7 of lba address
__prepare_calc_lba_addr:
    jsr  __fat_is_cln_zero
    bne  l_scl
__fat_set_root_clus_lba_addr:
    .repeat 4,i
      lda volumeID + VolumeID::BPB_RootClus + i
      sta lba_addr + i
    .endrepeat
    rts
l_scl:
    .repeat 4,i
      lda fd_area + F32_fd::CurrentCluster + i,x
      sta lba_addr + i
    .endrepeat
    rts


__fat_shift_lba_addr:
    ;SecPerClus is a power of 2 value, therefore cluster << n, where n is the number of bit set in VolumeID::SecPerClus
    ; lba_addr multiple of "sec per cluster"
    ldy volumeID+VolumeID::BPB_SecPerClusCount
    debug32 "c lba 0", lba_addr
    beq @l_exit   ; count 0 (1 sector/cluster), no shift necessary

:   asl lba_addr +0
    rol lba_addr +1
    rol lba_addr +2
    rol lba_addr +3
    debug32 "c lba 1", lba_addr
    dey
    bne :-
@l_exit:
    rts


; calculate LBA address of first block from cluster number found in file descriptor entry. file descriptor index must be in x
; Note: lba_addr = volumeID+VolumeID::lba_cluster_m2 + (cluster_number * VolumeID::SecPerClus)
; in:
;   .X - file descriptor index
__calc_lba_addr:

    jsr __prepare_calc_lba_addr

    jsr __fat_shift_lba_addr

    add32 volumeID+VolumeID::lba_data, lba_addr, lba_addr

    debug32 "c lba 2", lba_addr

    ; SeekPos / $200 (blocksize) mod "sec per cluster" = block offset within cluster
    lda fd_area+F32_fd::SeekPos+1,x
    lsr                                         ; SeekPos / $200 => is SeekPos high byte >> 1
    and volumeID+VolumeID::BPB_SecPerClusMask   ; mod "sec per cluster" => AND ("sec per cluster"-1)
    clc
    adc lba_addr+0                              ; add to lba_addr
    sta lba_addr+0
    bcc :+
    .repeat 3, i
      lda lba_addr+1+i
      adc #0
      sta lba_addr+1+i
    .endrepeat
:   debug32 "f_lba", lba_addr
    rts

; in:
;  X - file descriptor
; out:
;  vol->LbaFat + (cluster_nr>>7); => div 128 -> 4 (32bit) * 128 cluster numbers per block (512 bytes)
__calc_fat_lba_addr:
    jsr __prepare_calc_lba_addr
    ;instead of shift right 7 times in a loop, we copy over the entire byte (same as >>8) - and simply shift left 1 bit (<<1)
    lda lba_addr+0
    asl
    lda lba_addr+1
    rol
    sta lba_addr+0
    lda lba_addr+2
    rol
    sta lba_addr+1
    lda lba_addr+3
    rol
    sta lba_addr+2
    lda #0                  ;$0f (see EOC) highest value for cluster MSB, due to >>7 the $0f from the MSB is erased completely
    rol
    sta lba_addr+3

    ; add volumeID+VolumeID::lba_fat and lba_addr
    add32 volumeID+VolumeID::lba_fat, lba_addr, lba_addr

    debug32 "fat_lba", lba_addr
    rts

; extract next cluster number from the 512 fat block buffer or reserve a new one
; unsigned int offs = (clnr << 2 & (BLOCK_SIZE-1));//offset within 512 byte block, cluster nr * 4 (32 Bit) and Bit 8-0 gives the offset
; in:
;   X - file descriptor
;   C - C=0 read access, C=1 write access means extend cluster if EOC
; out:
;  C=0 on success, C=1 on failure with A=<error code>, C=1 if EOC reached and A=0 (EOK)
__fat_next_cln:

    bcc @l_select_next_cln  ; read access, just try to select

@l_write:
    jsr @l_select_next_cln
    bcc @l_exit
   ;cmp #EOK   ; EOK means EOC (C=1/A=0)
    bne @l_exit ; other error, then exit
    ; A=0 here
    debug "f n cl w >"
    jsr __fat_reserve_cluster ; otherwise reserve a cluster
    bcs @l_exit

    jsr __fat_read_cluster_block_and_select      ; read fat block of the current cluster, Y will offset
  ;  bcc @l_exit
    bne @l_exit ; other error, then exit
    debug "f n cl w"
    lda volumeID + VolumeID::LastClus + 0 ;
    sta (read_blkptr), y
    iny
    lda volumeID + VolumeID::LastClus + 1
    sta (read_blkptr), y
    iny
    lda volumeID + VolumeID::LastClus + 2
    sta (read_blkptr), y
    iny
    lda volumeID + VolumeID::LastClus + 3
    sta (read_blkptr), y

    jsr __fat_write_fat_blocks    ; write fat block with updated chain
    bcs @l_exit

@l_select_next_cln:
    jsr __fat_read_cluster_block_and_select      ; read fat block of the current cluster, Y will offset
    debug16 "sel nxt (eoc)", read_blkptr
    bcs @l_exit

    lda (read_blkptr), y
    sta fd_area + F32_fd::CurrentCluster+0, x
    iny
    lda (read_blkptr), y
    sta fd_area + F32_fd::CurrentCluster+1, x
    iny
    lda (read_blkptr), y
    sta fd_area + F32_fd::CurrentCluster+2, x
    iny
    lda (read_blkptr), y
    sta fd_area + F32_fd::CurrentCluster+3, x
@l_exit:
    debug32 "fat next cln <", fd_area+(FD_Entry_Size*2)+F32_fd::CurrentCluster
    rts


__fat_set_fd_start_cluster_seek_pos:
    stz fd_area+F32_fd::SeekPos+3,x
    stz fd_area+F32_fd::SeekPos+2,x
    stz fd_area+F32_fd::SeekPos+1,x
    stz fd_area+F32_fd::SeekPos+0,x

    lda fd_area+F32_fd::status,x
    ora #FD_STATUS_DIRTY
    sta fd_area+F32_fd::status,x

__fat_set_fd_start_cluster:
    lda fd_area+F32_fd::StartCluster+3, x
    sta fd_area+F32_fd::CurrentCluster+3, x
    lda fd_area+F32_fd::StartCluster+2, x
    sta fd_area+F32_fd::CurrentCluster+2, x
    lda fd_area+F32_fd::StartCluster+1, x
    sta fd_area+F32_fd::CurrentCluster+1, x
    lda fd_area+F32_fd::StartCluster+0, x
    sta fd_area+F32_fd::CurrentCluster+0, x
    rts

; in:
;  X - file descriptor
; out:
;  read_blkptr - setup to block_fat either low/high page
;  Y - offset within block_fat to clnr
;  C=0 on success, C=1 if the cluster number is the EOC and A=EOK or C=1 and A=<error code> otherwise
__fat_read_cluster_block_and_select:
    jsr __calc_fat_lba_addr
    jsr __fat_read_block_fat
    bcs @l_exit
    jsr __fat_is_cln_zero          ; is root clnr? - which is all zero due to offset compensation, therefore we have to select the root cluster explicitly
    bne @l_clnr_fd
    lda volumeID+VolumeID::BPB_RootClus+0
    bra @l_clnr_page
@l_clnr_fd:
    lda fd_area+F32_fd::CurrentCluster+0,x  ; offset within block_fat, clnr<<2 (* 4)
@l_clnr_page:
    bit #$40                                ; clnr within 2nd page of the 512 byte block ?
    beq @l_clnr
    inc read_blkptr+1            ; yes, set read_blkptr to 2nd page of block_fat
@l_clnr:
    asl                    ; block offset = clnr*4
    asl
    tay
; check whether the EOC (end of cluster chain) cluster number is reached
; out:
;  C=1 if clnr is EOC and A=EOK, C=0 otherwise
@l_is_eoc:
    phy
    lda (read_blkptr),y
    and #$f8              ; 0x?FFFFFF8 - 0x?FFFFFFF - eoc compatible check
    cmp #$f8
    bcc @l_not_eoc
    iny
    lda (read_blkptr),y
    cmp #<(FAT_EOC>>8)
    bne @l_not_eoc
    iny
    lda (read_blkptr),y
    cmp #<(FAT_EOC>>16)
    bne @l_not_eoc
    iny
    lda (read_blkptr),y
    and #<(FAT_EOC>>24)
    cmp #<(FAT_EOC>>24)
    beq @l_eoc
@l_not_eoc:
    clc
@l_eoc:
    ply
    lda #EOK ; carry denotes EOC state
    debug "is_eoc <"
@l_exit:
    rts

__inc_lba_address:
    _inc32 lba_addr
    rts

__fat_matcher:
    jmp  (volumeID+VolumeID::fat_vec_matcher)
