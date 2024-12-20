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

; int __fastcall__ read(int fd, void *buf, int count)

.include "fcntl.inc"
.include "errno.inc"
.include "kernel/kernel_jumptable.inc"
.include "asminc/zeropage.inc"
.include "asminc/common.inc"

;.import __rwsetup,__do_oserror,__inviocb,__oserror, popax, popptr1
.import popax, popptr1, __oserror
.importzp tmp1
.importzp ptr1,ptr2,ptr3

.export _read

;--------------------------------------------------------------------------
; _read
.code

.proc  _read
        sta ptr2        ; the count argument
        stx ptr2+1

        jsr popptr1     ; get pointer to buf

        jsr popax       ; the fd handle
        cpx #0          ; high byte must be 0
        bne invalidfd

        sta tmp1        ; save fd

        stz     ___oserror

        ; Set counter to zero
        stz     ptr3
        stz     ptr3+1

        lda ptr2
        ora ptr2+1
        beq @check

@next:  ; read bytes loop
        ldx tmp1
        jsr krn_fread_byte
        bcs @eof

        sta (ptr1)  ; save byte

        ; Increment pointer
        inc ptr1
        bne :+
        inc ptr1+1

        ; Increment counter
:       inc     ptr3
        bne     @check
        inc     ptr3+1

        ; Check for counter less than count
@check: lda     ptr3
        cmp     ptr2
        bcc     @next
        ldx     ptr3+1
        cpx     ptr2+1
        bcc     @next
        ; Return success, AX already set
        rts

; set _oserror and return the number of bytes read
@eof:   sta ___oserror
        lda ptr3
        ldx ptr3+1
        rts

; Error entry: The given file descriptor is not valid or not open

invalidfd:
        lda    #EBADF
        jmp    ___directerrno  ; Sets _errno, clears _oserror, returns -1

.endproc
