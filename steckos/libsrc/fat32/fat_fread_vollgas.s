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

;@module: fat32

.ifdef DEBUG_FAT32 ; debug switch for this module
  debug_enabled=1
.endif

.include "zeropage.inc"
.include "common.inc"
.include "fat32.inc"
.include "errno.inc"  ; from ca65 api
.include "fcntl.inc"  ; from ca65 api
.include "stdio.inc"  ; from ca65 api

.include "debug.inc"

.autoimport

.export fat_fread_vollgas

.segment "ZEROPAGE_LIB": zeropage
  p_data: .res 2

.code

;@desc: read the file denoted by given file descriptor (X) until EOF and store data at given address (A/Y)
;@name: fat_fread_vollgas
;@in: X - offset into fd_area
;@in: A/Y - pointer to target address
;@out: C=0 on success, C=1 on error and A="error code" or C=1 and A=0 (EOK) if EOF is reached
fat_fread_vollgas:
          _is_file_open   ; otherwise rts C=1 and A=#EINVAL
          _is_file_dir    ; otherwise rts C=1 and A=#EISDIR

          sta p_data
          sty p_data+1

          jsr @read_end_of_block_or_file
          debug16 "frv 0", p_data
          bcs @l_exit

          lda fd_area + F32_fd::FileSize + 1,x
          and #$80
          ora fd_area + F32_fd::FileSize + 2,x
          ora fd_area + F32_fd::FileSize + 3,x
          bne @l_err_range                      ; file too big >32k

          ; (filesize - seek pos) / $200 (block size) gives amount of blocks to read
          sec
          lda fd_area + F32_fd::FileSize + 1,x
          sbc fd_area + F32_fd::SeekPos + 1,x
          lsr
          tay
          debug16 "frv blocks", p_data
          beq @read_bytes  ; read remaining bytes and exit

@l_read_blocks:
          phy
          lda p_data
          ldy p_data+1
          clc
          jsr __fat_prepare_block_access

          inc p_data+1
          inc p_data+1

          lda #<sd_blocksize
          ldy #>sd_blocksize
          jsr __fat_add_seekpos
          ply
          dey
          bne @l_read_blocks

          jsr @read_bytes
          bcs @l_exit
;    _cmp32_x fd_area+F32_fd::SeekPos, fd_area+F32_fd::FileSize, :+
          debug16 "fread vollgas <", p_data
@l_exit_ok:
          clc
@l_exit:
          rts
@l_err_range:
          lda #ERANGE
@l_exit_eof:
          sec
          rts

; at beginning we need to read until we are block aligned
; and after blocks where read we read the remaining bytes until eof
@read_end_of_block_or_file:
          lda fd_area+F32_fd::SeekPos+1,x     ; read until we are block aligned (multiple of $200)
          and #$01
          ora fd_area+F32_fd::SeekPos+0,x
          beq @l_exit_ok

@read_bytes:
          jsr fat_fread_byte                  ; ... or end of file is reached
          bcs @l_exit

          sta (p_data)
          inc p_data
          bne @read_end_of_block_or_file
          inc p_data+1
          bra @read_end_of_block_or_file

