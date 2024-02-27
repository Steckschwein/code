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

prompt  = '.'

.include "steckos.inc"

; SCREENSAVER_TIMEOUT_MINUTES=2
BUF_SIZE    = 80 ;TODO maybe too small?

dumpvec    = $c0
dumpvec_end     = dumpvec
dumpvec_start   = dumpvec+2


;---------------------------------------------------------------------------------------------------------
; init shell
;  - print welcome message
;---------------------------------------------------------------------------------------------------------

.export char_out=krn_chrout

.autoimport

.zeropage
bufptr:         .res 2
; pathptr:        .res 2
; p_history:      .res 2
; tmp1:   .res 1
; tmp2:   .res 1


appstart $1000

.code
init:


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
mainloop:
        
        lda #prompt
        jsr krn_chrout
        .byte prompt, 0

        lda crs_x
        sta crs_x_prompt

        ; reset input buffer
        ldy #0
        jsr terminate

  ; put input into buffer until return is pressed
inputloop:
        ; jsr screensaver_settimeout  ;reset timeout
@l_input:
        ; jsr screensaver_loop

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


key_crs_up:
;        jsr history_back
        bra inputloop

key_crs_down:
;        jsr history_frwd
        bra inputloop

terminate:
        lda #0
        sta (bufptr),y
        rts

parse:
        copypointer bufptr, cmdptr

        ;jsr history_push

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
@l1:    ldy #$00
@l2:  lda (cmdptr),y

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
        ora #$20

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
        beq @l1
        bra @l1

cmdfound:
        crlf
        inx
        jmp (cmdlist,x) ; 65c02 FTW!!


@l1:  jmp mainloop


printbuf:
        ldy #$01
        sty crs_x
        jsr krn_textui_update_crs_ptr

        ldy #$00
@l1:  lda (bufptr),y
        beq @l2
        sta buf,y
        jsr char_out
        iny
        bra @l1
@l2:  rts


cmdlist:
        .byte "cd",0
        .word cd

        .byte "up",0
        .word krn_upload

        .byte "m",0
        .word dump
  ; End of list
  .byte $ff

atoi:
  cmp #'9'+1
  bcc @l1   ; 0-9?
  ; must be hex digit
  adc #$08
  and #$0f
  rts

@l1:  sec
  sbc #$30
  rts



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
  jsr primm
  .byte CODE_LF,"unknown error",CODE_LF,$00
  jmp mainloop

cd:
        lda paramptr
        ldx paramptr+1
        jsr krn_chdir
        beq @l2
        jmp errmsg
@l2:
        jmp mainloop



dump:
        stz dumpvec+1
        stz dumpvec+2
        stz dumpvec+3

        ldy #$00
        ldx #$03
@l1:
        lda (paramptr),y
        beq @l2

        jsr atoi
        asl
        asl
        asl
        asl
        sta dumpvec,x

        iny
        lda (paramptr),y
        beq @l2
        jsr atoi
        ora dumpvec,x
        sta dumpvec,x
        dex
        iny
        cpy #$04
        bne @l1

        iny
        bra @l1

@l2:  cpy #$00
        bne @l3

        printstring "parameter error"

        bra @l8
@l3:
        crlf
        lda dumpvec_start+1
        jsr hexout
        lda dumpvec_start
        jsr hexout
        lda #':'
        jsr char_out
        lda #' '
        jsr char_out

        ldy #$00
@l4:
        lda (dumpvec_start),y
        jsr hexout
        lda #' '
        jsr char_out
        iny
        cpy #$08
        bne @l4

        lda #' '
        jsr char_out

        ldy #$00
@l5:  lda (dumpvec_start),y
        cmp #$19
        bcs @l6
        lda #'.'
@l6:  jsr char_out
        iny
        cpy #$08
        bne @l5

        lda dumpvec_start+1
        cmp dumpvec_end+1
        bne @l7
        lda dumpvec_start
        cmp dumpvec_end
        beq @l8
        bcs @l8

@l7:
        jsr krn_getkey
        cmp #$03
        beq @l8
        clc
        lda dumpvec_start

        adc #$08
        sta dumpvec_start
        lda dumpvec_start+1
        adc #$00
        sta dumpvec_start+1
        bra @l3

@l8:  jmp mainloop


.bss
crs_x_prompt:     .res 1
tmpbuf:           .res BUF_SIZE
buf:              .res BUF_SIZE
cwdbuf_size=80
cwdbuf:           .res cwdbuf_size
