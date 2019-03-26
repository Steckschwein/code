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

.include "vdp.inc"

.export vdp_memcpys, vdp_memcpy

.importzp vdp_ptr

.code
;	input:
;  	.X    - amount of 256byte blocks (page counter)
;		.A/.Y - pointer to source data
vdp_memcpy:
      sta vdp_ptr
      sty vdp_ptr+1
      ldy #0
@l0:
      nop
      nop
      nop
      nop
      nop
@l1:
      vdp_wait_l 10+10;3 + 5 + 2 + 1 opcode fetch =10 cl for inner loop, +10 cl outer loop
      lda (vdp_ptr),y ;5
      sta a_vram      ;1
      iny             ;2
      bne @l0         ;3/2
      inc vdp_ptr+1   ;5
      dex             ;2
      bne @l1         ;3
      rts
		
;	input:
;  	.X    - amount of bytes to copy
;   .A/.Y - pointer to data
vdp_memcpys:
      sta vdp_ptr
      sty vdp_ptr+1
      ldy #0
@0:   vdp_wait_l 13	 ;2 + 2 + 3 + 5 + 1 opcode fetch
      lda (vdp_ptr),y ;5
      sta a_vram      ;1+3
      iny             ;2
      dex             ;2
      bne	@0			    ;3
      rts
      