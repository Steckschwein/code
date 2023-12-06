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
.export __fat_ensure_start_cluster
.export __fat_write_dir_entry
.export __fat_update_direntry
.export __fat_write_block
.export __fat_fopen_touch
.export __fat_write_block_data
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

    sta __volatile_tmp

    jsr __fat_prepare_block_access
    bcs @l_exit

    lda __volatile_tmp                  ; get back byte to write
    debug "fwr bt"
    sta (__volatile_ptr)

    _inc32_x fd_area+F32_fd::SeekPos    ; seek+1
    jsr __fat_set_fd_filesize

    jsr __fat_write_block_data          ; write block
@l_exit:
    ply
    rts


__fat_set_fd_filesize:
    debug32 "seek > fs", fd_area+(2*FD_Entry_Size)+F32_fd::FileSize
    lda fd_area+F32_fd::FileSize+3,x
    cmp fd_area+F32_fd::SeekPos+3,x
    bcc @l_set3
    bne @l_exit
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
    debug32 "seek < fs", fd_area+(2*FD_Entry_Size)+F32_fd::FileSize
    rts


; out:
;   C=0 on success, C=1 and A=<error> otherwise
__fat_update_direntry:
    lda fd_area+F32_fd::flags,x
    and #(O_CREAT | O_WRONLY | O_APPEND | O_TRUNC) ; file write access?
    beq @l_exit_err

    jsr __fat_read_direntry                  ; read dir entry, dirptr is set accordingly
    bcs @l_exit
    jsr __fat_set_direntry_start_cluster
    jsr __fat_set_direntry_filesize         ; set filesize of directory entry via dirptr
    jsr __fat_set_direntry_modify_datetime  ; set modification time and date

    jmp __fat_write_block_data              ; lba_addr is already set from read, see above
@l_exit_err:
    lda #EBADF
    sec
@l_exit:
    rts

; read the block with the directory entry of the given file descriptor, dirptr is adjusted accordingly
; in:
;    X - file descriptor of the file the directory entry should be read
; out:
;    C - C=0 on success (A=0), C=1 and A=<error code> otherwise
;  dirptr pointing to the corresponding directory entry of type F32DirEntry
__fat_read_direntry:
    jsr __fat_set_lba_from_fd_dirlba      ; setup lba address from fd
    jsr __fat_read_block_data              ; and read the block with the dir entry
    bcs @l_exit

    lda fd_area+F32_fd::DirEntryPos, x  ; setup dirptr
    asl
    sta dirptr
    lda #>block_data
    adc #0 ;+Carry
    sta dirptr+1
    lda #EOK
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
    debug32 "fw_slba", lba_addr
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
    ldy #F32DirEntry::WrtTime                  ; creation date/time copy over from modified date/time
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

; copy cluster number from file descriptor to direntry given as dirptr
; in:
;  dirptr
__fat_set_direntry_start_cluster:
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
    rts

; write new dir entry to dirptr and set new end of directory marker
; in:
;  X - file descriptor of the new dir entry within fd_area
;  dirptr to directory entry
; out:
;  C=0 on success, C=1 on error and A=<error code>
__fat_fopen_touch:
    copypointer dirptr, s_ptr2
    jsr string_fat_name         ; build fat name upon input string (filenameptr)
    bne @l_exit_err
    jsr __fat_alloc_fd          ; alloc a fd for the new file we want to create to make sure we get one before
    bcs @l_exit                 ; we do any sd block writes which may result in various errors
    lda __volatile_tmp          ; save file open flags
    sta fd_area+F32_fd::flags, x
    lda #DIR_Attr_Mask_Archive    ; create as regular file with archive bit set
    jsr __fat_set_fd_attr_dirlba  ; update dir lba addr and dir entry number within fd from lba_addr and dir_ptr which where setup during __fat_opendir_cwd from above
    jsr __fat_write_dir_entry    ; create dir entry at current dirptr
    bcc @l_exit
    jmp fat_close               ; free the allocated file descriptor if there where errors, C=1 and A are preserved
@l_exit_err:
    sec
@l_exit:
    debug "fop touch"
    rts


; write new dir entry to dirptr and set new end of directory marker
; in:
;  X - file descriptor of the new dir entry within fd_area
;  dirptr - set to current dir entry within block_data
; out:
;  C=0 on success, C=1 on error and A=<error code>
__fat_write_dir_entry:

    lda fd_area+F32_fd::Attr, x
    ldy #F32DirEntry::Attr                    ; store attribute
    sta (dirptr), y

    lda #0
    ldy #F32DirEntry::Reserved                  ; unused
    sta (dirptr), y
    ldy #F32DirEntry::CrtTimeMillis
    sta (dirptr), y                        ; ms to 0, ms not supported by rtc

    jsr __fat_set_direntry_start_cluster
    jsr __fat_set_direntry_filesize
    jsr __fat_set_direntry_modify_datetime
    jsr __fat_set_direntry_create_datetime

    debug16 "f_w_dp", dirptr

    ;TODO FIXME duplicate code here! - @see __fat_find_next:
    lda dirptr+1
    sta s_ptr1+1
    lda dirptr                          ; create the end of directory entry
    clc
    adc #DIR_Entry_Size
    sta s_ptr1
    bcc @l2
    inc s_ptr1+1
@l2:
    lda s_ptr1+1               ; end of block reached? :/ edge-case, we have to create the end-of-directory entry at the next block
    cmp #>(block_data+sd_blocksize)
    beq @l_new_block            ; yes, prepare new block
    lda #0                  ; mark EOD
    sta (s_ptr1)
    bra @l_eod
@l_new_block:                  ; new dir entry
    jsr __fat_write_block_data        ; write the current block with the updated dir entry first
    bcs @l_exit

    ldy #0                  ; safely, fill the new dir block with 0 to mark end-of-directory
    tya
@l_erase:
    sta block_data+$000, y
    sta block_data+$100, y
    iny
    bne @l_erase
    ;TODO FIXME test end of cluster, if so reserve a new one, update cluster chain for directory ;)
    debug32 "eod_lba", lba_addr
    debug32 "eod_cln", fd_area+FD_INDEX_TEMP_DIR
    jsr __inc_lba_address                    ; increment lba address to write to next block
@l_eod:
    ;TODO FIXME erase the rest of the block, currently 0 is assumed
    jsr __fat_write_block_data                  ; write the updated dir entry to device
@l_exit:
    debug "f_wde"
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
    sta s_tmp1
    dec
    bra __fat_update_cluster
@l_exit:
    rts

; out:
;  C=0 on success and fd::StartCluster initialized with a valid cluster, C=1 otherwise and A=<error code>
__fat_ensure_start_cluster:
    clc
    lda fd_area+F32_fd::StartCluster+3, x
    ora fd_area+F32_fd::StartCluster+2, x
    ora fd_area+F32_fd::StartCluster+1, x
    ora fd_area+F32_fd::StartCluster+0, x
    bne @l_exit

    lda fd_area + F32_fd::flags,x
    and #(O_CREAT | O_WRONLY | O_APPEND | O_TRUNC) ; write access?
    sec         ; set EOC (C=1) A=0 (EOK) if we take the branch
    debug "sel strt cl flg"
    beq @l_exit     ; read access and no cluster reserved yet (empty file) - exit with EOC => C=1/A=EOK (0)
    jsr __fat_reserve_cluster
    bcs @l_exit
    jsr __fat_set_fd_start_cluster
@l_exit:
    debug32 "sel strt cl <", fd_area+(FD_Entry_Size*2)+F32_fd::CurrentCluster
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
    sta s_tmp1
; update cluster
; in:
;  .A - mark cluster in fat block eihter with EOC (0x0fffffff) or free 0x00000000
;  s_tmp1 amount of  clusters to be reserved/freed with A [-128...127]
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
    stz s_tmp2
    lda s_tmp1
    bpl :+                      ; +/- fs info cluster number?
    dec s_tmp2 ; 2's complement ($ff)
    ldy fd_area+F32_fd::CurrentCluster+0,x
    sty block_fat+F32FSInfo::LastClus+0
    ldy fd_area+F32_fd::CurrentCluster+1,x
    sty block_fat+F32FSInfo::LastClus+1
    ldy fd_area+F32_fd::CurrentCluster+2,x
    sty block_fat+F32FSInfo::LastClus+2
    ldy fd_area+F32_fd::CurrentCluster+3,x
    sty block_fat+F32FSInfo::LastClus+3
:   debug32 "fs_info", block_fat+F32FSInfo::FreeClus
    clc
    adc block_fat+F32FSInfo::FreeClus+0
    sta block_fat+F32FSInfo::FreeClus+0
    lda block_fat+F32FSInfo::FreeClus+1
    adc s_tmp2
    sta block_fat+F32FSInfo::FreeClus+1
    lda block_fat+F32FSInfo::FreeClus+2
    adc s_tmp2
    sta block_fat+F32FSInfo::FreeClus+2
    lda block_fat+F32FSInfo::FreeClus+3
    adc s_tmp2
    sta block_fat+F32FSInfo::FreeClus+3

; return C=0 on success, C=1 otherwise and A=error code
__fat_write_block_fat:
    phy
    ldy #>block_fat
    bra :+
__fat_write_block_data:
    phy
    ldy #>block_data
.ifdef FAT_DUMP_FAT_WRITE
    debugdump "fat_wb dmp", block_fat
.endif
:    lda write_blkptr
    pha
    lda write_blkptr+1
    pha
    jsr :+
    ply
    sty write_blkptr+1
    ply
    sty write_blkptr
    ply
    rts
:   sty write_blkptr+1
    stz write_blkptr  ;block_data, block_fat address are page aligned - see fat32.inc
__fat_write_block:
.ifndef FAT_NOWRITE
    debug32 "f_wr lba", lba_addr
    debug16 "f_wr wpt", write_blkptr
    phx
    jsr write_block
    dec write_blkptr+1    ; TODO FIXME clarification with TW - write_block increments write_blkptr highbyte - which is a sideeffect and should be avoided
    plx
    cmp #EOK
    bne :+
    clc
    rts
.else
    lda #EOK
    clc
    rts
.endif
:   sec
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
    ror  s_tmp2
    lsr
    ror  s_tmp2
    lsr
    ror  s_tmp2
    ora s_tmp1
    tax
    rts

    ; out:
    ;  .A/.X with time from rtc struct in fat format
__fat_rtc_time:
    stz s_tmp2
    lda rtc_systime_t+time_t::tm_hour              ; hour
    asl
    asl
    asl
    sta s_tmp1
    lda rtc_systime_t+time_t::tm_min                ; minutes 0..59
    jsr __fat_rtc_high_word
    lda rtc_systime_t+time_t::tm_sec                ; seconds/2
    lsr
    ora s_tmp2
    rts

    ; out
    ;  A/X with date from rtc struct in fat format
__fat_rtc_date:
    stz s_tmp2
    lda rtc_systime_t+time_t::tm_year              ; years since 1900
    sec
    sbc #80                                ; fat year is 1980..2107 (bit 15-9), we have to adjust 80 years
    asl
    sta s_tmp1
    lda rtc_systime_t+time_t::tm_mon                ; month from rtc is (0..11), adjust +1
    inc
    jsr __fat_rtc_high_word
    lda rtc_systime_t+time_t::tm_mday              ; day of month (1..31)
    ora s_tmp2
    rts

; mark cluster according to A
; in:
;  A - 0x00 free, 0xff EOC
;  Y - offset in block
;   read_blkptr - points to block_fat either 1st or 2nd page
__fat_mark_cluster:
    sta (read_blkptr), y
    iny
    sta (read_blkptr), y
    iny
    sta (read_blkptr), y
    iny
    and #$0f
    sta (read_blkptr), y
    rts

; in:
;  X - file descriptor
; out:
;  C=0 on success
;  Y=offset in block_fat of found cluster
;  lba_addr with fat block where the found cluster resides
;  the found cluster is stored within the given file descriptor at fd_area+F32_fd::CurrentCluster,x and fd_area+F32_fd::StartCluster,x if its the start cluster
;  C=1 on error, A=<error code>
__fat_find_free_cluster:
    ;TODO improve, use a previously saved lba_addr and/or found cluster number - e.g. from fsinfo
    ; init lba_addr with fat_begin lba addr
    lda volumeID+VolumeID::lba_fat+3
    sta lba_addr+3
    lda volumeID+VolumeID::lba_fat+2
    sta lba_addr+2
    lda volumeID+VolumeID::lba_fat+1
    sta lba_addr+1
    lda volumeID+VolumeID::lba_fat+0
    sta lba_addr+0

@next_block:
    jsr __fat_read_block_fat  ; read fat block
    bcs @l_exit_err

    ldy #0
@l1:
    lda block_fat+3,y    ; 1st page find cluster entry with ?0 00 00 00
    and #$0f
    ora block_fat+2,y
    ora block_fat+1,y
    ora block_fat+0,y
    beq @l_found_lb      ; branch, A=0 here

    lda block_fat+$100+3,y  ; 2nd page find cluster entry with ?0 00 00 00
    and #$0f                ; mask upper 4 bits
    ora block_fat+$100+2,y
    ora block_fat+$100+1,y
    ora block_fat+$100+0,y
    beq @l_found_hb
    iny
    iny
    iny
    iny
    bne @l1
    jsr __inc_lba_address  ; inc lba_addr, next fat block

    cmp32 volumeID+VolumeID::lba_fat2, lba_addr, @next_block ; end of fat reached?
    lda #ENOSPC        ; yes, answer ENOSPC () - "No space left on device"
@l_exit_err:
    debug32 "free_cl", fd_area+(2*.sizeof(F32_fd))+F32_fd::CurrentCluster ; almost the 3rd entry
    rts
@l_found_hb: ; found in "high" block (2nd page of the sd_blocksize)
    lda #>(block_fat+$100)  ; set read_blkptr to begin 2nd page of fat_buffer - @see __fat_mark_free_cluster
    sta read_blkptr+1
    lda #$40          ; adjust clnr with +$40 (256 / 4 byte/clnr) clusters since it was found in 2nd page
@l_found_lb:          ; A=0 here if called from branch above
    sta fd_area+F32_fd::CurrentCluster+0, x
    tya
    lsr            ; offset Y>>2 (div 4, 32 bit clnr)
    lsr
    adc fd_area+F32_fd::CurrentCluster+0, x  ; C=0 here always, y is multiple of 4
    sta fd_area+F32_fd::CurrentCluster+0, x  ; safe clnr
    debug32 "fat_fcc_cl", fd_area+(2*.sizeof(F32_fd)) +F32_fd::CurrentCluster ; hart debug 3rd fd entry

    ; calc the cluster number with clnr = (block number * 512) / 4+(Y / 4) => (lba_addr - volumeID+VolumeID::lba_fat) << 7+(Y>>2)
    ; to avoid the <<7, we simply <<8 and do one ror - FTW!
    sec
    lda lba_addr+0
    sbc volumeID+VolumeID::lba_fat+0
    sta s_tmp1        ; save A
    lda lba_addr+1
    sbc volumeID+VolumeID::lba_fat+1    ; now we have 16bit blocknumber
    lsr            ; clnr = blocks<<7
    sta fd_area+F32_fd::CurrentCluster+2, x
    lda s_tmp1        ; restore A
    ror
    sta fd_area+F32_fd::CurrentCluster+1, x
    lda #0
    ror            ; clnr += Y>>2 (offset within block) - already saved in F32_fd::CurrentCluster+0, x s.above
    adc fd_area+F32_fd::CurrentCluster+0, x
    sta fd_area+F32_fd::CurrentCluster+0, x
    lda #0          ; exit found
    sta fd_area+F32_fd::CurrentCluster+3, x
    clc ; found, C=0 success
    rts

; unlink a file denoted by given path in A/X
; in:
;  A/X - pointer to string with the file path
; out:
;  Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_unlink:
    ldy #O_RDONLY
    jsr fat_fopen    ; try to open as regular file
    bne @l_exit
    jsr __fat_unlink
    debug "unlnk"
    jmp __fat_free_fd
@l_exit:
    rts

__fat_unlink:
    jsr __fat_is_cln_zero           ; is root or no clnr assigned yet, file was just touched
    beq @l_unlink_direntry          ; ... then we can skip freeing clusters from fat

    jsr __fat_free_cluster          ; free cluster, update fsinfo
    bcs @l_exit
@l_unlink_direntry:
    jsr __fat_read_direntry         ; read the dir entry
    bne @l_exit
    lda #DIR_Entry_Deleted          ; mark dir entry as deleted ($e5)
    sta (dirptr)
    jmp __fat_write_block_data      ; write back dir entry
@l_exit:
    rts
