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

.include "common.inc"
.include "kernel.inc"

.import kernel_start

.segment "LOADER" ; @see kernel.cfg

; system attribute has to be set on file system

src_ptr  = $0
dst_ptr  = $2
   sei ; no irq if we upload from kernel to avoid clash
   ; copy kernel code to kernel_start
   lda #>payload
   sta src_ptr+1
   stz src_ptr

   lda #>kernel_start
   sta dst_ptr+1
   stz dst_ptr

   ldy #0
loop:
   lda (src_ptr),y
   sta (dst_ptr),y
   iny
   bne loop
   lda src_ptr+1
   cmp #>payload_end
   bne @skip
   cpy #<payload_end
   beq end
@skip:
   inc src_ptr+1
   inc dst_ptr+1
   bne loop
end:
   lda #$01
   sta ctrl_port

   ; jump to reset vector
   jmp ($fffc)

.data
payload:
.incbin "kernel.bin"
payload_end:
