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
.include "blklayer.inc"

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
  blk_lba .dword
  blk_ptr .word
  tmp_lba .dword
  tmp_ptr .word
  status  .byte
.endstruct

blklayer_init:
          m_memset _blkl_store+_blkl_state::blk_lba, $ff, 4
          stz _blkl_store+_blkl_state::status
          rts

blklayer_read_block:
;          debug32 "bl r lba", lba_addr
 ;         debug32 "bl r lba last", _blkl_store+_blkl_state::blk_lba
;          debug16 "bl r lba blkptr", _blkl_store+_blkl_state::blk_ptr
          ldx #0
          _block_loaded @l_read

          inc sd_blkptr+1  ; fake ptr change - TODO FIXME dev_read_block (sdcard) device driver sideeffect
          lda #EOK
          clc
@l_exit:  rts

@l_read:
          debug32 "bl r miss >", lba_addr
          jsr blklayer_flush
          bcs @l_exit
          debug32 "bl r sdpt", sd_blkptr
          jsr dev_read_block
          ;cmp #EOK
          bne l_exit_err
__blkl_save_lba_addr:
          stz _blkl_store+_blkl_state::status

          m_memcpy lba_addr, _blkl_store+_blkl_state::blk_lba, 4
          lda sd_blkptr
          sta _blkl_store+_blkl_state::blk_ptr
          lda sd_blkptr+1
          dea ; TODO FIXME sd block interface
          sta _blkl_store+_blkl_state::blk_ptr+1
          lda #EOK
          clc
          rts

blklayer_write_block:
          debug32 "bl w rlba", lba_addr
          jsr dev_write_block
          ;cmp #EOK
          beq __blkl_save_lba_addr
l_exit_err:
          sec
          rts

blklayer_flush:
          bit _blkl_store+_blkl_state::status ; ? pending write
          bpl @l_exit
          debug32 "bl fl l >", _blkl_store+_blkl_state::blk_lba
          debug16 "bl fl r", sd_blkptr
          debug16 "bl fl l", _blkl_store+_blkl_state::blk_ptr

          m_memcpy lba_addr, _blkl_store+_blkl_state::tmp_lba, 4
          lda sd_blkptr
          sta _blkl_store+_blkl_state::tmp_ptr
          lda sd_blkptr+1
          sta _blkl_store+_blkl_state::tmp_ptr+1

          m_memcpy _blkl_store+_blkl_state::blk_lba, lba_addr, 4
          lda _blkl_store+_blkl_state::blk_ptr
          sta sd_blkptr
          lda _blkl_store+_blkl_state::blk_ptr+1
          sta sd_blkptr+1
          jsr dev_write_block
          pha
          m_memcpy _blkl_store+_blkl_state::tmp_lba, lba_addr, 4
          lda _blkl_store+_blkl_state::tmp_ptr
          sta sd_blkptr
          lda _blkl_store+_blkl_state::tmp_ptr+1
          sta sd_blkptr+1
          pla
          cmp #EOK
          bne l_exit_err
@l_exit:  clc
          rts

blklayer_write_block_buffered:
          ;debug32 "bl wb rlba", lba_addr
          ;debug32 "bl wb l", _blkl_store+_blkl_state::blk_lba
          ;debug16 "bl fl r", sd_blkptr
          ;debug16 "bl wb l", _blkl_store+_blkl_state::blk_ptr
          ;cmp32 _blkl_store+_blkl_state::blk_lba, lba_addr, @l_err
          ;cmp16 _blkl_store+_blkl_state::blk_ptr, sd_blkptr, @l_err
          lda #BLKL_WRITE_PENDING
          sta _blkl_store+_blkl_state::status
          lda #EOK
          clc
          rts
@l_err:
          sec
          rts

.bss
  _blkl_store:
    .tag _blkl_state  ; fat32 currently uses $400/$600 as fixed block address - so we only need 2 states
    .tag _blkl_state
