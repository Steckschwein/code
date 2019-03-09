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

.export vdp_fills, vdp_fill

.code
vdp_fill:
;	in:
;		.A - byte to fill
;		.X - amount of 256byte blocks (page counter)
        ldy #0
@0:     nop
@1:     vdp_wait_l 8
        iny             ;2
        sta a_vram
        bne @0          ;3
        dex
        bne @1
        vdp_wait_l 12
        rts
	
vdp_fills:
;	in:
;   .A - value to write
;		.X - amount of bytes
@0:	  vdp_wait_l 6   ;3 + 2 + 1 opcode fetch
      dex            ;2
      sta a_vram     ;4
      bne	@0         ;3
      vdp_wait_l 8
      rts
