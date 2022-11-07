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
.include "appstart.inc"

.import kernel_start

; system attribute has to be set on file system
.zeropage
p_src:		.res 2
p_tgt:		.res 2

appstart $1000

   lda #$31 ; enable RAM at $c000
   sta ctrl_port+2

   sei ; no irq if we upload from kernel to avoid clash
   ; copy kernel code to kernel_start
   lda #>payload
   sta p_src+1
   stz p_src

   lda #>$8000
   sta p_tgt+1
   stz p_tgt

   ldy #0
loop:
   lda (p_src),y
   sta (p_tgt),y
   iny
   bne loop
   lda p_src+1
   cmp #>payload_end
   bne @skip
   cpy #<payload_end
   beq end
@skip:
   inc p_src+1
   inc p_tgt+1
   bne loop
end:

   sei
   lda #$02 ; enable RAM at $c000
   sta ctrl_port+2

   lda #$31 ; enable RAM at $c000
   sta ctrl_port+3

   ; jump to reset vector
   jmp ($fffc)

.data
payload:
.incbin "kernel.bin"
payload_end:
