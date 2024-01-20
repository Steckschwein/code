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


.ifdef DEBUG_FAT32_WRITE ; debug switch for this module
  debug_enabled=1
.endif

.include "zeropage.inc"
.include "common.inc"
.include "fat32.inc"
.include "rtc.inc"
.include "errno.inc"  ; from ca65 api
.include "fcntl.inc"  ; from ca65 api
.include "debug.inc"

.export fat_write_byte
.export fat_unlink

.export __fat_reserve_cluster
.export __fat_reserve_start_cluster
.export __fat_add_direntry
.export __fat_update_direntry
.export __fat_fopen_touch
.export __fat_write_fat_blocks
.export __fat_write_block_data
.export __fat_write_block_fat
.export __fat_set_lba_from_fd_dirlba
.export __fat_unlink
.autoimport

; in:
;  A - byte to write
;  X - offset into fd_area
; out:
;  C=0 on success, C=1 on error and A=<error code>
fat_write_byte:

    _is_file_open   ; otherwise rts C=1 and A=#EINVAL
    _is_file_dir    ; otherwise rts C=1 and A=#EISDIR

    phy
    pha

    sec ; write access
    jsr __fat_prepare_block_access

    sta __volatile_ptr                  ; A/Y pointer to data block
    sty __volatile_ptr+1

    pla                                 ; get back byte to write
    bcs @l_exit                         ; C=1 prepare above was an error, exit

    debug "f_wr byte"
    sta (__volatile_ptr)

    _inc32_x fd_area+F32_fd::SeekPos    ; seek+1

    jsr __fat_set_fd_filesize
    jsr __fat_write_block_data_buffered ; write block buffered
@l_exit:
    ply
    rts


__fat_set_fd_filesize:
    debug32 "fd fsize >", fd_area+(2*FD_Entry_Size)+F32_fd::FileSize
    lda fd_area+F32_fd::FileSize+3,x
    cmp fd_area+F32_fd::SeekPos+3,x
    bcc @l_set3 ; less then
    bne @l_exit ; greater then, otherwise equal
    lda fd_area+F32_fd::FileSize+2,x
    cmp fd_area+F32_fd::SeekPos+2,x
    bcc @l_set2
    bne @l_exit
    lda fd_area+F32_fd::FileSize+1,x
    cmp fd_area+F32_fd::SeekPos+1,x
    bcc @l_set1
    bne @l_exit
    lda fd_area+F32_fd::FileSize+0,x
    cmp fd_area+F32_fd::SeekPos+0,x
    bcc @l_set0
    bne @l_exit
@l_set3:
    lda fd_area+F32_fd::SeekPos+3,x
    sta fd_area+F32_fd::FileSize+3,x
@l_set2:
    lda fd_area+F32_fd::SeekPos+2,x
    sta fd_area+F32_fd::FileSize+2,x
@l_set1:
    lda fd_area+F32_fd::SeekPos+1,x
    sta fd_area+F32_fd::FileSize+1,x
@l_set0:
    lda fd_area+F32_fd::SeekPos+0,x
    sta fd_area+F32_fd::FileSize+0,x
@l_exit:
    debug32 "fd fsize <", fd_area+(2*FD_Entry_Size)+F32_fd::FileSize
    rts



; write new dir entry to dirptr and set new end of directory marker
; in:
;   X - file descriptor of the new dir entry within fd_area
;   Y - file open flags - see fat_fopen
;   C - C=1 if called from EOC
;   dirptr to directory entry
; out:
;  C=0 on success, C=1 on error and A=<error code>
__fat_fopen_touch:

    debug "fop touch >"
    bcc :+
    phy
    jsr __fat_prepare_block_access    ; write access - if eoc we have to prepare block access first to write new dir entry
    ply
    bcs @l_exit

:   jsr __fat_alloc_fd           ; allocate a dedicated fd for the new directory
    bcs @l_exit

    jsr __fat_set_fd_dirlba      ; save the dir entry lba and offset to new allocated fd

    tya
    sta fd_area+F32_fd::flags,x
    lda #DIR_Attr_Mask_Archive   ; create as regular file with archive bit set
    sta fd_area+F32_fd::Attr,x
    jsr __fat_add_direntry       ; create dir entry at current dirptr
@l_exit:
    debug "fop touch <"
    rts

; create a new dir entry at given dirptr and set a new end of directory marker
; in:
;   A - dir entry type - one of DIR_Attr_Mask_Dir, DIR_Attr_Mask_Archive ...
;   X - file descriptor of the new dir entry within fd_area
;   dirptr - set to current dir entry within block_data
; out:
;   C=0 on success, C=1 on error and A=<error code>
__fat_add_direntry:

    ldy #F32DirEntry::Attr              ; store type attribute
    sta (dirptr), y

    ldy #.sizeof(F32DirEntry::Name)+.sizeof(F32DirEntry::Ext)-1
:   lda volumeID+VolumeID::fat_filename,y
    sta (dirptr),y
    dey
    bpl :-

    debugdumpptr "dirent dptr", dirptr
    debugdump "dirent nm", volumeID+VolumeID::fat_filename

    jsr __fat_set_lba_from_fd_dirlba
    jsr __fat_set_direntry_create_datetime
    bra __fat_update_direntry_write

; out:
;   C=0 on success, C=1 and A=<error> otherwise
__fat_update_direntry:
    jsr __fat_read_direntry                  ; read dir entry, dirptr is set accordingly
    bcc :+
    rts

:   jsr __fat_set_direntry_modify_datetime  ; set modification time and date

__fat_update_direntry_write:
    ; copy cluster number from file descriptor to direntry given as dirptr
    ldy #F32DirEntry::FstClusHI+1
    lda fd_area+F32_fd::StartCluster+3 , x
    sta (dirptr),y
    dey
    lda fd_area+F32_fd::StartCluster+2 , x
    sta (dirptr),y

    ldy #F32DirEntry::FstClusLO+1
    lda fd_area+F32_fd::StartCluster+1 , x
    sta (dirptr),y
    dey
    lda fd_area+F32_fd::StartCluster+0 , x
    sta (dirptr),y

    jsr __fat_set_direntry_filesize         ; set filesize of directory entry via dirptr

    jmp __fat_write_block_data              ; lba_addr is already set from read, see above

; read the block with the directory entry of the given file descriptor, dirptr is adjusted accordingly
; in:
;   X - file descriptor of the file the directory entry should be read
; out:
;   C - C=0 on success (A=0), C=1 and A=<error code> otherwise
;   dirptr pointing to the corresponding directory entry of type F32DirEntry
__fat_read_direntry:
    jsr __fat_set_lba_from_fd_dirlba      ; setup lba address from fd
    jsr __fat_read_block_data             ; and read the block with the dir entry
    bcs @l_exit

    lda fd_area+F32_fd::DirEntryPos, x    ; setup dirptr
    asl
    sta dirptr
    lda #>block_data
    adc #0 ;+Carry
    sta dirptr+1
@l_exit:
    rts

; in:
;  X - file descriptor
; out:
;  lba_addr setup with direntry lba
__fat_set_lba_from_fd_dirlba:
    lda fd_area+F32_fd::DirEntryLBA+3 , x        ; set lba addr of dir entry...
    sta lba_addr+3
    lda fd_area+F32_fd::DirEntryLBA+2 , x
    sta lba_addr+2
    lda fd_area+F32_fd::DirEntryLBA+1 , x
    sta lba_addr+1
    lda fd_area+F32_fd::DirEntryLBA+0 , x
    sta lba_addr+0
    debug32 "fat set dir lba <", lba_addr
    rts

; write new timestamp to direntry entry given as dirptr
; in:
;    dirptr
__fat_set_direntry_modify_datetime:
    phx
    jsr rtc_systime_update                  ; update systime struct
    ;TODO FIXME rtc may be #EBUSY
    jsr __fat_rtc_time

    ldy #F32DirEntry::WrtTime
    sta (dirptr), y
    txa
    iny ; #F32DirEntry::WrtTime+1
    sta (dirptr), y

    jsr __fat_rtc_date
    ldy #F32DirEntry::WrtDate+0
    sta (dirptr), y
    ldy #F32DirEntry::LstModDate+0
    sta (dirptr), y
    txa
    ldy #F32DirEntry::WrtDate+1
    sta (dirptr), y
    ldy #F32DirEntry::LstModDate+1
    sta (dirptr), y
    plx
    rts

__fat_set_direntry_create_datetime:
    jsr __fat_set_direntry_modify_datetime
    lda #0
    ldy #F32DirEntry::Reserved          ; unused
    sta (dirptr), y
    ldy #F32DirEntry::CrtTimeMillis
    sta (dirptr), y                     ; ms to 0, ms not supported by rtc

    ldy #F32DirEntry::WrtTime           ; creation date/time copy over from modified date/time
    lda (dirptr),y
    ldy #F32DirEntry::CrtTime
    sta (dirptr),y
    ldy #F32DirEntry::WrtTime+1
    lda (dirptr),y
    ldy #F32DirEntry::CrtTime+1
    sta (dirptr),y

    ldy #F32DirEntry::WrtDate
    lda (dirptr),y
    ldy #F32DirEntry::CrtDate
    sta (dirptr),y
    ldy #F32DirEntry::WrtDate+1
    lda (dirptr),y
    ldy #F32DirEntry::CrtDate+1
    sta (dirptr),y
    rts

__fat_set_direntry_filesize:
    lda fd_area+F32_fd::FileSize+3,x
    ldy #F32DirEntry::FileSize+3
    sta (dirptr),y
    lda fd_area+F32_fd::FileSize+2,x
    dey
    sta (dirptr),y
    lda fd_area+F32_fd::FileSize+1,x
    dey
    sta (dirptr),y
    lda fd_area+F32_fd::FileSize+0,x
    dey
    sta (dirptr),y
    debug32 "fsize", fd_area+(2*.sizeof(F32_fd))+F32_fd::FileSize
    rts

; free cluster and maintain the fsinfo block
; in:
;  X - the file descriptor into fd_area (F32_fd::CurrentCluster)
; out:
;  C=0 on success, C=1 on error and A=error code
__fat_free_cluster:
    jsr __fat_read_cluster_block_and_select  ; Y offset in block
    bne @l_exit        ; read error
    bcc @l_exit        ; EOC? (C=1) expected here in order to free - TODO FIXME cluster chain during deletion not supported yet
    lda #1
    sta volumeID+VolumeID::fat_cluster_add
    dec
    bra __fat_update_cluster
@l_exit:
    rts

; in:
;   X - fd
; out:
;  C=0 on success and fd::StartCluster initialized with a valid cluster, C=1 otherwise and A=<error code>
__fat_reserve_start_cluster:
    jsr __fat_reserve_cluster
    bcs @l_exit
    lda volumeID + VolumeID::cluster + 3
    sta fd_area + F32_fd::StartCluster + 3, x
    lda volumeID + VolumeID::cluster + 2
    sta fd_area + F32_fd::StartCluster + 2, x
    lda volumeID + VolumeID::cluster + 1
    sta fd_area + F32_fd::StartCluster + 1, x
    lda volumeID + VolumeID::cluster + 0
    sta fd_area + F32_fd::StartCluster + 0, x
@l_exit:
    debug32 "reserve strt cl <", volumeID + VolumeID::cluster
    rts


; find and reserve next free cluster in given FD (.X), also maintains the fsinfo block
; in:
;  X - the file descriptor into fd_area where the found cluster should be stored
; out:
;  C=0 on success and fd::CurrentCluster initialized with the found cluster, C=1 otherwise and A=<error code>
__fat_reserve_cluster:
    jsr __fat_find_free_cluster
    bcc :+
    rts

:   lda #$ff
    sta volumeID+VolumeID::fat_cluster_add
; update cluster
; in:
;  .A - mark cluster in fat block eihter with EOC (0x0fffffff) or free 0x00000000
;  volumeID+VolumeID::fat_cluster_add amount of  clusters to be reserved/freed with A [-128...127]
__fat_update_cluster:
    jsr __fat_mark_cluster
    jsr __fat_write_fat_blocks  ; write the updated fat block for 1st and 2nd FAT to the device
    bcc :+                      ; exit on error, otherwise fall through and update the fsinfo sector/block
@l_exit:
    rts
    ;TODO check valid fsinfo block
    ;TODO check whether clnr is maintained, test 0xFFFFFFFF ?
:   m_memcpy volumeID+VolumeID::lba_fsinfo, lba_addr, 4
    jsr __fat_read_block_fat
    bcs @l_exit
    lda volumeID+VolumeID::fat_cluster_add
    stz volumeID+VolumeID::fat_cluster_add
    bpl :+                      ; +/- fs info cluster number?
    dec volumeID+VolumeID::fat_cluster_add ; 2's complement ($ff)
    ldy volumeID+VolumeID::cluster+0
    sty block_fat+F32FSInfo::LastClus+0
    ldy volumeID+VolumeID::cluster+1
    sty block_fat+F32FSInfo::LastClus+1
    ldy volumeID+VolumeID::cluster+2
    sty block_fat+F32FSInfo::LastClus+2
    ldy volumeID+VolumeID::cluster+3
    sty block_fat+F32FSInfo::LastClus+3
:   debug32 "fs_info", block_fat+F32FSInfo::FreeClus
    clc
    adc block_fat+F32FSInfo::FreeClus+0
    sta block_fat+F32FSInfo::FreeClus+0
    lda block_fat+F32FSInfo::FreeClus+1
    adc volumeID+VolumeID::fat_cluster_add
    sta block_fat+F32FSInfo::FreeClus+1
    lda block_fat+F32FSInfo::FreeClus+2
    adc volumeID+VolumeID::fat_cluster_add
    sta block_fat+F32FSInfo::FreeClus+2
    lda block_fat+F32FSInfo::FreeClus+3
    adc volumeID+VolumeID::fat_cluster_add
    sta block_fat+F32FSInfo::FreeClus+3

; return C=0 on success, C=1 otherwise and A=error code
__fat_write_block_fat:
    lda #>block_fat
    bra :+
__fat_write_block_data:
    lda #>block_data
.ifdef FAT_DUMP_FAT_WRITE
    debugdump "fat_wb dmp", block_fat
.endif
:   sta sd_blkptr+1
    stz sd_blkptr  ;block_data, block_fat address are page aligned - see fat32.inc
    phy

.ifdef FAT_NOWRITE
    lda #EOK
    clc
.else
    debug32 "f_wr lba", lba_addr
    debug16 "f_wr bpt", sd_blkptr
    phx
    jsr write_block
    plx
.endif

    ply
    cmp #EOK
    bne @l_exit_err
    clc
    rts
@l_exit_err:
    sec
    rts

__fat_write_block_data_buffered:
    lda #>block_data
    sta sd_blkptr+1
    stz sd_blkptr  ;block_data, block_fat address are page aligned - see fat32.inc
    phx
    jsr write_block_buffered
    plx
    cmp #EOK
    bne @l_exit_err
    clc
    rts
@l_exit_err:
    sec
    rts

__fat_write_fat_blocks:
    jsr __fat_write_block_fat      ; lba_addr is already setup by __fat_find_free_cluster
    bcs @err_exit
    ; calc fat2 lba_addr = lba_addr+VolumeID::FATSz32
    .repeat 4, i
      lda lba_addr+i
      adc volumeID+VolumeID::BPB_FATSz32+i
      sta lba_addr+i
    .endrepeat
    jsr __fat_write_block_fat        ; write to fat mirror (fat2)
@err_exit:
    debug "fw_blocks"
    rts


__fat_rtc_high_word:
    lsr
    ror volumeID+VolumeID::fat_tmp_1
    lsr
    ror volumeID+VolumeID::fat_tmp_1
    lsr
    ror volumeID+VolumeID::fat_tmp_1
    ora volumeID+VolumeID::fat_tmp_0
    tax
    rts

; out:
;   A/X with time from rtc struct in fat format
__fat_rtc_time:
    stz volumeID+VolumeID::fat_tmp_1
    lda rtc_systime_t+time_t::tm_hour              ; hour
    asl
    asl
    asl
    sta volumeID+VolumeID::fat_tmp_0
    lda rtc_systime_t+time_t::tm_min                ; minutes 0..59
    jsr __fat_rtc_high_word
    lda rtc_systime_t+time_t::tm_sec                ; seconds/2
    lsr
    ora volumeID+VolumeID::fat_tmp_1
    rts

; out
;   A/X with date from rtc struct in fat format
__fat_rtc_date:
    stz volumeID+VolumeID::fat_tmp_1
    lda rtc_systime_t+time_t::tm_year               ; years since 1900
    sec
    sbc #80                                         ; fat year is 1980..2107 (bit 15-9), we have to adjust 80 years
    asl
    sta volumeID+VolumeID::fat_tmp_0
    lda rtc_systime_t+time_t::tm_mon                ; month from rtc is (0..11), adjust +1
    inc
    jsr __fat_rtc_high_word
    lda rtc_systime_t+time_t::tm_mday               ; day of month (1..31)
    ora volumeID+VolumeID::fat_tmp_1
    rts

; mark cluster according to A
; in:
;  A - 0x00 free, 0xff EOC
;  Y - offset in block
;   sd_blkptr - points to block_fat either 1st or 2nd page
__fat_mark_cluster:
    sta (sd_blkptr), y
    iny
    sta (sd_blkptr), y
    iny
    sta (sd_blkptr), y
    iny
    and #$0f
    sta (sd_blkptr), y
    rts

; try to find a free cluster and store them in volumeId+VolumeID::cluster
; out:
;   sd_blkptr points to the free cluster position within the fat block
;   C=0 on success, Y=offset in block_fat of found cluster. lba_addr of the fat block where the found cluster resides
;   C=1 on error and A=<error code>
__fat_find_free_cluster:
        debug32 "fcl cl >", volumeID+VolumeID::cluster
        debug32 "fcl flba", volumeID+VolumeID::lba_fat
@l_search:
        _inc32 volumeID+VolumeID::cluster
        m_memcpy volumeID+VolumeID::cluster, lba_addr, 4   ; init lba_addr with last cluster (if cluster is zero, it will  we start from lba_fat)
        jsr __calc_fat_lba_addr
        cmp32 volumeID+VolumeID::lba_fat2, lba_addr, @l_read  ; end of fat reached?
        lda #ENOSPC ; yes, C=1 answer ENOSPC - "No space left on device"
@l_exit_err:
        rts
@l_read:
        jsr __fat_read_block_fat  ; read fat block
        bcs @l_exit_err

        lda volumeID+VolumeID::cluster+0
        sta sd_blkptr
        lda #0
        asl sd_blkptr
        rol
        asl sd_blkptr
        rol
        ora #>block_fat
        sta sd_blkptr+1
        debug16 "fcl bp", sd_blkptr

        ldy #3
        lda (sd_blkptr),y   ; find cluster entry with ?0 00 00 00
        and #$0f
        dey
        ora (sd_blkptr),y
        dey
        ora (sd_blkptr),y
        dey
        ora (sd_blkptr)
        cmp #0
        bne @l_search
        debug32 "fat find cl <", volumeID+VolumeID::cluster ; found, cluster is set already
        clc
        rts

; unlink a file denoted by given path in A/X
; in:
;  A/X - pointer to string with the file path
; out:
;  Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_unlink:
    ldy #O_RDONLY
    jsr fat_fopen    ; try to open as regular file
    bcs @l_exit
    jsr __fat_unlink
    debug "unlnk"
    jmp __fat_free_fd
@l_exit:
    rts

__fat_unlink:
    jsr __fat_is_cln_zero           ; no clnr assigned yet, file was just touched
    beq @l_unlink_direntry          ; ... then we can skip freeing clusters from fat

    jsr __fat_free_cluster          ; free cluster, update fsinfo
    bcs @l_exit
@l_unlink_direntry:
    jsr __fat_read_direntry         ; read the dir entry
    bcs @l_exit
    lda #DIR_Entry_Deleted          ; mark dir entry as deleted ($e5)
    sta (dirptr)
    jmp __fat_write_block_data      ; write back dir entry
@l_exit:
    rts
