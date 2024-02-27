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
.ifndef _BLKLAYER_INC_
  _BLKLAYER_INC_ = 1

; Z=1 if equal, Z=0 otherwise and branch to given label
;
.macro _blkl_cmp32_x op1, op2, _label
   lda op1+0, x
   cmp op2+0
   bne _label
   lda op1+1, x
   cmp op2+1
   bne _label
   lda op1+2, x
   cmp op2+2
   bne _label
   lda op1+3, x
   cmp op2+3
   bne _label
.endmacro

.macro _blkl_cmp16_x op1, op2, _label
  lda op1+0, x
  cmp op2+0
  bne _label
  lda op1+1, x
  cmp op2+1
  bne _label
.endmacro

.macro _block_loaded _label
  _blkl_cmp32_x _blkl_store+_blkl_state::blk_lba, lba_addr, _label
  _blkl_cmp16_x _blkl_store+_blkl_state::blk_ptr, sd_blkptr, _label
.endmacro

.endif  ; _BLKLAYER_INC_
