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

.ifdef DEBUG_BLKLAYER ; debug switch for this module
  debug_enabled=1
.endif

.include "common.inc"
.include "errno.inc"

.include "debug.inc"

.export blklayer_init
.export blklayer_read_block;
.export blklayer_write_block;
.export blklayer_write_block_buffered;
.export blklayer_flush;

.autoimport

.importzp sd_blkptr

BLKL_WRITE_PENDING = 1<<7

.struct _blkl_state
  lba_addr  .res 4
  lba_temp  .res 4
  blk_ptr   .res 2
  status    .res 1
.endstruct

blklayer_init:
          m_memset _blkl_0+_blkl_state::lba_addr, $ff, 4
          stz _blkl_0+_blkl_state::status
          rts

blklayer_read_block:
          debug32 "blkl r lba", lba_addr
          debug32 "blkl r lba last", _blkl_0+_blkl_state::lba_addr
;          debug16 "blkl r lba blkptr", _blkl_0+_blkl_state::blk_ptr
          cmp32 _blkl_0+_blkl_state::lba_addr, lba_addr, @l_read

          inc sd_blkptr+1  ; TODO FIXME dev_write_block (sdcard) device driver sideeffect
          lda #EOK
          clc
@l_exit:  rts

@l_read:  jsr blklayer_flush
          bcs @l_exit
          debug32 "blkl lba r miss >", lba_addr
          jsr dev_read_block
          ;cmp #EOK
          bne l_exit_err
__blkl_save_lba_addr:
          stz _blkl_0+_blkl_state::status

          lda lba_addr+0
          sta _blkl_0+_blkl_state::lba_addr+0
          lda lba_addr+1
          sta _blkl_0+_blkl_state::lba_addr+1
          lda lba_addr+2
          sta _blkl_0+_blkl_state::lba_addr+2
          lda lba_addr+3
          sta _blkl_0+_blkl_state::lba_addr+3
          lda #EOK
          clc
          rts
l_exit_err:
          sec
          rts

blklayer_flush:
          bit _blkl_0+_blkl_state::status ; ? pending write
          bpl @l_exit
          debug "blkl flush >"
          m_memcpy lba_addr, _blkl_0+_blkl_state::lba_temp, 4
          m_memcpy _blkl_0+_blkl_state::lba_addr, lba_addr, 4
          jsr dev_write_block
          pha
          m_memcpy _blkl_0+_blkl_state::lba_temp, lba_addr, 4
          pla
          cmp #EOK
          bne l_exit_err
          dec sd_blkptr+1 ; TODO FIXME dev_write_block (sdcard) device driver sideeffect
@l_exit:  clc
          rts

blklayer_write_block:
          debug32 "blkl w rlba", lba_addr
          jsr dev_write_block
          ;cmp #EOK
          beq __blkl_save_lba_addr
          sec
          rts

blklayer_write_block_buffered:
          debug32 "blkl wb rlba", lba_addr
          ;debug32 "blkl w llba", _blkl_0+_blkl_state::lba_addr
          ;debug16 "blkl w lba blkptr", _blkl_0+_blkl_state::blk_ptr
          ;cmp32 _blkl_0+_blkl_state::lba_addr, lba_addr, l_dev_write
          lda #BLKL_WRITE_PENDING
          sta _blkl_0+_blkl_state::status
          lda #EOK
          clc
          rts

.bss
  _blkl_0: .tag _blkl_state
