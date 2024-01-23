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
;
; int open(const char *name, int flags, ...);

      .include "fcntl.inc"
      .include "errno.inc"
      .include "kernel/kernel_jumptable.inc"

      .export _open
      .destructor closeallfiles, 5

      .import popax
      .import incsp4
      .import ldaxysp,addysp
      .import __oserror
      .importzp tmp3

;--------------------------------------------------------------------------
; _open
.proc  _open
      dey              ; parm count < 4 shouldn't be needed to be checked
      dey              ;     (it generates a c compiler warning)
      dey
      dey
      beq parmok       ; parameter count ok
      jsr addysp       ; fix stack, throw away unused parameters

; Parameters ok. Pop the flags and save them into tmp3

parmok:
      jsr popax        ; Get flags

; Check the flags. We cannot have both, read and write flags set, and we cannot
; open a file for writing without creating it.

      and #(O_RDWR | O_CREAT)
      cmp #O_RDONLY     ; Open for reading?
      beq doread       ; Yes: Branch
      cmp #(O_WRONLY | O_CREAT)  ; Open for writing?
      beq dowrite

; Invalid open mode
      lda #EINVAL

; Error entry. Sets _errno, clears _oserror, returns -1
seterrno:
      jmp __directerrno

; Error entry: Set oserror and errno using error code in A and return -1
oserror:
      jmp __mappederrno

doread:
dowrite:
      sta tmp3  ; save cleanead flags

; Get the filename from stack and parse it. Bail out if is not ok

      jsr popax         ; Get name, ptr low/high in a/x
      ldy tmp3
      jsr krn_open      ; with a/x ptr to path
      bcs oserror       ; Bail out if problem with open

; Done. Return the handle in a/x
      txa               ; offset into fd_area from krn_open
      ldx #0
      stx __oserror     ; Clear _oserror
      rts
.endproc

;--------------------------------------------------------------------------
; closeallfiles: Close all open files.

.proc  closeallfiles

    jmp krn_close_all

.endproc
