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

.code

.export fat_get_root_and_pwd

.autoimport

;in:
;  A/X - address to write the current work directory string into
;  Y  - size of result buffer
;out:
;  C - C=0 on success (A=0), C=1 and A=error code otherwise
fat_get_root_and_pwd:

    php
    sei

    sta __volatile_ptr
    stx __volatile_ptr+1

    SetVector block_fat, s_ptr3             ; TODO FIXME !!!
    stz s_tmp3

    ldy #FD_INDEX_CURRENT_DIR
    ldx #FD_INDEX_TEMP_DIR
    jsr __fat_clone_fd                  ; start from current directory, clone the cd fd

@l_rd_dir:
    stp
    lda #'/'                            ; put the / char to result string
    jsr put_char
    ldx #FD_INDEX_TEMP_DIR              ; if root, exit to inverse the path string
    jsr __fat_is_start_cln_zero
    beq @l_inverse
    m_memcpy fd_area+FD_INDEX_TEMP_DIR+F32_fd::CurrentCluster, volumeID+VolumeID::temp_dword, 4  ; save the cluster from the fd of the "current" dir which is stored in FD_INDEX_TEMP_DIR (see clone above)
    lda #<l_dot_dot
    ldx #>l_dot_dot
    ldy #FD_INDEX_TEMP_DIR              ; call opendir function with "..", on success the fd (FD_INDEX_TEMP_DIR) was updated and points to the parent directory
    jsr fat_opendir
    bcs @l_exit
    SetVector cluster_nr_matcher, volumeID+VolumeID::fat_vec_matcher  ; set the matcher strategy to the cluster number matcher
    jsr __fat_find_first                ; and call find first to find the entry with that cluster number we saved in temp_dword before we did the cd ".."
    bcs @l_exit
    jsr fat_name_string                 ; found, dirptr points to the entry and we can simply extract the name - fat_name_string formats and appends the dir entry name:attr
    bra @l_rd_dir                       ; go on with bottom up walk until root is reached
@l_inverse:
    copypointer __volatile_ptr, s_ptr2  ; __volatile_ptr is the pointer to the result string, given by the caller (eg. pwd.prg)
    jsr path_inverse                    ; since we captured the dir entry names bottom up, the path segments are in inverse order, we have to inverse them per segment and write them to the target string
    plp
    clc
    rts
@l_exit:
    plp
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
    lda volumeID+VolumeID::temp_dword+0
    cmp (dirptr),y
    bne @l_notfound
    ldy #F32DirEntry::FstClusLO+1
    lda volumeID+VolumeID::temp_dword+1
    cmp (dirptr),y
    bne @l_notfound
    ldy #F32DirEntry::FstClusHI+0
    lda volumeID+VolumeID::temp_dword+2
    cmp (dirptr),y
    bne @l_notfound
    ldy #F32DirEntry::FstClusHI+1
    lda volumeID+VolumeID::temp_dword+3
    cmp (dirptr),y
    beq @l_found
@l_notfound:
    clc
@l_found:
    rts

  ; fat name to string (by reference)
  ; in:
  ;  dirptr    - pointer to directory entry (F32DirEntry)
  ;  s_ptr3    - pointer to result string
  ;  s_tmp3    - length or offset in result string denoted by s_ptr1
fat_name_string:
  stz s_tmp1
l_next:
  ldy s_tmp1
  cpy #11
  beq l_exit
  inc s_tmp1
  lda (dirptr), y
  cmp #' '
  beq l_next
  cpy #8
  bne fns_ca
  pha
  lda #'.'
  jsr put_char
  pla
fns_ca:
  jsr put_char
  bra l_next

put_char:
  ldy s_tmp3
  sta (s_ptr3), y
  inc s_tmp3
l_exit:
  rts

  ; recursive inverse a path string where each path segment is separated by a '/'
  ; in:
  ;  s_ptr2 - pointer to the result string
  ;  s_ptr3 - pointer to originary path we have to inverse
  ; out:
  ;  Y - length of the result string (s_ptr2)
  ;
  ; sample: foo/bar/baz is converted to baz/bar/foo
  ;
path_inverse:
    stz s_tmp1
    stz s_tmp2
    ldy #0
    jsr l_inv
    iny
    lda #0
    sta (s_ptr2),y
    rts
l_inv:
    lda (s_ptr3),y
    iny
    cpy s_tmp3
    beq l_seg
    cmp #'/'
    bne l_inv
    phy
    jsr l_inv
    ply
    sty s_tmp1
l_seg:
    ldy s_tmp1
    inc s_tmp1
    lda (s_ptr3),y
    ldy s_tmp2
    inc s_tmp2
    sta (s_ptr2),y
    cmp #'/'
    bne l_seg
    rts
