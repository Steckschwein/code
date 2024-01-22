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


.include "steckos.inc"
.include "fcntl.inc"

dump_line_length = $10

BUF_SIZE    = 80 ;TODO maybe too small?
cwdbuf_size = 80
prompt  = '>'



;---------------------------------------------------------------------------------------------------------
; init shell
;  - print welcome message
;---------------------------------------------------------------------------------------------------------

.export char_out=krn_chrout

.autoimport

.zeropage
msg_ptr:  .res 2
bufptr:   .res 2
pathptr:  .res 2
dumpvec:  .res 2
dumpend:  .res 1
tmpchar:  .res 1


appstart __SHELL_START__
.export __APP_SIZE__=kernel_start-__SHELL_START__ ; adjust __APP_SIZE__ for linker accordingly
.code
init:
        jsr primm
        ;.byte 27,"[2J "

        ;.byte 27,"[3B" ; move cursor down 3 lines

        .byte "steckOS shell  "
    ;    .byte 27,"[5D" ; move cursor left 5 pos

        .include "version.inc"
        .byte CODE_LF,0
exit_from_prg:
        cld
        jsr  krn_textui_init

        ldx #BUF_SIZE
:       stz tmpbuf,x
        dex
        bpl :-

        SetVector exit_from_prg, retvec
        SetVector buf, bufptr
        SetVector buf, paramptr ; set param to empty buffer
        SetVector PATH, pathptr
mainloop:
        jsr primm
        .byte CODE_LF, '[', 0

        ; output current path
        lda #<cwdbuf
        ldy #>cwdbuf
        ldx #cwdbuf_size
        jsr krn_getcwd
        bcs @nocwd

        lda #<cwdbuf
        ldx #>cwdbuf
        jsr strout

        bra @prompt
@nocwd:
        lda #'?'
        jsr char_out
@prompt:
        jsr primm
        .byte ']', prompt, 0

        lda crs_x
        sta crs_x_prompt

        ; reset input buffer
        ldy #0
        jsr terminate

  ; put input into buffer until return is pressed
inputloop:
@l_input:

        jsr krn_getkey
        bcc @l_input

        cmp #KEY_RETURN ; return?
        beq parse

        cmp #KEY_BACKSPACE
        beq backspace

        cmp #KEY_ESCAPE
        beq escape

        cmp #KEY_CRSR_UP
        beq key_crs_up

        cmp #KEY_CRSR_DOWN
        beq key_crs_down

        cmp #KEY_FN12
        beq key_fn12

        ; prevent overflow of input buffer
        cpy #BUF_SIZE
        beq inputloop

        sta (bufptr),y
        iny
line_end:
        jsr char_out
        jsr terminate

        bra inputloop

backspace:
        cpy #$00
        beq inputloop
        dey
        bra line_end

escape:
        jsr krn_getkey
        jsr printbuf
        bra inputloop

key_fn12:
        jmp mode_toggle

key_crs_up:
        bra inputloop

key_crs_down:
        bra inputloop

terminate:
        lda #0
        sta (bufptr),y
        rts

parse:
        copypointer bufptr, cmdptr


        ; find begin of command word
@l1:
        lda (cmdptr)  ; skip non alphanumeric stuff
        bne @l2
        jmp mainloop
@l2:
        cmp #' '
        bne @l3
        inc cmdptr
        bra @l1
@l3:
        copypointer cmdptr, paramptr

        ; find begin of parameter (everything behind the command word, separated by space)
        ; first, fast forward until space or abort if null (no parameters then)
@l4:
        lda (paramptr)
        beq @l7
        cmp #' '
        beq @l5
        inc paramptr
        bra @l4
@l5:
  ; space found.. fast forward until non space or null
@l6:
        lda (paramptr)
        beq @l7
        cmp #$20
        bne @l7
        inc paramptr
        bra @l6
@l7:
        SetVector buf, bufptr

        jsr terminate

compare:
      ; compare
        ldx #$00
@l1:
        ldy #$00
@l2:
        lda (cmdptr),y

        ; if not, there is a terminating null
        bne @l3

        cmp cmdlist,x
        beq cmdfound

        ; command string in buffer is terminated with $20 if there are cmd line arguments

@l3:
        cmp #$20
        bne @l4

        cmp cmdlist,x
        bne cmdfound

@l4:
        ; make lowercase
        tolower

        cmp cmdlist,x
        bne @l5  ; difference. this isnt the command were looking for

        iny
        inx

        bra @l2

        ; next cmdlist entry
@l5:
        inx
        lda cmdlist,x
        bne @l5
        inx
        inx
        inx

        lda cmdlist,x
        cmp #$ff
        beq try_exec
        bra @l1

cmdfound:
        inx
        jmp (cmdlist,x) ; 65c02 FTW!!

try_exec:
        lda (bufptr)
        beq @l1

        jmp exec
@l1:  
        jmp mainloop

printbuf:
        ldy #$01
        sty crs_x
        jsr krn_textui_update_crs_ptr

        ldy #$00
@l1:
        lda (bufptr),y
        beq @l2
        sta buf,y
        jsr char_out
        iny
        bra @l1
@l2:
        rts


cmdlist:
        .byte "cd",0
        .word cd

        .byte "rm",0
        .word rm

        .byte "mkdir",0
        .word mkdir

        .byte "rmdir",0
        .word rmdir

        .byte "pwd",0
        .word pwd

        .byte "up",0
        .word krn_upload

        .byte "pd",0
        .word pd

        .byte "bd",0
        .word bd

        .byte "ms",0
        .word ms

        .byte "go",0
        .word go

        .byte "load",0
        .word load


        ; End of list
        .byte $ff



msg_EOK:        .asciiz "No error"
msg_ENOENT:     .asciiz "No such file or directory"
msg_ENOMEM:     .asciiz "Out of memory"
msg_EACCES:     .asciiz "Permission denied"
msg_ENODEV:     .asciiz "No such device"
msg_EMFILE:     .asciiz "Too many open files"
msg_EBUSY:      .asciiz "Device or resource busy"
msg_EINVAL:     .asciiz "Invalid argument (0x07)"
msg_ENOSPC:     .asciiz "No space left on device (0x08)"
msg_EEXIST:     .asciiz "File exists"
msg_EAGAIN:     .asciiz "Try again (0x0a)"
msg_EIO:        .asciiz "I/O error"
msg_EINTR:      .asciiz "Interrupted system call"
msg_ENOSYS:     .asciiz "Function not implemented"
msg_ESPIPE:     .asciiz "Illegal seek"
msg_ERANGE:     .asciiz "Range error"
msg_EBADF:      .asciiz "Bad file number"
msg_ENOEXEC:    .asciiz "Exec format error"
msg_EISDIR:     .asciiz "Is a directory"
msg_ENOTDIR:    .asciiz "Not a directory"
msg_ENOTEMPTY:  .asciiz "Directory not empty"

errors:
.addr msg_EOK
.addr msg_ENOENT
.addr msg_ENOMEM
.addr msg_EACCES
.addr msg_ENODEV
.addr msg_EMFILE
.addr msg_EBUSY
.addr msg_EINVAL
.addr msg_ENOSPC
.addr msg_EEXIST
.addr msg_EAGAIN
.addr msg_EIO
.addr msg_EINTR
.addr msg_ENOSYS
.addr msg_ESPIPE
.addr msg_ERANGE
.addr msg_EBADF
.addr msg_ENOEXEC
.addr msg_EISDIR
.addr msg_ENOTDIR
.addr msg_ENOTEMPTY

errmsg:
        ;TODO FIXME maybe use oserror() from cc65 lib
        cmp #$f1
        bne @l1
        jsr primm
        .byte CODE_LF,"invalid command",CODE_LF,$00
        jmp mainloop

@l1:
        cmp #$f2
        bne @l2
        jsr primm
        .byte CODE_LF,"invalid directory",CODE_LF,$00
        jmp mainloop

@l2:
        cmp #$15
        bcs @l_unknown
        asl
        tax
        lda errors,x
        sta msg_ptr
        lda errors+1,x
        sta msg_ptr+1
        ldy #0
:
        lda (msg_ptr),y
        beq @l_exit
        jsr char_out
        iny
        bne :-
@l_unknown:
        pha
        jsr primm
        .asciiz "unknown error "
        pla
        jsr hexout_s
@l_exit:
        lda #CODE_LF
        jsr char_out
        jmp mainloop

mode_toggle:
        lda video_mode
        eor #VIDEO_MODE_80_COLS
        jsr hexout
        jsr krn_textui_setmode
        jmp mainloop
cd:
        lda paramptr
        ldx paramptr+1
        jsr krn_chdir
        bcc @l2
        jmp errmsg
@l2:
        jmp mainloop


rm:
        lda (paramptr)
        beq @exit

        lda paramptr
        ldx paramptr+1

        jsr krn_unlink
        bcc @exit
        jsr errmsg
@exit:
        jmp mainloop
mkdir:
        lda (paramptr)
        beq @exit

        lda paramptr
        ldx paramptr+1

        jsr krn_mkdir
        bcc @exit
        jsr errmsg
@exit:
        jmp mainloop

rmdir:
        lda (paramptr)
        beq @exit

        lda paramptr
        ldx paramptr+1

        jsr krn_rmdir
        bcc @exit
        jsr errmsg
@exit:
        jmp mainloop

pwd:
        crlf
        lda #<cwdbuf
        ldx #>cwdbuf
        jsr strout
        jmp mainloop


exec:
        lda cmdptr
        ldx cmdptr+1    ; cmdline in a/x

        ; try to chdir
        jsr krn_chdir
        bcs @resolve_path ; branch taken if chdir successful
        jmp mainloop

@resolve_path:
        crlf
        stz tmp2
@try_path:
        ldx #0
        ldy tmp2
@cp_path:
        lda (pathptr), y
        beq @check_path
        cmp #':'
        beq @cp_next
        sta tmpbuf,x
        inx
        iny
        bne @cp_path
        lda #$f0
        jmp errmsg
@check_path:    ;PATH end reached and nothing to prefix
        cpy tmp2
        bne @cp_next_piece  ;end of path, no iny
        lda #$f1        ;nothing found, "Invalid command"
        jmp errmsg
@cp_next:
        iny
@cp_next_piece:
        sty tmp2        ;safe PATH offset, 4 next try
        stz tmp1
        ldy #0
@cp_loop:
        lda (cmdptr),y
        beq @l3
        cmp #'.'
        bne @cp_loop_1
        stx tmp1
@cp_loop_1:
        cmp #' '    ;end of program name?
        beq @l3
        sta tmpbuf,x
        iny
        inx
        bne @cp_loop
@l3:
        lda tmp1
        bne @l4
        ldy #0
@l5:
        lda PRGEXT,y
        beq @l4
        sta tmpbuf,x
        inx
        iny
        bne  @l5
@l4:
        stz tmpbuf,x

        lda #<tmpbuf
        ldx #>tmpbuf    ; cmdline in a/x
        jsr krn_execv   ; return A with errorcode
        bcs @try_path
        lda #$fe
        jmp errmsg

go:
        ldy #0
        jsr hex2dumpvec
        bcs @error

        jmp (dumpvec)
@error:  
        printstring "parameter error"
@end:
        jmp mainloop


ms:
        ldy #0
        jsr hex2dumpvec
        bcs @error 

        iny
        lda (paramptr),y
        beq @error
        cmp #' '
        bne @error

@again:
        crlf
        lda dumpvec+1
        jsr hexout

        lda dumpvec
        jsr hexout 

        lda #':'
        jsr char_out
        lda #' '
        jsr char_out

@skip:
        iny
        lda (paramptr),y
        beq @end
        cmp #' '
        beq @skip 

        tax
 
        iny
        lda (paramptr),y
 
        jsr parse_hex

        sta dumpend 
        jsr hexout

        sta (dumpvec)

        inc16 dumpvec
        bra @again
        jmp mainloop


        beq @error
@error:  
        printstring "parameter error"
@end:
        jmp mainloop


bd:
        ldy #0
        lda (paramptr),y
        tax 
        iny 
        lda (paramptr),y 
        jsr parse_hex       
        sta lba_addr +3

        iny
        lda (paramptr),y
        tax 
        iny 
        lda (paramptr),y 
        jsr parse_hex       
        sta lba_addr +2

        iny
        lda (paramptr),y
        tax 
        iny 
        lda (paramptr),y 
        jsr parse_hex       
        sta lba_addr +1

        iny
        lda (paramptr),y
        tax 
        iny 
        lda (paramptr),y 
        jsr parse_hex       
        sta lba_addr 

        lda #04
        sta dumpvec+1
        stz dumpvec

        lda #05 
        sta dumpend
        copypointer dumpvec, sd_blkptr

        jsr krn_sd_read_block
        bcs @err
        jmp dump_start
@err:
        jmp errmsg


pd:
        ldy #0
        lda (paramptr),y
        beq @error
       
        stz dumpvec+0
        ; stz dumpvec+1

        tax 
        iny
        lda (paramptr),y
        beq @error

        jsr parse_hex

        sta dumpvec+1
        sta dumpend

        iny 
        lda (paramptr),y 
        beq dump_start

        iny 
        lda (paramptr),y
        tax

        sta dumpend
        
        iny
        lda (paramptr),y
        beq @error

        jsr parse_hex
        
        sta dumpend
        crlf
        bra dump_start

@error:  
        printstring "parameter error"
        jmp mainloop
dump_start:
        crlf
        lda #<pd_header
        ldx #>pd_header
        jsr strout

        ldx #256 / dump_line_length
@output_line:
        crlf

        lda dumpvec+1
        jsr hexout
        lda dumpvec
        jsr hexout

        lda #':'
        jsr char_out
        lda #' '
        jsr char_out

        ldy #$00
@out_hexbyte:
        lda (dumpvec),y
        jsr hexout
        lda #' '
        jsr char_out
        iny
        cpy #dump_line_length
        bne @out_hexbyte

        lda #' '
        jsr char_out

        ldy #$00
@out_char:  
        lda (dumpvec),y
        cmp #$19 ; printable character?
        bcs :+   ; 
        lda #'.' ; no, just print '.'
:                ; yes, print it
        jsr char_out
        iny
        cpy #dump_line_length
        bne @out_char

        ; update dumpvec
        clc
        tya 
        adc dumpvec
        sta dumpvec
 
        dex 
        bne @output_line

        lda dumpvec+1
        cmp dumpend
        beq @l8
        jsr primm
        .byte $0a,$0d,"-- press a key-- ",$00
        
        keyin
        cmp #KEY_CTRL_C
        beq @l8
        cmp #KEY_ESCAPE
        beq @l8

        inc dumpvec+1
        jmp dump_start
@l8:  
        jmp mainloop

load:
        ldy #0
        ldx #0
@read_filename:
        lda (paramptr),y
        beq @read_filename_done
        cmp #' '
        beq @read_filename_done
        sta filenamebuf,x
        iny 
        inx
        bne @read_filename

@read_filename_done:
        stz filenamebuf,x 

        ; skip space
        lda (paramptr),y 
        cmp #' '
        bne :+
        iny
:

        jsr hex2dumpvec
        bcs @err

        lda #<filenamebuf
        ldx #>filenamebuf
        ldy #O_RDONLY
        jsr krn_open     ; X contains fd
        bcs @err    ; not found or other error, dont care...
        ldy #0
:
        jsr krn_fread_byte
        bcs @eof
        sta (dumpvec)
        inc16 dumpvec
        bne :-
@eof:
        jsr krn_close
@end:
        jmp mainloop
@err:
        crlf
        jmp errmsg

; parse two hex digits to binary
; highbyte in X
; lowbyte in A
; returns A
parse_hex:
        pha 
        txa
        jsr atoi
        asl
        asl
        asl
        asl
        sta tmpchar
        pla 
        jsr atoi
        ora tmpchar
        rts

hex2dumpvec:
        ; ldy #0
        lda (paramptr),y
        beq @err
        stz dumpvec+0
        tax
        
        iny
        lda (paramptr),y
        beq @err
        
        jsr parse_hex
        sta dumpvec+1

        iny
        lda (paramptr),y
        beq @err
        tax 

        iny
        lda (paramptr),y
        beq @err
   
        jsr parse_hex
        sta dumpvec
        clc 
        rts
@err:
        sec
        rts


.data
PATH: .asciiz ".:/steckos/:/progs/"
PRGEXT: .asciiz ".PRG"
pd_header: .asciiz "####   0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F  0123457890ABCDEF"


.bss
crs_x_prompt:     .res 1
tmpbuf:           .res BUF_SIZE
buf:              .res BUF_SIZE
cwdbuf:           .res cwdbuf_size
filenamebuf:      .res 12
tmp1:     .res 1
tmp2:     .res 1
