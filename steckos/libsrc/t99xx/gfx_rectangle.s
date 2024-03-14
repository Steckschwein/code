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

.include "debug.inc"

.include "vdp.inc"
.include "gfx.inc"

.autoimport

.importzp __volatile_ptr

.export gfx_rectangle

;@name: gfx_rectangle
;@desc: draw a rectangle according to data in given rectangle struct
;@in: A/Y ptr to rectangle_t struct
gfx_rectangle:
              sta __volatile_ptr
              sty __volatile_ptr+1

              jsr @setup_line
              ldx __gfx_rect_line+line_t::y1
              stx __gfx_rect_line+line_t::y2
              jsr gfx_line

              jsr @setup_line
              ldx __gfx_rect_line+line_t::y2
              stx __gfx_rect_line+line_t::y1
              jsr gfx_line

              jsr @setup_line
              ldx __gfx_rect_line+line_t::x1
              stx __gfx_rect_line+line_t::x2
              jsr gfx_line

              jsr @setup_line
              ldx __gfx_rect_line+line_t::x2
              stx __gfx_rect_line+line_t::x1
              jmp gfx_line

@setup_line:  ldy #.sizeof(rectangle_t)-1
:             lda (__volatile_ptr),y
              sta __gfx_rect_line,y
              dey
              bpl :-
              lda #<__gfx_rect_line
              ldy #>__gfx_rect_line
              rts
.bss
__gfx_rect_line: .tag line_t