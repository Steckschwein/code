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
; int write (int fd, const void* buf, unsigned count);
;
      .include "zeropage.inc"
      .include "errno.inc"
      .include "kernel/kernel_jumptable.inc"

      .export      _write
      .constructor   initstdout

      .import popax,popptr1
      .import  _cputc
      .importzp ptr1
      .importzp tmp1

;--------------------------------------------------------------------------
; initstdout: Open the stdout and stderr file descriptors for the screen.

.segment "ONCE"
.proc  initstdout
  rts
.endproc

;--------------------------------------------------------------------------
.proc   _write

    pha
    phx
    ; count
    sta tmp1 ; 8bit length string only - TODO
    ; *buf
    jsr popax
    sta ptr1
    stx ptr1+1
    ; fd
    jsr popax ; assume stdout, ignore fd
    plx
    pla
    cmp #0 ; shortcut, zero length?
    bne @li
    cpx #0
    beq @exit
@li:
    ldy #0
@l0:
    lda (ptr1),y
    beq @exit
    jsr _cputc
    iny
    cpy tmp1
    bne @l0
@lex:
    tya
    ldx #0
@exit:
    rts
.endproc

.proc   _write_io
    sta ptr3
    eor #$FF        ; the count argument
    sta ptr2
    txa
    sta ptr3+1
    eor #$FF
    sta ptr2+1      ; Remember -count-1

    jsr popptr1     ; get pointer to buf

    jsr popax       ; the fd handle
    cpx #0          ; high byte must be 0
    bne invalidfd

    tax            ; fd to x

; write bytes loop
@0:
    inc ptr2       ; count bytes read ?
    bne @1
    inc ptr2+1
    beq @exit
@1:
    jsr krn_write_byte
    bcs @error

    sta (ptr1)  ; save byte

    inc ptr1
    bne @0
    inc ptr1+1
    bra @0

; set _oserror and return the number of bytes read
@error:
    sta __oserror
;    jmp __directerrno  ; Sets _errno, clears _oserror, returns -1
@exit:
    clc          ; calc count bytes read
    lda ptr2
    adc ptr3
    pha
    lda ptr2+1
    adc ptr3+1
    tax
    pla
    rts

; Error entry: The given file descriptor is not valid or not open

invalidfd:
      lda    #EBADF
      jmp    __directerrno  ; Sets _errno, clears _oserror, returns -1

.endproc
