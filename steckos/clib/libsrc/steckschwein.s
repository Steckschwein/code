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

.include "asminc/system.inc"

.export _sys_reset
.export _sys_slot_get
.export _sys_slot_set

.import popa

; extern void __fastcall__ sys_reset();
.proc _sys_reset
              jmp (SYS_VECTOR_RESET)
.endproc

; extern void __fastcall__ sys_slot_set(Slot, unsigned char);
.proc _sys_slot_set
              and #$9f
              tax
              jsr popa
              tay
              txa
              sta ctrl_port,y
              rts
.endproc

; extern unsigned char __fastcall__ sys_slot_get(Slot);
.proc _sys_slot_get
              and #$03
              tay
              lda ctrl_port,y
              ldx #0
              rts
.endproc
