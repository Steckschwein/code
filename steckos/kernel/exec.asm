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


; enable debug for this module
.ifdef DEBUG_EXECV
	debug_enabled=1
.endif
.include "common.inc"
.include "kernel.inc"
.include "errno.inc"
.include "fat32.inc"
.include "fcntl.inc"	; from ca65 api

.code

.import fat_fopen, fat_close, fat_fread_byte

.import hexout
.import krn_chrout
.export char_out=krn_chrout

.export execv

; in:
;	A/X - pointer to string with the file path
; out:
;   Z=1 on success, Z=0 and A=<error code> otherwise
execv:
		  ldy #O_RDONLY
        jsr fat_fopen					; A/X - pointer to filename
        bne @l_err_exit

		  jsr fat_fread_byte	; start address low
		  bcc @l_err_exit
		  sta krn_ptr2
		  jsr hexout

		  jsr fat_fread_byte ; start address high
		  bcc @l_err_exit
		  sta krn_ptr2+1
		  jsr hexout

@l:	  jsr fat_fread_byte
			jsr hexout

		  bcc @l_err_exit
		  sta (krn_ptr2),y
		  inc krn_ptr2
		  bne @l
		  inc krn_ptr2+1
		  bne @l

@l_exec_run:
        jsr fat_close			; close after read to free fd, regardless of error

        ; we came here using jsr, but will not rts.
        ; get return address from stack to prevent stack corruption
        pla
        pla
        jmp (krn_ptr2)

@l_err_exit:
			jsr fat_close			; close after read to free fd, regardless of error
     		debug "exec"
        	rts
