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

.ifdef DEBUG_UTIL    ; enable debug for this module
  debug_enabled=1
.endif
.setcpu "65c02"
.include "fat32.inc"
.include "common.inc"
.include "zeropage.inc"
.include "errno.inc"
.include "debug.inc"


.export fat_get_root_and_pwd

.autoimport

.code
;in:
;  A/Y - address to write the current work directory string into
;  X  - size of result buffer/string
;out:
;  C - C=0 on success (A=0), C=1 and A=error code otherwise
fat_get_root_and_pwd:

              php
              sei

              sta __volatile_ptr
              sty __volatile_ptr+1
              stx volumeID+VolumeID::fat_tmp_0

              ldy #FD_INDEX_CURRENT_DIR
              ldx #FD_INDEX_TEMP_FILE
              jsr __fat_clone_fd                  ; start from current directory, clone the cd fd

              lda #0
              jsr put_char                        ; \0 terminated end of buffer

@l_rd_dir:    lda #'/'                            ; put the / char to result string
              jsr put_char
              ldx #FD_INDEX_TEMP_FILE             ; if root, exit to inverse the path string
              jsr __fat_is_start_cln_zero
              beq @l_path_trim
              m_memcpy fd_area+FD_INDEX_TEMP_FILE+F32_fd::StartCluster, volumeID+VolumeID::cluster, 4  ; save the cluster from the fd of the "current" dir which is stored in FD_INDEX_TEMP_FILE (see clone above)
              lda #<l_dot_dot
              ldx #>l_dot_dot
              ldy #FD_INDEX_TEMP_FILE             ; call opendir function with "..", on success the fd (FD_INDEX_TEMP_FILE) was updated and points to the parent directory
              jsr __fat_open_path
              bcs @l_exit
              jsr __fat_free_fd
              SetVector cluster_nr_matcher, volumeID+VolumeID::fat_vec_matcher  ; set the matcher strategy to the cluster number matcher
              ldx #FD_INDEX_TEMP_FILE
              jsr __fat_find_first                ; and call find first to find the entry with that cluster number we saved in cluster before we did the cd ".."
              bcs @l_exit
              jsr fat_name_string                 ; found, dirptr points to the entry and we can simply extract the name - fat_name_string formats and appends the dir entry name:attr
              bra @l_rd_dir                       ; go on with bottom up walk until root is reached
@l_path_trim:
              jsr path_trim                       ; since we captured the dir entry names bottom up, the path segments are in inverse order, we have to inverse them per segment and write them to the target string
              plp
              clc
              rts

@l_exit:      plp
              sec
              rts
l_dot_dot:
              .asciiz ".."


; in:
;   dirptr - pointer to dir entry (F32DirEntry)
; out:
;   C=0 not found, C=1 found
cluster_nr_matcher:
              ldy #F32DirEntry::Name
              lda (dirptr),y
              cmp #DIR_Entry_Deleted
              beq @l_notfound
              ldy #F32DirEntry::FstClusLO+0
              lda volumeID+VolumeID::cluster+0
              cmp (dirptr),y
              bne @l_notfound
              iny
              lda volumeID+VolumeID::cluster+1
              cmp (dirptr),y
              bne @l_notfound
              ldy #F32DirEntry::FstClusHI+0
              lda volumeID+VolumeID::cluster+2
              cmp (dirptr),y
              bne @l_notfound
              iny
              lda volumeID+VolumeID::cluster+3
              cmp (dirptr),y
              beq @l_found
@l_notfound:  clc
@l_found:     rts

path_trim:
              ldy #0
:             phy
              ldy volumeID+VolumeID::fat_tmp_0
              lda (__volatile_ptr),y
              ply
              sta (__volatile_ptr),y
              cmp #0
              beq @l_exit
              inc volumeID+VolumeID::fat_tmp_0
              iny
              bne :-
@l_exit:      rts


; fat name to string (by reference)
; in:
;   dirptr         - pointer to directory entry (F32DirEntry)
;   __volatile_ptr - pointer to result string
;   __string_ix    - length or offset in result string denoted by __volatile_ptr
fat_name_string:
              ldy #.sizeof(F32DirEntry::Name) + .sizeof(F32DirEntry::Ext)
@l_next:
              dey
              lda (dirptr),y
              cmp #' '
              beq @l_next
              cpy #.sizeof(F32DirEntry::Name)
              bne :+
              pha
              lda #'.'
              jsr put_char
              pla
:             jsr put_char
              bne @l_next
              rts
put_char:     phy
              ldy volumeID+VolumeID::fat_tmp_0
              beq @l_exit
              dey
              sty volumeID+VolumeID::fat_tmp_0
              sta (__volatile_ptr),y
@l_exit:      ply
              rts