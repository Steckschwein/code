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
.setcpu "65c02"

prompt  = $af

.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "vdp.inc"
.include "common.inc"
.include "keyboard.inc"
.include "rtc.inc"
.include "appstart.inc"

; SCREENSAVER_TIMEOUT_MINUTES=2
BUF_SIZE		= 80 ;TODO maybe too small?


;---------------------------------------------------------------------------------------------------------
; init shell
;  - print welcome message
;---------------------------------------------------------------------------------------------------------

.export char_out=krn_chrout

.zeropage
bufptr:         .res 2
pathptr:        .res 2
p_history:      .res 2
tmp1:   .res 1
tmp2:   .res 1

.import hexout
.import kernel_start

appstart $e400
.export __APP_SIZE__=kernel_start-__APP_START__ ; adjust __APP_SIZE__ for linker accordingly

init:
        jsr krn_primm
        .byte "steckOS shell  "
        .include "version.inc"
        .byte CODE_LF,0
exit_from_prg:
        cld
        jsr	krn_textui_init

        ldx #BUF_SIZE
:       stz tmpbuf,x
        dex
        bpl :-

        SetVector exit_from_prg, retvec
        SetVector buf, bufptr
        SetVector buf, paramptr ; set param to empty buffer
        SetVector PATH, pathptr
mainloop:
        jsr krn_primm
        .byte CODE_LF, '[', 0
        ; output current path
        lda #<cwdbuf
        ldx #>cwdbuf
        ldy #cwdbuf_size
        jsr krn_getcwd
        bne @nocwd

        lda #<cwdbuf
        ldx #>cwdbuf
        jsr krn_strout
        bra @prompt
@nocwd:
        lda #'?'
        jsr char_out
@prompt:
        jsr krn_primm
        .byte ']', prompt, 0

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
        lda (cmdptr)	; skip non alphanumeric stuff
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
@l1:	ldy #$00
@l2:	lda (cmdptr),y

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
        bne @l5	; difference. this isnt the command were looking for

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
        crlf
        inx
        jmp (cmdlist,x) ; 65c02 FTW!!

try_exec:
        lda (bufptr)
        beq @l1

        crlf
        jmp exec

@l1:	jmp mainloop

history_frwd:
        lda p_history
        ;cmp #<(history+$0100)
        cmp p_history
        bne @inc_hist_ptr
        lda p_history+1
        ;cmp #>(history+$0100)
        cmp p_history+1
        bne @inc_hist_ptr
        rts
@inc_hist_ptr:
        lda p_history
        clc
        adc #BUF_SIZE
        sta p_history
        bra history_peek

history_back:
        lda p_history+1
        cmp #>history
        bne @dec_hist_ptr
        lda p_history
        cmp #<history
        bne @dec_hist_ptr
        rts
@dec_hist_ptr:
        sec ;dec hist ptr
        sbc #BUF_SIZE
        sta p_history

history_peek:
        lda crs_x_prompt
        sta crs_x
        jsr krn_textui_update_crs_ptr

        ldy #0
        ldx #BUF_SIZE
:       lda (p_history), y
        sta (bufptr), y
        beq :+
        jsr char_out
        iny
        dex
        bpl :-

:       phy       ;safe y pos in buffer
        ldy crs_x ;safe crs_x position after restored cmd to y

        lda #' '  ;erase the rest of the line
:
        jsr char_out
        dex
        bpl :-
        sty crs_x
        jsr krn_textui_update_crs_ptr
        ply       ;restore y buffer index
        rts

history_push:
        lda #CODE_LF
        ;jsr char_out

        tya
        tax
        ldy #0
:       lda (bufptr), y
        sta (p_history), y
        ;jsr char_out
        iny
        dex
        bpl :-

        lda #CODE_LF
        ;jsr char_out

        lda p_history   ; new end
        clc
        adc #BUF_SIZE
        sta p_history
        rts

printbuf:
        ldy #$01
        sty crs_x
        jsr krn_textui_update_crs_ptr

        ldy #$00
@l1:	lda (bufptr),y
        beq @l2
        sta buf,y
        jsr char_out
        iny
        bra @l1
@l2:	rts


cmdlist:
        .byte "cd",0
        .word cd

        .byte "up",0
        .word krn_upload

.ifdef DEBUG
        .byte "dump",0
	.word dump
.endif
	; End of list
	.byte $ff

.ifdef DEBUG

atoi:
	cmp #'9'+1
	bcc @l1 	; 0-9?
	; must be hex digit
	adc #$08
	and #$0f
	rts

@l1:	sec
	sbc #$30
	rts
.endif


errmsg:
	;TODO FIXME maybe use oserror() from cc65 lib
	cmp #$f1
	bne @l1

	jsr krn_primm
	.byte CODE_LF,"invalid command",CODE_LF,$00
	jmp mainloop

@l1:
        cmp #$f2
	bne @l2

	jsr krn_primm
	.byte CODE_LF,"invalid directory",CODE_LF,$00
	jmp mainloop

@l2:
	jsr krn_primm
	.byte CODE_LF,"unknown error",CODE_LF,$00
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
        beq @l2
        jmp errmsg
@l2:
        jmp mainloop

exec:
	lda cmdptr
	ldx cmdptr+1    ; cmdline in a/x
	jsr krn_execv   ; return A with errorcode
	bne @l1         ; error? try different path
	jmp mainloop

@l1:
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
	stz	tmp1
	ldy #0
@cp_loop:
	lda (cmdptr),y
	beq @l3
	cmp #'.'
	bne	@cp_loop_1
	stx	tmp1
@cp_loop_1:
	cmp #' '		;end of program name?
	beq @l3
	sta tmpbuf,x
	iny
	inx
	bne @cp_loop
@l3:
        lda tmp1
        bne	@l4
        ldy #0
@l5:
        lda	PRGEXT,y
        beq @l4
        sta tmpbuf,x
        inx
        iny
        bne	@l5
@l4:
        stz tmpbuf,x

        lda #<tmpbuf
        ldx #>tmpbuf    ; cmdline in a/x
        jsr krn_execv   ; return A with errorcode
        bne @try_path
        lda #$fe
        jmp errmsg


.ifdef DEBUG
.import hexout
dumpvec		= $c0
dumpvec_end   	= dumpvec
dumpvec_start 	= dumpvec+2

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

@l2:	cpy #$00
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
@l5:	lda (dumpvec_start),y
        cmp #$19
        bcs @l6
        lda #'.'
@l6:	jsr char_out
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

@l8:	jmp mainloop
.endif

; screensaver_loop:
;         lda rtc_systime_t+time_t::tm_min
;         cmp screensaver_rtc
;         bne l_exit
;         lda #<screensaver_prg
;         ldx #>screensaver_prg
;         phy
;         jsr krn_execv   ;ignore any errors
;         ply
; screensaver_settimeout:
;         lda rtc_systime_t+time_t::tm_min
;         clc
;         adc #SCREENSAVER_TIMEOUT_MINUTES
;         cmp #60
;         bcc :+
;         sbc #60
; :       sta screensaver_rtc
; l_exit:
;         rts

PATH:             .asciiz "./:/steckos/:/progs/"
PRGEXT:           .asciiz ".PRG"
; screensaver_prg:  .asciiz "/steckos/unrclock.prg"
; screensaver_rtc:  .res 1

.bss
crs_x_prompt:     .res 1
tmpbuf:           .res BUF_SIZE
buf:              .res BUF_SIZE
cwdbuf_size=80
cwdbuf:           .res cwdbuf_size
history:
