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
.include "errno.inc"	; from ca65 api
.include "fcntl.inc"	; from ca65 api

.include "debug.inc"

.autoimport

.export fat_mount

.code
;---------------------------------------------------------------------
; Mount FAT32 on Partition 0
;---------------------------------------------------------------------
fat_mount:
		; set lba_addr to $00000000 since we want to read the bootsector
		stz lba_addr + 0
		stz lba_addr + 1
		stz lba_addr + 2
		stz lba_addr + 3
		jsr __fat_read_block_data
		beq @l0
		rts

@l0:	jsr fat_check_signature
		beq @l1
		rts

@l1:	; Check partition table entry 0 for valid FAT32 signature
		@part0 = block_data + BootSector::Partitions + PartTable::Partition_0

		lda @part0 + PartitionEntry::TypeCode
		cmp #PartType_FAT32_LBA
		beq @l2
		lda #fat_invalid_partition_type	; type code not  PartType_FAT32_LBA ($0C)
		rts
@l2:
		m_memcpy @part0 + PartitionEntry::LBABegin, lba_addr, 4
		debug32 "mnt_lba", lba_addr

		; Read FAT Volume ID at LBABegin and Check signature
		jsr __fat_read_block_data
		beq :+
		rts

:		jsr fat_check_signature
		beq @l4
		rts
@l4:
		; Bytes per Sector, must be 512 = $0200
		lda block_data + F32_VolumeID::BPB + BPB::BytsPerSec+0
		bne @invalid
		lda block_data + F32_VolumeID::BPB + BPB::BytsPerSec+1
		cmp #$02
		beq @l6
@invalid:
		lda #fat_invalid_sector_size
		rts

@l6:	lda block_data + F32_VolumeID::BPB + BPB::SecPerClus
		sta volumeID + VolumeID::BPB_SecPerClus
		m_memcpy block_data + F32_VolumeID::EBPB + EBPB::RootClus, volumeID + VolumeID::EBPB_RootClus, 4
		m_memcpy block_data + F32_VolumeID::EBPB + EBPB::FATSz32, volumeID + VolumeID::EBPB_FATSz32 , 4

__calc_fat_fsinfo_lba:
		; calc fs_info lba address as cluster_begin_lba + EBPB::FSInfoSec
		add16 lba_addr, block_data + F32_VolumeID::EBPB + EBPB::FSInfoSec, volumeID+VolumeID::lba_fsinfo
		lda lba_addr+2
		adc #0				  ; + C
		sta volumeID+VolumeID::lba_fsinfo+2
		stz volumeID+VolumeID::lba_fsinfo+3 ; always 0

__calc_fat_lba_begin:
		; cluster_begin_lba = Partition_LBA_Begin + Number_of_Reserved_Sectors + (Number_of_FATs * Sectors_Per_FAT) -  (2 * sec/cluster);
		; fat_lba_begin = Partition_LBA_Begin + Number_of_Reserved_Sectors
		; fat2_lba_begin = Partition_LBA_Begin + Number_of_Reserved_Sectors + Sectors_Per_FAT

		; add number of reserved sectors to calculate fat_lba_begin. also store in cluster_begin_lba for further calculation
		clc
		lda lba_addr + 0
		adc block_data + F32_VolumeID::BPB + BPB::RsvdSecCnt + 0
		sta volumeID+VolumeID::lba_data + 0
		sta volumeID+VolumeID::lba_fat + 0
		lda lba_addr + 1
		adc block_data + F32_VolumeID::BPB + BPB::RsvdSecCnt + 1
		sta volumeID+VolumeID::lba_data + 1
		sta volumeID+VolumeID::lba_fat + 1
		lda lba_addr + 2
		adc #0
		sta volumeID+VolumeID::lba_data + 2
		sta volumeID+VolumeID::lba_fat + 2
		; adc #0 above will never overflow
		stz volumeID+VolumeID::lba_data + 3
		stz volumeID+VolumeID::lba_fat + 3

		add32 block_data + F32_VolumeID::EBPB + EBPB::FATSz32, volumeID+VolumeID::lba_fat, volumeID+VolumeID::lba_fat2
		; fall through

__calc_cluster_begin_lba:
		; Number of FATs. Must be 2
		; cluster_begin_lba = fat_lba_begin + (sectors_per_fat * VolumeID::NumFATs (2))
		ldy block_data + F32_VolumeID::BPB + BPB::NumFATs
@l7:	clc
		add32 volumeID+VolumeID::lba_data, block_data + F32_VolumeID::EBPB + EBPB::FATSz32, volumeID+VolumeID::lba_data ; add sectors per fat
		dey
		bne @l7

		; performance optimization - the RootClus offset is compensated within calc_lba_addr
		; cluster_begin_lba_m2 = cluster_begin_lba - (VolumeID::RootClus*VolumeID::SecPerClus)
		; cluster_begin_lba_m2 = cluster_begin_lba - (2 * sec/cluster) = cluster_begin_lba - (sec/cluster << 1)

		;TODO FIXME we assume 2 here instead of using the value in VolumeID::RootClus
		lda volumeID + VolumeID::BPB_SecPerClus ; max sec/cluster can be 128, with 2 (BPB_RootClus) * 128 we may subtract max 256
		asl

		sta lba_addr+0	  	;	used as tmp
		stz lba_addr +1	  	;	safe carry
		rol lba_addr +1
		sec					;	subtract from volumeID+VolumeID::lba_data
		lda volumeID+VolumeID::lba_data+0
		sbc lba_addr+0
		sta volumeID+VolumeID::lba_data+0
		lda volumeID+VolumeID::lba_data +1
		sbc lba_addr +1
		sta volumeID+VolumeID::lba_data +1
		lda volumeID+VolumeID::lba_data +2
		sbc #0
		sta volumeID+VolumeID::lba_data +2
		lda volumeID+VolumeID::lba_data +3
		sbc #0
		sta volumeID+VolumeID::lba_data +3

		debug8 "sc/cl", volumeID + VolumeID::BPB_SecPerClus
		debug32 "r_cl", volumeID + VolumeID::EBPB_RootClus
		debug32 "f_sc", volumeID + VolumeID::EBPB_FATSz32
		debug32 "s_lba", lba_addr
		debug16 "r_sc", block_data + F32_VolumeID::BPB + BPB::RsvdSecCnt
		debug16 "fi_sc", block_data + F32_VolumeID::EBPB + EBPB::FSInfoSec
		debug32 "cl_lba", volumeID+VolumeID::lba_data
		debug32 "fi_lba", volumeID+VolumeID::lba_fsinfo
		debug16 "f_lba", volumeID + VolumeID::lba_fat
		debug16 "f2_lba", volumeID + VolumeID::lba_fat2
		debug16 "fbuf", filename_buf

		; init file descriptor area
   		ldx #0
		jsr __fat_init_fdarea

		; alloc file descriptor for current dir. which is cluster number 0 on fat32 - !!! Note: the RootClus offset is compensated within calc_lba_addr
		ldx #FD_INDEX_CURRENT_DIR
		jmp __fat_init_fd

fat_check_signature:
		lda #$55
		cmp block_data + BootSector::Signature
		bne @l1
		asl ; $aa
		cmp block_data + BootSector::Signature + 1
		beq @l2
@l1:	lda #fat_bad_block_signature
@l2:	rts
