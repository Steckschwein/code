
.setcpu "65c02"

.include "common.inc"
.include "fcntl.inc"
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "ym3812.inc"
.include "via.inc"
.include "vdp.inc"
.include "keyboard.inc"
.include "appstart.inc"

appstart

.segment "STARTUP"

.code
.importzp ptr1

.import vdp_bgcolor
.import hexout
.import jch_fm_init, jch_fm_play
.import jch_fm_set_volume
.import opl2_detect, opl2_init, opl2_reg_write

.export d00file
.export char_out=krn_chrout
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
		jsr hexout
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
		;jsr opl2_delay_register
		lda #($ff-(1000000 / freq / t2cycles))	; 1s => 1.000.000µs / 70 (Hz) / 320µs = counter value => timer is incremental, irq on overflow so we have to $ff - counter value
		sta t2_value
		jsr set_timer_t2

		jsr restart_timer

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
		jsr set_timer_t2
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

restart_timer:
reset_irq:
		ldx #opl2_reg_ctrl
		lda #$80
		jsr opl2_reg_write
		ldx #opl2_reg_ctrl
		lda #$42	; t2
		jmp opl2_reg_write

set_timer_t2:
    php
    sei
		ldx #opl2_reg_t2	; t2 timer value
    lda t2_value
    jsr opl2_reg_write
    plp
    rts

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
		jsr hexout
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
		bne @l_exit
		stx fd
		SetVector d00file, read_blkptr
		jsr krn_read
		pha
		ldx fd
		jsr krn_close
		pla
		cmp #0
@l_exit:
		rts

player_isr:
		bit opl_stat
		bpl @vdp     ; bit 6 set? (snd)
		; do write operations on ym3812 within a user isr directly after reading opl_stat here, "is too hard", we have to delay at least register wait ;)
		;jsr opl2_delay_register
		jsr restart_timer
		lda #Medium_Green<<4|Medium_Red
		jsr vdp_bgcolor
		lda player_state
		bne @vdp
		jsr jch_fm_play
@vdp:
		bit a_vreg
		bpl @exit
		lda #Medium_Green<<4|Dark_Yellow
		jsr vdp_bgcolor
@exit:

		lda #Medium_Green<<4|Transparent
		jsr vdp_bgcolor

		rts

safe_isr:     .res 2
player_state: .res 1,0
t2_value:     .res 1,0
fd:           .res 1
irq_counter:  .res 0
fm_master_volume: .res 1,0

.bss
d00file:
