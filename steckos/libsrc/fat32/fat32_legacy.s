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


.ifdef DEBUG_FAT32_LEGACY ; debug switch for this module
  debug_enabled=1
.endif

.include "zeropage.inc"
.include "common.inc"
.include "fat32.inc"
.include "rtc.inc"
.include "errno.inc"  ; from ca65 api
.include "fcntl.inc"  ; from ca65 api

.include "debug.inc"

.autoimport

.export fat_read
.export fat_write


    ;in:
    ;  X - offset into fd_area
    ;out:
    ;  Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_read:
    bit fd_area + F32_fd::CurrentCluster+3, x
    bmi @l_err_exit

    jsr __calc_blocks
    beq @l_exit          ; if Z=0, no blocks to read. we return with "EOK", 0 bytes read
    jsr __calc_lba_addr
    jsr sd_read_multiblock
    rts
@l_err_exit:
    lda #EINVAL
@l_exit:
    rts

; NOTE: only max blocks in first cluster are supported
; in:
;  X - offset into fd_area
;  write_blkptr - set to the address with data we have to write
; out:
;  C - C=0 on success (A=0), C=1 and A=error code otherwise
fat_write:

    _is_file_open     ; otherwise rts C=1 and A=#EINVAL
    _is_file_dir      ; otherwise rts C=1 and A=#EISDIR

    jsr __fat_fseek_cluster
    bcs @l_exit
@l_write:
    jsr __calc_blocks               ; calc blocks
    beq @l_update                   ; Z=1 - no blocks to write
    lda blocks                      ; > max sec/cl
    cmp volumeID+VolumeID::BPB_SecPerClus
    bcc :+
    beq :+
    lda #EINVAL
    rts
:   jsr __calc_lba_addr             ; calc lba file payload
    debug32 "fat_wr lba", lba_addr
.ifdef MULTIBLOCK_WRITE
    .warning "SD multiblock writes are EXPERIMENTAL"
    debug16 "fat_wr wptr", write_blkptr
    .import sd_write_multiblock
    jsr sd_write_multiblock
.else
@l: debug8 "fat_wr blks", blocks
    debug16 "fat_wr wptr", write_blkptr
    jsr __fat_write_block_data
    bcs @l_exit
    jsr __inc_lba_address              ; increment lba address to write next block
    inc write_blkptr+1
    inc write_blkptr+1
    dec blocks
    bne @l
.endif
@l_update:
    lda fd_area + F32_fd::FileSize + 3,x
    sta fd_area + F32_fd::SeekPos + 3,x
    lda fd_area + F32_fd::FileSize + 2,x
    sta fd_area + F32_fd::SeekPos + 2,x
    lda fd_area + F32_fd::FileSize + 1,x
    sta fd_area + F32_fd::SeekPos + 1,x
    lda fd_area + F32_fd::FileSize + 0,x
    sta fd_area + F32_fd::SeekPos + 0,x
    clc
@l_exit:
    rts

; write and sd multi block write only supports max sec/cl - therefore blocks are 8bit
; in:
;  X - file descriptor
; out:
;  Z=1 (A=0) if no blocks to read (file has zero length)
__calc_blocks: ;blocks = filesize / BLOCKSIZE -> filesize >> 9 (div 512) - +1 if filesize & 0xffffff00 != 0
    lda fd_area + F32_fd::FileSize + 2,x
    lsr
    lda fd_area + F32_fd::FileSize + 1,x
    ror
    sta blocks
    lda fd_area + F32_fd::FileSize + 0,x
    beq @l_exit
    inc blocks
@l_exit:
    debug8 "__calc_blocks", blocks
    rts
