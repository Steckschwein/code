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


.ifdef DEBUG_FAT32_MOUNT ; debug switch for this module
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

.export fat_mount
;@module: fat32
.code
;---------------------------------------------------------------------
; Mount FAT32 on Partition 0
;---------------------------------------------------------------------
; out:
;   C=0 on success, C=1 otherwise with A=<error code>
;@name: "fat_mount"
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@desc: "mount fat32 file system"
fat_mount:

    m_memclr volumeID, .sizeof(VolumeID)

    ; set lba_addr to $00000000 since we want to read the bootsector
    m_memclr lba_addr, 4
    jsr __fat_read_block_data
    bcc @l0
    rts
@l0:
    jsr fat_check_signature
    beq @l1
    rts
@l1:  ; Check partition table entry 0 for valid FAT32 signature
    @part0 = block_data + BootSector::Partitions + PartTable::Partition_0

    lda @part0 + PartitionEntry::TypeCode
    cmp #PartType_FAT32_LBA
    bne @mount_fat32
    ; partition entry 0 did not contain a valid FAT32 partition signature
    ; we assume now that the card does not have a MBR boot block, and we already
    ; have loaded the fat32 bpb
@load_bpb:
    ; Partition entry 0 contains a valid FAT32 LBA partition signature
    ; get the lba address
    m_memcpy @part0 + PartitionEntry::LBABegin, lba_addr, 4
    debug32 "mnt_lba", lba_addr

    ; Read FAT Volume ID at LBABegin and Check signature
    jsr __fat_read_block_data
    bcc :+
    rts

:   jsr fat_check_signature
    beq @mount_fat32
    rts
@mount_fat32:
    ; Bytes per Sector, must be 512 = $0200
    lda block_data + F32_VolumeID::BPB + BPB::BytsPerSec+0
    bne @invalid
    lda block_data + F32_VolumeID::BPB + BPB::BytsPerSec+1
    cmp #$02
    beq @l6
@invalid:
    lda #fat_invalid_sector_size
    sec
    rts
@l6:
    lda block_data + F32_VolumeID::BPB + BPB::SecPerClus
    sta volumeID + VolumeID::BPB_SecPerClus
    dec
    sta volumeID + VolumeID::BPB_SecPerClusMask

    lda volumeID + VolumeID::BPB_SecPerClus
:   lsr
    beq @l7
    inc volumeID + VolumeID::BPB_SecPerClusCount
    bra :-

@l7:
    m_memcpy block_data + F32_VolumeID::BPB + BPB::RootClus, volumeID + VolumeID::BPB_RootClus, 4
    m_memcpy block_data + F32_VolumeID::BPB + BPB::FATSz32, volumeID + VolumeID::BPB_FATSz32, 4

    ; calc fs_info lba address as cluster_begin_lba + BPB::FSInfoSec
    add16to32 lba_addr, block_data + F32_VolumeID::BPB + BPB::FSInfoSec, volumeID + VolumeID::lba_fsinfo

    ; fat_lba_begin  = Partition_LBA_Begin + Number_of_Reserved_Sectors
    ; add number of reserved sectors to calculate fat_lba_begin. store in volumeID for further calculation
    add16to32 lba_addr, block_data + F32_VolumeID::BPB + BPB::RsvdSecCnt, volumeID + VolumeID::lba_fat

    ; fat2_lba_begin = fta_lba_behin + Sectors_Per_FAT
    add32 volumeID + VolumeID::lba_fat, volumeID + VolumeID::BPB_FATSz32, volumeID + VolumeID::lba_fat2

    ; cluster_begin_lba = Partition_LBA_Begin + Number_of_Reserved_Sectors + (Number_of_FATs * Sectors_Per_FAT) -  (2 * sec/cluster);
    ldy block_data + F32_VolumeID::BPB + BPB::NumFATs
    cpy #2
    bcs @l8
    lda #fat_invalid_num_fats
    sec
    rts
@l8:
    ; number of fats is at least 2 here
    add32 volumeID + VolumeID::lba_fat, volumeID + VolumeID::BPB_FATSz32, volumeID + VolumeID::lba_data
    dey
@loop:  ; we have to add "n" times FATSz32 to calc the data lba
    add32 volumeID + VolumeID::lba_data, volumeID + VolumeID::BPB_FATSz32, volumeID + VolumeID::lba_data
    dey
    bne @loop

    ; performance optimization - the RootClus offset is compensated within calc_lba_addr - we avoid the substraction of the RootClus from lba_data on each calculation
    ; lba_cluster_m2 = cluster_begin_lba - (VolumeID::RootClus * VolumeID::SecPerClus)
    jsr __fat_set_root_cluster_lba_addr   ; root cluster to lba_addr
    jsr __fat_shift_lba_addr              ; * sec/cl

    sec          ;  subtract from volumeID + VolumeID::lba_data
    lda volumeID + VolumeID::lba_data+0
    sbc lba_addr+0
    sta volumeID + VolumeID::lba_data+0
    lda volumeID + VolumeID::lba_data+1
    sbc lba_addr +1
    sta volumeID + VolumeID::lba_data+1
    lda volumeID + VolumeID::lba_data+2
    sbc lba_addr +2
    sta volumeID + VolumeID::lba_data+2
    lda volumeID + VolumeID::lba_data+3
    sbc lba_addr +3
    sta volumeID + VolumeID::lba_data+3

    debug8 "sc/cl",   volumeID+VolumeID::BPB_SecPerClus
    debug8 "sc/msk",   volumeID+VolumeID::BPB_SecPerClusMask
    debug8 "sc/cnt",   volumeID+VolumeID::BPB_SecPerClusCount
    debug32 "root cl",   volumeID+VolumeID::BPB_RootClus
    debug32 "fi sc",  volumeID+VolumeID::lba_fsinfo
    debug32 "fat sz",   volumeID+VolumeID::BPB_FATSz32
    debug32 "fat lba",  volumeID+VolumeID::lba_fat
    debug32 "fat2_lba", volumeID+VolumeID::lba_fat2
    debug32 "data lba", volumeID+VolumeID::lba_data
    debug16 "fbuf",   volumeID+VolumeID::filename_buf

    ldx #0  ; init file descriptor area
    jsr __fat_init_fdarea

    ; alloc file descriptor for current dir. which is cluster number 0 on fat32 - !!! Note: the RootClus offset is compensated within calc_lba_addr
    ldx #FD_INDEX_CURRENT_DIR
    jmp __fat_open_rootdir

fat_check_signature:
    lda block_data + BootSector::Signature
    asl
    cmp block_data + BootSector::Signature + 1
    beq @ok
    lda #fat_bad_block_signature
@ok:
    rts
