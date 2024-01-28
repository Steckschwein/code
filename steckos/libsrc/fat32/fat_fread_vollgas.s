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

@l_blockstart:
          lda fd_area+F32_fd::SeekPos+1,x
          and #$01
          ora fd_area+F32_fd::SeekPos+0,x
          beq @l_read_blocks

          jsr fat_fread_byte
          bcs @l_exit

          sta (p_data)
          inc p_data
          bne @l_blockstart
          inc p_data+1
          bra @l_blockstart

@l_read_blocks:
          lda fd_area + F32_fd::FileSize + 2,x
          lsr
          lda fd_area + F32_fd::FileSize + 1,x
          ror
          tay
          lda fd_area + F32_fd::FileSize + 0,x
          beq @l_exit
          iny

          lda p_data
          ldy p_data+1
          jsr __fat_prepare_block_access_read

          inc p_data+1
          inc p_data+1

          lda #<sd_blocksize
          ldy #>sd_blocksize
          jsr __fat_add_seekpos

;    _cmp32_x fd_area+F32_fd::SeekPos, fd_area+F32_fd::FileSize, :+
@l_exit:
          rts
