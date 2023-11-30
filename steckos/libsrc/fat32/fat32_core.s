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
.export __fat_alloc_fd_x
.export __fat_clone_cd_td
.export __fat_clone_fd
.export __fat_free_fd
.export __fat_is_cln_zero
.export __fat_next_cln
.export __fat_open_path
.export __fat_read_block_data
.export __fat_read_block_fat
.export __fat_set_fd_attr_dirlba
.export __fat_set_fd_start_cluster
.export __calc_lba_addr
.export __inc_lba_address

; in:
;  .X - file descriptor (index into fd_area) of the directory
; out:
;
__fat_find_first_mask:
    SetVector fat_dirname_mask, s_ptr2  ; build fat dir entry mask from user input
    jsr string_fat_mask
    SetVector dirname_mask_matcher, fat_vec_matcher
; in:
;  .X - file descriptor (index into fd_area) of the directory
; out:
;  C=1 if dir entry was found with dirptr pointing to that entry, C=0 otherwise
__fat_find_first:
    lda volumeID+VolumeID::BPB_SecPerClus
    sta blocks
    jsr __calc_lba_addr
ff_l3:
    SetVector block_data, dirptr      ; dirptr to begin of target buffer
    jsr __fat_read_block_data
    bne ff_exit
ff_l4:
    lda (dirptr)
    beq ff_exit                ; first byte of dir entry is $00 (end of directory)
@l5:
    ldy #F32DirEntry::Attr          ; else check if long filename entry
    lda (dirptr),y               ; we are only going to filter those here (or maybe not?)
    cmp #DIR_Attr_Mask_LongFilename
    beq __fat_find_next

    jsr __fat_matcher        ; call matcher strategy
    lda #EOK            ; Z=1 (success) and no error
    bcs ff_end            ; if C=1 we had a match
; in:
;  X - directory fd index into fd_area
; out:
;  C=1 on success (A=0), C=0 and A=error code otherwise
__fat_find_next:
    lda dirptr
    clc
    adc #DIR_Entry_Size
    sta dirptr
    bcc @l6
    inc dirptr+1
@l6:
    .assert <(block_data + sd_blocksize) = $00, error, "block_data isn't aligned on a RAM page boundary"
    lda dirptr+1
    cmp #>(block_data + sd_blocksize)  ; end of block reached?
    bcc ff_l4              ; no, process entry
    dec blocks
    beq @ff_eoc                ; end of cluster reached?
    jsr __inc_lba_address        ; increment lba address to read next block
    bra ff_l3
@ff_eoc:
    ldx #FD_INDEX_TEMP_DIR        ; TODO FIXME dont know if this is a good idea... FD_INDEX_TEMP_DIR was setup above and following the cluster chain is done with the FD_INDEX_TEMP_DIR to not clobber the FD_INDEX_CURRENT_DIR
    jsr __fat_next_cln            ; select next cluster
    bcc __fat_find_first ; ff_exit    ; C=0 go on with next cluster
    ; C=1 on error or EOC, exit
ff_exit:
    clc                  ; we are at the end, nothing found C=0 and return
    debug "ffex"
ff_end:
    rts


; open a path to a file or directory starting from current directory
; in:
;  A/X - pointer to string with the file path
;  Y  - file descriptor of fd_area denoting the start directory. usually FD_INDEX_CURRENT_DIR is used
; out:
;  X - index into fd_area of the opened file. if a directory was opened then X == FD_INDEX_TEMP_DIR
;  C - C=0 on success (A=0), C=1 and A=<error code> otherwise
;  Note: regardless of return value, the dirptr points to the last visited directory entry and the corresponding lba_addr is set to the block where the dir entry resides.
;      furthermore the filenameptr points to the last inspected path fragment of the given input path
__fat_open_path:
    sta s_ptr1
    stx s_ptr1+1           ; save path arg given in a/x

    ldx #FD_INDEX_TEMP_DIR    ; we use the temp dir fd to not clobber the current dir (Y parameter!), maybe we will run into an error
    jsr __fat_clone_fd      ; Y is given as param

    ldy #0              ; trim wildcard at the beginning
@l1:
    lda (s_ptr1), y
    cmp #' '
    bne @l2
    iny
    bne @l1
    bra @l_err_einval    ; overflow, >255 chars
@l2:  ;  starts with '/' ? - we simply cd root first
    cmp #'/'
    bne @l31
    jsr __fat_open_rootdir
    iny
    lda  (s_ptr1), y    ;end of input?
    beq  @l_exit        ;yes, so it was just the '/', exit with A=0
@l31:
    SetVector filename_buf, filenameptr  ; filenameptr to filename_buf
@l3:  ;  parse input path fragments into filename_buf try to change dirs accordingly
    ldx #0
@l_parse_1:
    lda (s_ptr1), y
    beq @l_openfile
    cmp #' '           ;TODO FIXME support file/dir name with spaces? it's beyond 8.3 file support
    beq @l_openfile
    cmp #'/'
    beq @l_open

    sta filename_buf, x
    iny
    inx
    cpx #8+1+3    +1    ; buffer overflow ? - only 8.3 file support yet
    bne @l_parse_1
    bra @l_err_einval
@l_open:
    stz filename_buf, x      ; \0 terminate the current path fragment
    jsr __fat_open_file      ; return with X as offset into fd_area with new allocated file descriptor
    bcs @l_exit
    iny
    bne  @l3          ;overflow - <path argument> exceeds 255 chars
@l_err_einval:
    lda  #EINVAL
@l_exit:
    rts
@l_openfile:
    stz filename_buf, x      ;\0 terminate the current path fragment
    jmp __fat_open_file      ; return with X as offset into fd_area with new allocated file descriptor

__fat_clone_cd_td:
    ldy #FD_INDEX_CURRENT_DIR
    ldx #FD_INDEX_TEMP_DIR
    ; clone source file descriptor with offset y into fd_area to target fd with x
    ; in:
    ;  Y - source file descriptor (offset into fd_area)
    ;  X - target file descriptor (offset into fd_area)
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


; prepare read/write access by fetching the appropriate block from device
; in:
;   .X - file descriptor
; out:
;   C=0 on success, C=1 on error with A=<error code>
.export __fat_prepare_block_access
__fat_prepare_block_access:
    ; TODO FIXME - introduce dirty check or do always read - the block_data may be corrupted if a read from another fd happened in between
    lda fd_area+F32_fd::seek_pos+1,x
    and #$01                              ; mask block start
    ora fd_area+F32_fd::seek_pos+0,x      ; and test whether seek_pos is at the beginning of a block (multiple of $0200) ?
    bne __fat_prepare_access_read         ; no, we can fetch the byte from block_data

    lda fd_area+F32_fd::seek_pos+1,x
    lsr
    and volumeID+VolumeID::BPB_SecPerClusMask ; mask with sec per cluster mask
    debug8 "fp ba >", volumeID+VolumeID::BPB_SecPerClusMask
    bne __fat_prepare_access_read             ; if block is not at the beginning of a cluster just read the block
    jsr __fat_next_cln                        ; otherwise select next cluster
    debug "fp ba <"
    bcs l_exit                                ; exit on error or EOC (C=1)
.export __fat_prepare_access_read
__fat_prepare_access_read:
    jsr __calc_lba_addr
    jsr __fat_read_block_data
    bcs l_exit
l_prepare:
    .assert >block_data & $01 = 0, error, "block_data must be $0200 aligned!"
    lda fd_area+F32_fd::seek_pos+0,x
    sta __volatile_ptr+0
    lda fd_area+F32_fd::seek_pos+1,x
    and #$01
    ora #>block_data
    sta __volatile_ptr+1
    clc
l_exit:
    rts

; update the dir entry position and dir lba_addr of the given file descriptor
; in:
;  .A - file attr
;  .X - file descriptor
; out:
;  updated file descriptor, DirEntryLBA and DirEntryPos setup accordingly
__fat_set_fd_attr_dirlba:
    sta fd_area + F32_fd::Attr, x

    lda lba_addr + 3
    sta fd_area + F32_fd::DirEntryLBA + 3, x
    lda lba_addr + 2
    sta fd_area + F32_fd::DirEntryLBA + 2, x
    lda lba_addr + 1
    sta fd_area + F32_fd::DirEntryLBA + 1, x
    lda lba_addr + 0
    sta fd_area + F32_fd::DirEntryLBA + 0, x

    lda dirptr+1
    and #$01    ; div 32 (DIR_Entry_Size), just bit 0 of high byte must be taken into account. dirptr must be $0200 aligned
    .assert >block_data & $01 = 0, error, "block_data must be $0200 aligned!"
    lsr
    lda dirptr
    ror
    sta fd_area + F32_fd::DirEntryPos, x
    rts

;in:
;  filenameptr - ptr to the filename
;out:
;  X - index into fd_area of the opened file
;  C - C=0 on success (A=0), C=1 and A=<error code> otherwise
__fat_open_file:
    phy

    ldx #FD_INDEX_TEMP_DIR
    jsr __fat_find_first_mask
    bcs @l1
    lda #ENOENT
    sec
    bra @l_exit
@l1:
    ldy #F32DirEntry::Attr
    lda (dirptr),y
    and #DIR_Attr_Mask_Dir    ; directory?
    bne @l2                   ; yes, do not allocate a new fd, use index (X) which is already set to FD_INDEX_TEMP_DIR and just update the fd data
    jsr __fat_alloc_fd        ; no, then regular file and we allocate a new fd for them
    bcs @l_exit
@l2:
    ;save 32 bit cluster number from dir entry
    ldy #F32DirEntry::FstClusHI +1
    lda (dirptr),y
    and #$0f      ; cluster nr must be 0x?ffffff7
    sta fd_area + F32_fd::CurrentCluster + 3, x
    dey
    lda (dirptr),y
    sta fd_area + F32_fd::CurrentCluster + 2, x

    ldy #F32DirEntry::FstClusLO +1
    lda (dirptr),y
    sta fd_area + F32_fd::CurrentCluster + 1, x
    dey
    lda (dirptr),y
    sta fd_area + F32_fd::CurrentCluster + 0, x

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
    jsr __fat_set_fd_attr_dirlba

    jsr __fat_set_fd_start_cluster

    clc
@l_exit:
    ply
    rts


; out:
; .X - with index to fd_area
;  C - C=0 on success (A=0), C=1 and A=<error code> otherwise
__fat_alloc_fd:
    ldx #(2*FD_Entry_Size)                    ; skip 2 entries, they're reserved for current and temp dir
__fat_alloc_fd_x:
    lda fd_area + F32_fd::status,x            ; bit 7 not set means unused, init and return current x as offset
    bpl __fat_init_fd

    txa
    clc
    adc #FD_Entry_Size
    tax

    cpx #(FD_Entry_Size*FD_Entries_Max)
    bne __fat_alloc_fd_x
    lda #EMFILE                         ; Too many open files, no free file descriptor found
    sec
    rts

; out:
;   .X - FD_INDEX_TEMP_DIR offset to fd area
;   C=0 on success
__fat_open_rootdir:
    ldx #FD_INDEX_TEMP_DIR          ; use fd of the temp directory
; in:
;  .X - with index to fd_area
__fat_init_fd:
    ; init fd with all 0 - note: start cluster with root cluster nr 0 and not RootClus - the RootClus offset is compensated within calc_lba_addr (@see Note)
    phx
    lda #FD_FILE_OPEN
    sta fd_area+F32_fd::status,x ; set reserved ($80)
    lda #FD_Entry_Size-1         ; -1 to avoid override ::status
:   stz fd_area,x
    inx
    dec
    bne :-
    plx
    clc
    rts

    ; free file descriptor quietly
    ; in:
    ;  X - offset into fd_area
__fat_free_fd:
    debug "fat_free"
    pha
    stz fd_area + F32_fd::status,x
    pla
    rts

    ; check whether cluster of fd is the root cluster number - 0x00000000 (not VolumeID::RootClus due to lba calc optimization)
    ; in:
    ;  X - file descriptor
    ; out:
    ;  Z=1 if it is the root cluster, Z=0 otherwise
__fat_is_cln_zero:
    lda fd_area+F32_fd::CurrentCluster+3,x        ; check whether start cluster is the root dir cluster nr (0x00000000) as initial set by fat_alloc_fd
    ora fd_area+F32_fd::CurrentCluster+2,x
    ora fd_area+F32_fd::CurrentCluster+1,x
    ora fd_area+F32_fd::CurrentCluster+0,x
    rts

; internal read block
; requires: lba_addr already calculated
__fat_read_block_fat:
    lda #>block_fat
    bra :+
__fat_read_block_data:
    lda #>block_data
:   sta read_blkptr+1
    stz read_blkptr+0
;__fat_read_block:
    phx
    debug32 "fat_rb_lba", lba_addr
;    debug16 "fat_rb_ptr", read_blkptr
    jsr read_block
    dec read_blkptr+1    ; TODO FIXME clarification with TW - read_block increments block ptr highbyte - which is a sideeffect and should be avoided
    plx
    cmp #0          ; TODO FIXME inverse api result C=0 on error, C=1 on success to avoid waste of cylce on result dispatching here and "everywhere"
    bne :+
    clc
    rts
:   sec
    rts

    ; in:
    ;  X - file descriptor
    ; out:
    ;  lba_addr setup with lba address from given file descriptor
    ;  A - with bit 0-7 of lba address
__prepare_calc_lba_addr:
    jsr  __fat_is_cln_zero
    bne  @l_scl
    .repeat 4,i
      lda volumeID + VolumeID::EBPB_RootClus + i
      sta lba_addr + i
    .endrepeat
    rts
@l_scl:
    .repeat 4,i
      lda fd_area + F32_fd::CurrentCluster + i,x
      sta lba_addr + i
    .endrepeat
    rts


; calculate LBA address of first block from cluster number found in file descriptor entry. file descriptor index must be in x
; Note: lba_addr = volumeID+VolumeID::lba_cluster_m2 + (cluster_number * VolumeID_SecPerClus)
; in:
;   .X - file descriptor index
__calc_lba_addr:
    jsr __prepare_calc_lba_addr

    ;SecPerClus is a power of 2 value, therefore cluster << n, where n is the number of bit set in VolumeID::SecPerClus
    ; lba_addr multiple of "sec per cluster"
    ldy volumeID+VolumeID::BPB_SecPerClus
    debug32 "c lba 0", lba_addr
@lm:
    tya
    lsr
    beq @lme   ; until 1 sector/cluster
    tay
    asl lba_addr +0
    rol lba_addr +1
    rol lba_addr +2
    rol lba_addr +3
    debug32 "c lba 1", lba_addr
    bra @lm
@lme:
    ; add volumeID+VolumeID::lba_data and lba_addr => TODO may be an optimization
    add32 volumeID+VolumeID::lba_data, lba_addr, lba_addr

    debug32 "c lba 2", lba_addr

    ; seek_pos / $200 (blocksize) mod "sec per cluster" = block offset within cluster
    lda fd_area+F32_fd::seek_pos+1,x
    lsr                                         ; seek_pos / $200 => is seek_pos high byte >> 1
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
:
;    debug32 "f_lba", lba_addr
    rts

; in:
;  X - file descriptor
; out:
;  vol->LbaFat + (cluster_nr>>7); => div 128 -> 4 (32bit) * 128 cluster numbers per block (512 bytes)
__calc_fat_lba_addr:
    ;instead of shift right 7 times in a loop, we copy over the entire byte (same as >>8) - and simply shift left 1 bit (<<1)
    jsr __prepare_calc_lba_addr
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

; extract next cluster number from the 512 fat block buffer
; unsigned int offs = (clnr << 2 & (BLOCK_SIZE-1));//offset within 512 byte block, cluster nr * 4 (32 Bit) and Bit 8-0 gives the offset
; in:
;  X - file descriptor
; out:
;  C=0 on success, C=1 on failure with A=<error code>, C=1 if EOC reached and A=0 (EOK)
__fat_next_cln:
    lda read_blkptr
    pha
    lda read_blkptr+1
    pha

    jsr __fat_select_next_cln
    debug32 "fnxtcln cl <", fd_area+(2*.sizeof(F32_fd))+F32_fd::CurrentCluster

    ply                      ; use Y to preserve A with return code
    sty read_blkptr+1
    ply
    sty read_blkptr
    rts


__fat_select_next_cln:

    jsr __fat_is_cln_zero
    bne @l_select_next

    jsr @try_reserve
    bcs @l_exit

    bra __fat_set_fd_start_cluster
    ; jmp __fat_update_direntry

@l_select_next:
    lda fd_area+F32_fd::seek_pos+3,x     ; seek pos is 0 - we are at first block and first cluster (StartCluster), we skip select the next clnr
    ora fd_area+F32_fd::seek_pos+2,x
    ora fd_area+F32_fd::seek_pos+1,x
    ora fd_area+F32_fd::seek_pos+0,x
    debug32 "fat sel sp", fd_area+(2*.sizeof(F32_fd))+F32_fd::seek_pos
    beq @l_exit_ok

    jsr __fat_read_cluster_block_and_select      ; read fat block of the current cluster, Y will offset
    debug "fat sel nxt"
    bcc @l_save_cln
    ;cmp #EOK  ; EOK means EOC (C=1/A=0)
    bne @l_exit
@try_reserve:
    lda fd_area + F32_fd::flags,x
    and #(O_CREAT | O_WRONLY | O_APPEND | O_TRUNC) ; write access?
    sec         ; set EOC (C=1) A=0 (EOK) if we take the branch
    debug "fat sel flg"
    beq @l_exit     ; read access and no cluster reserved yet (empty file) - exit with EOC => C=1/A=EOK (0)
    jmp __fat_reserve_cluster

@l_save_cln:
    ;debug32 "fnxtcln cl >", fd_area+(2*.sizeof(F32_fd))+F32_fd::CurrentCluster
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
@l_exit_ok:
    clc
@l_exit:
    rts


__fat_set_fd_start_cluster:
    lda fd_area + F32_fd::CurrentCluster + 3, x
    sta fd_area + F32_fd::StartCluster + 3, x
    lda fd_area + F32_fd::CurrentCluster + 2, x
    sta fd_area + F32_fd::StartCluster + 2, x
    lda fd_area + F32_fd::CurrentCluster + 1, x
    sta fd_area + F32_fd::StartCluster + 1, x
    lda fd_area + F32_fd::CurrentCluster + 0, x
    sta fd_area + F32_fd::StartCluster + 0, x
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
    bcc @l_clnr_fd
    rts
;    jsr __fat_is_cln_zero          ; is root clnr?
 ;   bne @l_clnr_fd
  ;  debug "!!! ZERO !!!"
   ; lda volumeID + VolumeID::EBPB_RootClus+0
    ;bra @l_isroot
@l_clnr_fd:
    lda fd_area+F32_fd::CurrentCluster+0,x  ; offset within block_fat, clnr<<2 (* 4)
    bit #$40                                ; clnr within 2nd page of the 512 byte block ?
    beq @l_clnr
    inc read_blkptr+1            ; yes, set read_blkptr to 2nd page of block_fat
@l_clnr:
    asl                    ; block offset = clnr*4
    asl
@l_isroot:
    tay
; check whether the EOC (end of cluster chain) cluster number is reached
; out:
;  C=1 if clnr is EOC and A=EOK, C=0 otherwise
__fat_is_cluster_eoc:
    phy
    lda (read_blkptr),y
    and #$f8              ; 0x?FFFFFF8 - 0x?FFFFFFF - eoc compatible check
    cmp #$f8
    bcc @l_exit
    iny
    lda (read_blkptr),y
    cmp #<(FAT_EOC>>8)
    bne @l_neoc
    iny
    lda (read_blkptr),y
    cmp #<(FAT_EOC>>16)
    bne @l_neoc
    iny
    lda (read_blkptr),y
    and #<(FAT_EOC>>24)
    cmp #<(FAT_EOC>>24)
    beq @l_exit
@l_neoc:
    clc
@l_exit:
    ply
    lda #EOK ; carry denotes EOC state
    rts

__inc_lba_address:
    _inc32 lba_addr
    rts

__fat_matcher:
    jmp  (fat_vec_matcher)
