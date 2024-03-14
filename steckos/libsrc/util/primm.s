; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschein.de
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

.export primm
.import char_out

.segment "ZEROPAGE_LIB": zeropage
   DPL: .res 1
   DPH: .res 1

.code

; put the string following in-line until a NULL out to the console
;
primm:
   pla			; Get the low part of "return" address (data start address)
   sta     DPL
   pla
   sta     DPH             ; Get the high part of "return" address (data start address)
   ; Note: actually we're pointing one short
PSINB:
   ldy     #1
   lda     (DPL),y         ; Get the next string character
   inc     DPL             ; update the pointer
   bne     PSICHO          ; if not, we're pointing to next character
   inc     DPH             ; account for page crossing
PSICHO:
   ora     #0              ; Set flags according to contents of Accumulator
   beq     PSIX1           ; don't print the final NULL
   jsr     char_out         ; write it out
   bra     PSINB           ; back around
PSIX1:
   inc     DPL             ;
   bne     PSIX2           ;
   inc     DPH             ; account for page crossing
PSIX2:
   jmp     (DPL)           ; return to byte following final NULL
