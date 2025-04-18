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

;@module: vdp

.setcpu "6502"

.include "vdp.inc"

.export vdp_memcpys, vdp_memcpy

.importzp vdp_ptr

.code

;@name: vdp_memcpy
;@desc: copy data from host memory denoted by pointer (A/Y) to vdp VRAM (page wise). the VRAM address must be setup beforehand e.g. with macro vdp_vram_w <address>
;@in: X - amount of 256byte blocks (page counter)
;@in: A/Y - pointer to source data
vdp_memcpy:
              sta vdp_ptr
              sty vdp_ptr+1
              ldy #0
:             vdp_wait_l 10 ;3 + 5 + 2 + 1 opcode fetch =10 cl for inner loop, +10 cl outer loop
              lda (vdp_ptr),y ;5
              sta a_vram    ;1
              iny         ;2
              bne :-
              inc vdp_ptr+1  ;5
              dex         ;2
              bne :-
              rts

;@name: vdp_memcpys
;@desc: copy memory to vdp VRAM page wise
;@in: X - amount of bytes to copy
;@in: A/Y - pointer to data
vdp_memcpys:
            sta vdp_ptr
            sty vdp_ptr+1
            ldy #0
@0:         vdp_wait_l 13   ;2 + 2 + 3 + 5 + 1 opcode fetch
            lda (vdp_ptr),y ;5
            sta a_vram    ;1+3
            iny         ;2
            dex         ;2
            bne  @0         ;3
            rts
