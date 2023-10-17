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
.include "ym3812.inc"
.include "vdp.inc"
.include "keyboard.inc"
.include "errno.inc"
.include "appstart.inc"

.autoimport

.export d00file
.export char_out=$8D2E ; _vdp_chrout from bios_call.inc

appstart $1000

.code
main:
    lda #KEY_LF
    jsr char_out

		jsr opl2_detect
		bcc @load
		jsr primm
		.byte "YM3526/YM3812 not available!",$0a,0
		jmp exit
@load:
    jsr isD00File
		beq :+
		jsr primm
		.byte "not a D00 file",$0a,0
		jmp exit
:
		jsr primm
		.byte "edlib player v0.2 (somewhat optimized) by mr.mouse/xentax july 2017@",$0a,0
		jsr printMetaData

		jsr jch_fm_init
		jsr primm
		.byte "Play...",$0a,0

		sei

    jsr vdp_text_on ; init text again, with irq enabled

    lda #$03
    sta ctrl_port+3 ; bank 4 RAM, to set irq
    copypointer SYS_VECTOR_IRQ, safe_isr
		SetVector player_isr, SYS_VECTOR_IRQ

		freq=70
		t2cycles=320
		lda #($ff-(1000000 / freq / t2cycles))	; 1s => 1.000.000µs / 70 (Hz) / 320µs = counter value => timer is incremental, irq on overflow so we have to $ff - counter value
		sta t2_value
		jsr set_timer_t2

		ldx #opl2_reg_ctrl ;reset
		lda #$80
		jsr opl2_reg_write
		lda #$42 ; t1 disable, t2 enable and start
		jsr opl2_reg_write

    stz player_state

		cli

@keyin:
    ;keyin
    lda #0
		cmp #'p'
		bne @key_min
		lda #01
		eor player_state
		sta player_state
		beq :+
		jsr primm
		.byte "Pause...",$0a,0
		bra @keyin
:		jsr primm
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
		copypointer safe_isr, SYS_VECTOR_IRQ
		cli

exit:
		jsr opl2_init ; reset regs
:		jmp :-

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
		jsr primm
		.asciiz "Name: "
		ldy #$0b
		jsr printString
		jsr primm
		.byte $0a,"Composer: ",0
		ldy #$2b
		jsr printString
		jsr primm
		.byte $0a,"Irq: ",0
		ldy #8
		lda d00file,y
		jsr hexout_s
		jsr primm
		.byte $0a,0
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
:		lda d00file, y
    pha
    phy
;    jsr hexout_s
    ply
    pla
		cmp d00header,y
		bne :+
		iny
		cpy #6
		bne :-
:   rts
d00header:
		.byte "JCH",$26,$2,$66

player_isr:
    save

@vdp:
		bit a_vreg
		bpl @opl
		lda #Medium_Green<<4|Dark_Yellow
		jsr vdp_bgcolor
@opl:
    jsr opl2_delay_data
    lda opl_stat
		bpl @exit     ; bit 7 set? (snd)
		; do write operations on ym3812 within a user isr directly after reading opl_stat here, "is too hard", we have to delay at least register wait ;)
;		.import opl2_delay_data
    jsr opl2_delay_data
 ;   jsr hexout_s

		lda #Medium_Green<<4|Medium_Red
		jsr vdp_bgcolor

		lda player_state
		bne @opl_ack
		jsr jch_fm_play
@opl_ack:
		ldx #opl2_reg_ctrl
		lda #$80	; ack IRQ
		jsr opl2_reg_write

;		jsr set_timer_t2

;		ldx #opl2_reg_ctrl
;		lda #$42 ; t1 disable, t2 enable and start
;		lda #$21 ; t2 disable, t1 enable and start
;		jsr opl2_reg_write

    jsr opl2_delay_data
		lda opl_stat
		bpl @exit     ; bit 7 set? (snd)
  ;  jsr hexout_s
   ; lda #KEY_LF
    ;jsr char_out
		lda #Light_Blue<<4|Light_Blue
		jsr vdp_bgcolor
;		lda #$80	; ack IRQ
;		jsr opl2_reg_write

@exit:
;    lda #KEY_CR
;    jsr char_out

		lda #Gray<<4|Transparent
		jsr vdp_bgcolor

    restore
		rti

.bss
  safe_isr:     .res 2
  player_state: .res 1
  t2_value:     .res 1

.data
  d00file:
    .incbin "PJO_GALW.D00"
