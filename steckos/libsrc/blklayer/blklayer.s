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
.export blklayer_flush;

.autoimport

.struct _blkl_state
  lba_addr  .res 4
  blk_ptr   .res 2
  status    .res 1
.endstruct

blklayer_init:
          m_memset _blkl_0+_blkl_state::lba_addr, $ff, 4
          stz _blkl_0+_blkl_state::status
          rts

blklayer_read_block:
          debug32 "blkl lba", lba_addr
          debug32 "blkl lba last", _blkl_0+_blkl_state::lba_addr
          debug16 "blkl lba blkptr", _blkl_0+_blkl_state::blk_ptr
          cmp32 _blkl_0+_blkl_state::lba_addr, lba_addr, @l_read
          lda #EOK
          rts
@l_read:
          jsr dev_read_block
          sec
          bne :+
@l_save_lba_addr:
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
:         rts


blklayer_write_block:
          jmp dev_write_block

blklayer_flush:
          clc
          rts

.bss
  _blkl_0: .tag _blkl_state
