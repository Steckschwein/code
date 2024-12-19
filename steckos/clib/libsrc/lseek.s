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
;

; off_t __fastcall__ lseek(int fd, off_t offset, int whence);

.export         _lseek

.autoimport

.include "errno.inc"
.include "asminc/fat32.inc"
.include "kernel/kernel_jumptable.inc"

parmerr:      jsr     incsp6
              ldx     #255
              stx     sreg
              stx     sreg+1
              jmp     __inviocb


; lseek() entry point

.proc   _lseek
              cpx     #0              ; sanity check whence parameter
              bne     parmerr
              cmp     #3              ; valid values are 0..2
              bcs     parmerr
              sta     seek+Seek::Whence

              jsr popax
              sta seek+Seek::Offset+0
              stx seek+Seek::Offset+1
              jsr popax
              sta seek+Seek::Offset+2
              stx seek+Seek::Offset+3

              jsr popax
              stp
              tax
              lda #<seek
              ldy #>seek
              jsr krn_fseek
              bcs @exit

@ret:         lda fd_area+F32_fd::SeekPos+3,x
              sta sreg+1
              lda fd_area+F32_fd::SeekPos+2,x
              sta sreg
              lda fd_area+F32_fd::SeekPos+1,x
              pha
              lda fd_area+F32_fd::SeekPos+0,x
              plx
              clc
@exit:        rts
.endproc

.bss
  seek:
    .tag Seek