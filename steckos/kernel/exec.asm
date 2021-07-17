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

.import fat_fopen, fat_read, fat_close, fat_read_block, sd_read_multiblock, __inc_lba_address

.export execv

; in:
;	A/X - pointer to string with the file path
; out:
;   Z=1 on success, Z=0 and A=<error code> otherwise
execv:
        ldy #O_RDONLY
        jsr fat_fopen					; A/X - pointer to filename
        bne @l_err_exit

		  SetVector block_data, read_blkptr
		  phx ; save fd in x register for fat_close
		  jsr fat_read_block

		  lda block_data
		  sta krn_ptr1
		  clc
		  adc #$fe
		  sta read_blkptr

		  lda block_data+1
		  sta krn_ptr1+1
		  inc
		  sta read_blkptr+1

		  ldy #0
@l:
		  lda block_data+2,y
		  sta (krn_ptr1),y
		  iny
		  bne @l

		  inc krn_ptr1+1
@l2:
		  lda block_data+$100+2,y
		  sta (krn_ptr1),y
		  iny
		  cpy #$fe
		  bne @l2
		  dec krn_ptr1+1

		  jsr __inc_lba_address
		  dec blocks
		  beq @l_exec_run

        jsr sd_read_multiblock

@l_exec_run:

        plx
        jsr fat_close			; close after read to free fd, regardless of error

        ; we came here using jsr, but will not rts.
        ; get return address from stack to prevent stack corruption
        pla
        pla
        jmp (krn_ptr1)

@l_err_exit:
        debug "exec"
        rts
