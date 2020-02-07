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

; external deps - block layer
.import read_block

.import __fat_init_fdarea
.import __fat_init_fd

.export fat_mount

.code
;---------------------------------------------------------------------
; Mount FAT32 on Partition 0
;---------------------------------------------------------------------
fat_mount:
		; set lba_addr to $00000000 since we want to read the bootsector
		.repeat 4, i
			stz lba_addr + i
		.endrepeat

		SetVector sd_blktarget, read_blkptr
		jsr read_block

		jsr fat_check_signature
		bne @l_exit
@l1:
		@part0 = sd_blktarget + BootSector::Partitions + PartTable::Partition_0

		lda @part0 + PartitionEntry::TypeCode
		cmp #PartType_FAT32_LBA
		beq @l2
		lda #fat_invalid_partition_type	; type code not  PartType_FAT32_LBA ($0C)
		bra @l_exit
@l2:
		m_memcpy @part0 + PartitionEntry::LBABegin, lba_addr, 4
		;debug32 "p_lba", lba_addr

		SetVector sd_blktarget, read_blkptr
		; Read FAT Volume ID at LBABegin and Check signature
		jsr read_block
		bne @l_exit
		jsr fat_check_signature
		bne @l_exit
@l4:
		;m_memcpy	sd_blktarget+11, volumeID, .sizeof(VolumeID) ; +11 skip first 11 bytes, we are not interested in
		m_memcpy	sd_blktarget + F32_VolumeID::BPB, volumeID + VolumeID::BPB, .sizeof(BPB) ; +11 skip first 11 bytes, we are not interested in
		m_memcpy	sd_blktarget + F32_VolumeID::EBPB, volumeID + VolumeID::EBPB, .sizeof(EBPB) ; +11 skip first 11 bytes, we are not interested in

		; Bytes per Sector, must be 512 = $0200
		lda	volumeID + VolumeID::BPB + BPB::BytsPerSec+0
		bne @l_exit
		lda	volumeID + VolumeID::BPB + BPB::BytsPerSec+1
		cmp #$02
		beq @l6
		lda #fat_invalid_sector_size
@l_exit:
		jmp @end_mount
@l6:
		; cluster_begin_lba = Partition_LBA_Begin + Number_of_Reserved_Sectors + (Number_of_FATs * Sectors_Per_FAT) -  (2 * sec/cluster);
		; fat_lba_begin = Partition_LBA_Begin + Number_of_Reserved_Sectors
		; fat2_lba_begin = Partition_LBA_Begin + Number_of_Reserved_Sectors + Sectors_Per_FAT

		; add number of reserved sectors to calculate fat_lba_begin. also store in cluster_begin_lba for further calculation
		clc
		lda lba_addr + 0
		adc volumeID + VolumeID::BPB + BPB::RsvdSecCnt + 0
		sta cluster_begin_lba + 0
		sta fat_lba_begin + 0
		lda lba_addr + 1
		adc volumeID + VolumeID::BPB + BPB::RsvdSecCnt + 1
		sta cluster_begin_lba + 1
		sta fat_lba_begin + 1
		lda lba_addr + 2
		adc #$00
		sta cluster_begin_lba + 2
		sta fat_lba_begin + 2
		lda lba_addr + 3
		adc #$00
		sta cluster_begin_lba + 3
		sta fat_lba_begin + 3

		; Number of FATs. Must be 2
		; cluster_begin_lba = fat_lba_begin + (sectors_per_fat * VolumeID::NumFATs (2))
		ldy volumeID + VolumeID::BPB + BPB::NumFATs
@l7:	clc
		ldx #$00
@l8:	ror ; get carry flag back
		lda volumeID + VolumeID::EBPB + EBPB::FATSz32,x ; sectors per fat
		adc cluster_begin_lba,x
		sta cluster_begin_lba,x
		inx
		rol ; save status register before cpx to save carry
		cpx #$04 ; 32Bit
		bne @l8
		dey
		bne @l7

		; calc begin of 2nd fat (end of 1st fat)
		; TODO FIXME - we assume 16bit are sufficient for now since fat is placed at the beginning of the device
		clc
		lda volumeID +  VolumeID::EBPB + EBPB::FATSz32+0 ; sectors/blocks per fat
		adc fat_lba_begin	+0
		sta fat2_lba_begin	+0
		lda volumeID +  VolumeID::EBPB + EBPB::FATSz32+1
		adc fat_lba_begin	+1
		sta fat2_lba_begin	+1

		; calc fs_info lba address
		clc
		lda lba_addr+0
		adc volumeID+ VolumeID::EBPB + EBPB::FSInfoSec+0
		sta fat_fsinfo_lba+0
		lda lba_addr+1
		adc volumeID+ VolumeID::EBPB + EBPB::FSInfoSec+1
		sta fat_fsinfo_lba+1
		lda #0
		sta fat_fsinfo_lba+3
		adc #0				; 0 + C
		sta fat_fsinfo_lba+2

		; cluster_begin_lba_m2 -> cluster_begin_lba - (VolumeID::RootClus*VolumeID::SecPerClus)
		; cluster_begin_lba_m2 -> cluster_begin_lba - (2*sec/cluster) => cluster_begin_lba - (sec/cluster << 1)
		;TODO FIXME we assume 2 here instead of using the value in VolumeID::RootClus
		lda volumeID+VolumeID::BPB + BPB::SecPerClus ; max sec/cluster can be 128, with 2 (BPB_RootClus) * 128 wie may subtract max 256
		asl
		sta lba_addr		  ;	used as tmp
		stz lba_addr +1	  ;	safe carry
		rol lba_addr +1
		sec						 ;	subtract from cluster_begin_lba
		lda cluster_begin_lba
		sbc lba_addr
		sta cluster_begin_lba
		lda cluster_begin_lba +1
		sbc lba_addr +1
		sta cluster_begin_lba +1
		lda cluster_begin_lba +2
		sbc #0
		sta cluster_begin_lba +2
		lda cluster_begin_lba +3
		sbc #0
		sta cluster_begin_lba +3

		;debug8 "sec/cl", volumeID+VolumeID::BPB + BPB::SecPerClus
		;debug32 "r_cl", volumeID+VolumeID::EBPB + EBPB::RootClus
		;debug32 "s_lba", lba_addr
		;debug16 "r_sc", volumeID + VolumeID::BPB + BPB::RsvdSecCnt
		;debug16 "f_lba", fat_lba_begin
		;debug32 "f_sc", volumeID +  VolumeID::EBPB + EBPB::FATSz32
		;debug16 "f2_lba", fat2_lba_begin
		;debug16 "fi_sc", volumeID+ VolumeID::EBPB + EBPB::FSInfoSec
		;debug32 "fi_lba", fat_fsinfo_lba
		;debug32 "cl_lba", cluster_begin_lba
		;debug16 "fbuf", filename_buf

		; init file descriptor area
      ldx #0
		jsr __fat_init_fdarea

		; alloc file descriptor for current dir. which is cluster number 0 on fat32 - Note: the RootClus offset is compensated within calc_lba_addr
		ldx #FD_INDEX_CURRENT_DIR
		jsr __fat_init_fd
@end_mount:
		debug "f_mnt"
		rts

fat_check_signature:
		lda #$55
		cmp sd_blktarget + BootSector::Signature
		bne @l1
		asl ; $aa
		cmp sd_blktarget + BootSector::Signature + 1
		beq @l2
@l1:	lda #fat_bad_block_signature
@l2:	rts