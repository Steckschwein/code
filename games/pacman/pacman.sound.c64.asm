		.p02
		.include "pacman.c64.inc"

		.export sound_init
		.export sound_init_game_start
		.export sound_play

		.import game_state

.code

.struct voice
	 reg		 .byte	; channel reg F low
	 cnt		 .byte	; note cnt
	 ix		 .byte	; ix
	 p_note	 .word	; pointer
	 length	 .byte	; snd length
.endstruct

L2		  	=32
L4		  	=16
L8		  	=8
L16		=4
L32		=2
L64		=1

BASEFREQ=440
PAL_PHI = 985248
NTSC_PHI = 1022727; //This is for machines with 6567R8 VIC. 6567R56A is slightly different.
CONSTANT = (256*256*256) / PAL_PHI; //Select the constant appropriate for your machine (PAL vs NTSC).

;SID_FREQ = CONSTANT * FREQ_HZ; //Calculate SID freq for a certain note (specified in Hz).

NOTE_C	 =CONSTANT * 523;523,3
NOTE_Cis  =CONSTANT * 554;554,4
NOTE_D	 =CONSTANT * 587;587,3
NOTE_Dis  =CONSTANT * 622;622,3
NOTE_E	 =CONSTANT * 659;659,3
NOTE_F	 =CONSTANT * 699;698,5
NOTE_Fis  =CONSTANT * 740
NOTE_G	 =CONSTANT * 784
NOTE_Gis  =CONSTANT * 830;830,6
NOTE_A	 =CONSTANT * 880
NOTE_Ais  =CONSTANT * 932;932,4
NOTE_B	 =CONSTANT * 988;987,8

.byte $77
		.byte $61,$e1
		.byte $f7,$8f,$30
		.byte $8f,$4e
		.byte $ef
		.byte $c3,$c3
		.byte $ef
		.byte $60

@freqhi:
		.byte $00 ;WRAP
		.byte $07
		.byte $08,$08
		.byte $09,$0a,$0b
		.byte $0c,$0d
		.byte $0e
		.byte $10,$11
		.byte $13
		.byte $16

.macro soundEnd
	 .byte 0
	 .byte 0
	 .byte 1
.endmacro

tempo=0
.macro note _note, octave, delay
	.byte <(_note * (octave-3))
	.byte >(_note * (octave-3))
	.byte delay>>tempo
.endmacro

.macro pause delay
	 .byte 0
	 .byte 0
	 .byte delay>>tempo
.endmacro

.macro initvoice chn, initdata
		lda #0
		sta chn+voice::ix,x
		lda #L64
		sta chn+voice::cnt
		ldx #2
:	  	lda initdata,x
		sta chn+voice::p_note,x
		dex
		bpl :-
.endmacro

sound_init:
		rts

sound_init_game_start:
		;lda #(15<<4 | (1 & $0f))	; AD
		lda #97
		sta SID_AD1
;		lda #(10<<4 | (0 & $0f))  ; SR
		lda #200
		sta SID_SUR1

		lda #$ff
;		sta SID_PB1Lo
;		sta SID_PB1Hi

		lda #33	; 1<<6|1			;PULSE_SIN
		sta SID_Ctl1

;		lda #<(SCALE_3 | ($3f-48)) ; key scale / level

;		lda #(15<<4 | (1 & $0f))	; AD
		lda #$1a
		sta SID_AD2
;		lda #(10<<4 | (0 & $0f))  ; SR
		lda #$80
		sta SID_SUR2

		lda #$f8
		sta SID_PB1Lo
		sta SID_PB1Hi

		lda #17
		sta SID_Ctl2	; WS_PULSE_SIN

		initvoice voice1, sound_game_start_v1
		initvoice voice2, sound_game_start_v2

		lda #$0f
		sta SID_Amp
		lda #$0	;Filter used on middle (melody) voice.
		;sta SID_FltCtl

		lda #1
		sta sound_play_state
		rts

sound_play:
		lda sound_play_state
		beq @exit
		ldx #0*.sizeof(voice)
		jsr sound_play_voice
		ldx #1*.sizeof(voice)
		jsr sound_play_voice
@exit:
		rts

sound_play_voice:
		dec sound_voices+voice::cnt,x
		bne @exit

		lda sound_voices+voice::ix,x		; voice data index
		cmp sound_voices+voice::length,x
		bne @next_note

		lda #0
		sta sound_voices+voice::ix,x

		lda #L64
		sta sound_voices+voice::cnt,x
		lda #0
		sta sound_play_state
		rts

@next_note:
		tay ; voice::ix to y
		stx sound_tmp	; voice ix
		lda sound_voices+voice::p_note+0,x
		sta p_sound+0
		lda sound_voices+voice::p_note+1,x
		sta p_sound+1

		lda sound_voices+voice::reg,x
		tax
		lda #8
		;sta SID_Ctl1,x

		lda (p_sound), y	 ; note F-Number lsb
		iny
		sta SID_S1Lo,x
		lda (p_sound), y	 ; note Key-On / Octave / F-Number msb
		iny
		sta SID_S1Hi,x

		lda #21
		;sta SID_Ctl1,x

		lda (p_sound), y	 ; delay
		iny
		ldx sound_tmp
		sta sound_voices+voice::cnt,x
		tya
		sta sound_voices+voice::ix,x
@exit:
		rts

.data
sound_game_start_v1:
		.word game_start_voice1		;	 p_note	.word
		.byte game_start_voice1_end-game_start_voice1
sound_game_start_v2:
		.word game_start_voice2		;	 p_note	.word
		.byte game_start_voice2_end-game_start_voice2

sound_voices:
voice1:
		;.tag voice
		.byte 0		; reg ix
		.byte L64	; cnt .byte
		.byte 0		; note ix

		;.word 0;game_sfx_pacman
		;.byte 0;game_sfx_pacman_end-game_sfx_pacman
		.word 0;game_start_voice1		;	 p_note	 .word
		.byte 0;game_start_voice1_end-game_start_voice1

voice2:
		;.tag voice
		.byte 7
		.byte L64	;				  cnt .byte
		.byte 0		;				  ix		  .byte
		.word 0		;game_start_voice2;	 p_delay	.word
		.byte 0		;game_start_voice2_end-game_start_voice2

; game start sound
game_start_voice1: ; piano
		;1 takt
		note NOTE_C, 4, L8
		note NOTE_C, 5, L8
		note NOTE_G, 4, L8
		note NOTE_E, 4, L8
		note NOTE_C, 5, L16
		note NOTE_G, 4, L16
		pause L8
		note NOTE_E, 4, L8
		pause L8
		; 2nd takt
		note NOTE_Cis, 4, L8
		note NOTE_Cis, 5, L8
		note NOTE_Gis, 4, L8
		note NOTE_F, 4, L8
		note NOTE_Cis, 5, L16
		note NOTE_Gis, 4, L16
		pause L8
		note NOTE_F, 4, L8
		pause L8
		;3 takt
		note NOTE_C, 4, L8
		note NOTE_C, 5, L8
		note NOTE_G, 4, L8
		note NOTE_E, 4, L8
		note NOTE_C, 5, L16
		note NOTE_G, 4, L16
		pause L8
		note NOTE_E, 4, L8
		pause L8
		; 4 takt
		note NOTE_E, 4, L16
		note NOTE_F, 4, L16
		note NOTE_Fis, 4, L16
		pause L16
		note NOTE_Fis, 4, L16
		note NOTE_G, 4, L16
		note NOTE_Gis, 4, L16
		pause L16
		note NOTE_Gis, 4, L16
		note NOTE_A, 4, L16
		note NOTE_Ais, 4, L16
		pause L16
		note NOTE_C, 5, 3*L16
		pause L16
		soundEnd
game_start_voice1_end:

game_start_voice2:
		note NOTE_C, 2, L8
		pause L4
		note NOTE_G, 2, L8
		note NOTE_C, 2, L8
		pause L4
		note NOTE_G, 2, L8
		; 2nd takt
		note NOTE_Cis, 2, L8
		pause L4
		note NOTE_Gis, 2, L8
		note NOTE_Cis, 2, L8
		pause L4
		note NOTE_Gis, 2, L8
		; 3nd takt
		note NOTE_C, 2, L8
		pause L4
		note NOTE_G, 2, L8
		note NOTE_C, 2, L8
		pause L4
		note NOTE_G, 2, L8
		; 4nd takt
		note NOTE_G, 2, L8
		pause L8
		note NOTE_A, 2, L8
		pause L8
		note NOTE_B, 2, L8
		pause L8
		note NOTE_C, 3, L8
		pause L8
		soundEnd
game_start_voice2_end:

.bss
sound_play_state: .res 1
