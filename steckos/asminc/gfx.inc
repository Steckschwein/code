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
.ifndef _GFX_INC_
  _GFX_INC_ = 1

; DC = destination color - the color we want to set
; SC = source color - the source color currently set at the target position
GFX_OP_IMP = 0    ; DC = SC
GFX_OP_AND = 1    ; DC = SC & DC
GFX_OP_OR  = 2    ; DC = SC | DC
GFX_OP_XOR = 3    ; DC = SC ^ DC
GFX_OP_NOT = 4    ; DC = !SC

GFX_OP_TIMP = 8   ; SC = 0 => DC = DC; DC = SC otherwise
GFX_OP_TAND = 9   ; SC = 0 => DC = DC; DC = SC & DC otherwise
GFX_OP_TOR  = 10  ; SC = 0 => DC = DC; DC = SC | DC otherwise
GFX_OP_TXOR = 11  ; SC = 0 => DC = DC; DC = SC ^ DC otherwise
GFX_OP_TNOT = 12  ; SC = 0 => DC = DC; DC = !SC otherwise

.struct plot_t
   x1 .word ; 0..511 - depends on active screen mode
   y1 .word ; 0..211
   color .byte
   operator .byte ; one of IMP, AND, OR, XOR, NOT - use GFX_OP_xxx
.endstruct

.struct line_t
   x1 .word ; 0..511 - depends on active screen mode
   y1 .word ; 0..211
   x2 .word ;
   y2 .word ;
   color .byte
   operator .byte ; one of IMP, AND, OR, XOR, NOT - use GFX_OP_xxx
.endstruct

.struct circle_t
   x1 .word ; 0..511 - depends on active screen mode
   y2 .byte ; 0..211
   radius .byte ; 0..211
   color .byte  ; color
   operator .byte ; one of IMP, AND, OR, XOR, NOT - use GFX_OP_xxx
.endstruct

.endif ;_GFX_INC_
