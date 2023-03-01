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

.include "common.inc"
.include "fcntl.inc"
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "ym3812.inc"
.include "vdp.inc"
.include "keyboard.inc"
.include "errno.inc"
.include "appstart.inc"

.import vdp_bgcolor
.import hexout_s
.import jch_fm_init, jch_fm_play
.import jch_fm_set_volume
.import opl2_detect, opl2_init, opl2_reg_write

.export d00file
.export char_out=krn_chrout

appstart $1000

.code
main:
		jsr opl2_detect
		bcc @load
		jsr krn_primm
		.byte "YM3526/YM3812 not available!",$0a,0
		jmp exit
@load:
		jsr loadfile
		beq :+
		pha
		jsr krn_primm
		.byte "i/o error occured: ",0
		pla
		jsr hexout_s
		lda #$0a
		jsr char_out
		jmp exit

:   	jsr isD00File
		beq :+
		jsr krn_primm
		.byte "not a D00 file",$0a,0
		jmp exit

:
		jsr krn_primm
		.byte "edlib player v0.2 (somewhat optimized) by mr.mouse/xentax july 2017@",$0a,0
		jsr printMetaData

		jsr krn_textui_crs_onoff
		jsr jch_fm_init

		sei
    	copypointer user_isr, safe_isr
		SetVector player_isr, user_isr

		freq=70
		t2cycles=275
		lda #($ff-(1000000 / freq / t2cycles))	; 1s => 1.000.000µs / 70 (Hz) / 320µs = counter value => timer is incremental, irq on overflow so we have to $ff - counter value
		sta t2_value
		jsr set_timer_t2

		ldx #opl2_reg_ctrl
		lda #$80
		jsr opl2_reg_write
		lda #$42 ; t1 disable, t2 enable and start
		jsr opl2_reg_write

		cli

@keyin:
    keyin
		cmp #'p'
		bne @key_min
		lda #01
		eor player_state
		sta player_state
		beq :+
		jsr krn_primm
		.byte "Pause...",$0a,0
		bra @keyin
:		jsr krn_primm
		.byte "Play...",$0a,0
		bra @keyin
@key_min:
		cmp #'-'
		bne @key_pls
		dec t2_value
		bra @set_timer_t2
@key_pls:
		cmp #'+'
    	bne @key_esc
    	inc t2_value
@set_timer_t2:
		jsr set_timer_t2_safe
		bra @keyin
@key_esc:
		cmp #KEY_ESCAPE
		beq @exit_player
		bra @keyin

@exit_player:;TODO FIXME use ISR
		ldx #0
@fadeout:
		ldy #$40
:		dex
		bne :-
		dey
		bne :-
		inc fm_master_volume
		lda fm_master_volume
		jsr jch_fm_set_volume
		cmp #$3f
		bne @fadeout

		sei
		copypointer safe_isr, user_isr
		cli

exit:
		jsr opl2_init
		jsr krn_textui_init
		jmp (retvec)

set_timer_t2_safe:
    php
    sei
	jsr set_timer_t2
    plp
    rts
set_timer_t2:
	ldx #opl2_reg_t2	; t2 timer value
    lda t2_value
    jmp opl2_reg_write

printMetaData:
		jsr krn_primm
		.asciiz "Name: "
		ldy #$0b
		jsr printString
		jsr krn_primm
		.byte $0a,"Composer: ",0
		ldy #$2b
		jsr printString
		jsr krn_primm
		.byte $0a,"Irq: ",0
		ldy #8
		lda d00file,y
		jsr hexout_s
;		jsr krn_primm
;		.byte $0a,"Spd: ",0
;		ldy #8
;		lda d00file,y
;		jsr hexout
		rts

printString:
		ldx #$20
:
    lda d00file, y
		iny
		dex
		bne :-
		rts

isD00File:
		ldy #0
:
		lda d00file, y
		cmp d00header,y
		bne :+
		iny
		cpy #6
		bne :-
:
		rts
d00header:
		.byte "JCH",$26,$2,$66

loadfile:
		lda paramptr
		ldx paramptr+1
		ldy #O_RDONLY
		jsr krn_open
    bcs @l_exit
		stx fd
		SetVector d00file, read_blkptr
		jsr krn_read
		pha
		ldx fd
		jsr krn_close
		pla
		cmp #EOK
@l_exit:
		rts

player_isr:
		bit opl_stat
		bpl @vdp     ; bit 6 set? (snd)
		; do write operations on ym3812 within a user isr directly after reading opl_stat here, "is too hard", we have to delay at least register wait ;)
		.import opl2_delay_data
    jsr opl2_delay_data

		lda #Medium_Green<<4|Medium_Red
		jsr vdp_bgcolor

		lda player_state
		bne @opl_ack
		jsr jch_fm_play

@opl_ack:
		ldx #opl2_reg_ctrl
		lda #$80	; ack IRQ
		jsr opl2_reg_write
@vdp:
		bit a_vreg
		bpl @exit
		lda #Medium_Green<<4|Dark_Yellow
		jsr vdp_bgcolor
@exit:

		lda #Medium_Green<<4|Transparent
		jsr vdp_bgcolor

		rts

.data
safe_isr:     .res 2
player_state: .res 1
t2_value:     .res 1
fd:           .res 1
fm_master_volume: .res 1, $3f

.bss
d00file:
	.res $2000
