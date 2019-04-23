      .include "pacman.inc"

      .export sound_init
      .export sound_init_game_start
      .export sound_play
      .export sound_play_state
      
      .import wait
      .import game_state
      

NOTE_Cis  =$16B
NOTE_D    =$181
NOTE_Dis  =$198
NOTE_E    =$1B0
NOTE_F    =$1CA
NOTE_Fis  =$1E5
NOTE_G    =$202
NOTE_Gis  =$220
NOTE_A    =$241
NOTE_Ais  =$263
NOTE_B    =$287
NOTE_C    =$2AE

L2        =32
L4        =16
L8        =8
L16       =4
L32       =2
L64       =1

TREM=7
VIB=6
EG=5
KSR=4

WS_SIN=$0
WS_HALF_SIN=$01
WS_ABS_SIN=$02
WS_PULSE_SIN=$03

SCALE_0=0
SCALE_1_5=1<<7
SCALE_3=1<<6

.macro stefan note, octave, _A, _D, _S, _R
      opl_reg $63,  (_A<<4 | (_D & $0f))  ; attack / decay
      opl_reg $83,  (_S<<4 | (_R & $0f))  ; sustain / release
      opl_reg $a0,  <note ; frequency
      opl_reg $b0,  (1<<5) | (octave<<2) | (>note & $03)
.endmacro

.macro stefan2 note, octave, _l
      stefan note, octave, 15, 0, 7, 0
      lda #(_l-2)
      jsr snd_wait
.endmacro

tempo=0
.macro sound note, octave, delay
    .if note = NOTE_C ;adjust octave, ym3812 ends with C .... wired
      .byte <note
      .byte (1<<5) | ((octave-1)<<2) | (>note & $03)
      .byte delay>>tempo
    .else
      .byte <note
      .byte (1<<5) | (octave<<2) | (>note & $03)
      .byte delay>>tempo
    .endif
.endmacro

.macro pause delay
    .byte 0
    .byte 0
    .byte delay>>tempo
.endmacro

.macro soundEnd
    .byte 0
    .byte 0
    .byte 1
.endmacro


.macro s_AD _a, _d
  .byte _a<<4 | (_d & $0f)
.endmacro
.macro s_SR _s, _r
  .byte _s<<4 | (_r & $0f)
.endmacro
 
.macro initvoice chn, initdata
      stz chn+voice::ix
      lda #L64
      sta chn+voice::cnt
      ldx #2
:     lda initdata,x
      sta chn+voice::p_note,x
      dex
      bpl :-
.endmacro

.code
 
snd_wait:
      cmp game_state+GameState::frames
      bne snd_wait
      stz game_state+GameState::frames
      rts

sound_init:
      jmp opl2_init
      
sound_off:
      opl_reg $b0,  0
      rts

      set_irq player_isr, _save_irq
      cli
      
@loop:
      jmp @loop
      
@exit:
      sei
      restore_irq _save_irq
      cli

      jsr sound_off

      rts

.struct voice
    reg_a0    .byte
    reg_b0    .byte
    cnt       .byte
    ix        .byte
    p_note    .word
    length    .byte
.endstruct

player_isr:
      save
      bit	a_vreg
      bpl	@exit
      
      bgcolor Color_Yellow
      
      inc game_state+GameState::frames
      
@exit:
      bgcolor Color_Bg

      restore
      rti

sound_play:
.if DEBUG = 0
      lda sound_play_state
      beq @exit
      ldx #0*.sizeof(voice)
      jsr sound_play_voice
      ldx #1*.sizeof(voice)
      jsr sound_play_voice
@exit:
.endif
      rts

sound_play_state:
      .res 1,0
      
sound_play_voice:
      dec sound_voices+voice::cnt,x
      bne @exit
      
      lda sound_voices+voice::ix,x      ; voice data index
      cmp sound_voices+voice::length,x
      bne @next_note
      stz sound_voices+voice::ix,x
      stz sound_play_state
      rts
@next_note:
      stx sound_tmp
      tay ; index to y
      lda sound_voices+voice::p_note+0,x
      sta p_sound+0
      lda sound_voices+voice::p_note+1,x
      sta p_sound+1
      
      lda sound_voices+voice::reg_a0,x
      tax
      lda (p_sound), y    ; note F-Number lsb
      iny
      jsr opl2_reg_write
      
      ldx sound_tmp
      lda sound_voices+voice::reg_b0,x
      tax
      lda (p_sound), y    ; note Key-On / Octave / F-Number msb
      iny
      jsr opl2_reg_write
      
      lda (p_sound), y    ; delay
      iny
      ldx sound_tmp
      sta sound_voices+voice::cnt,x
      tya
      sta sound_voices+voice::ix,x
@exit:
      rts

sound_init_game_start:
      opl_reg $c0, 0 ; FM mode
      opl_reg 1,    1<<5 ; WS on
      ;TODO FIXME instrument table
      ;channel 1 - rhodes piano
      ;modulator op1
      opl_reg $20,  1
      opl_reg $40,  (SCALE_3 | ($3f-48)) ; key scale / level
      opl_reg $60,  (15<<4 | (1 & $0f))   ; AD
      opl_reg $80,  (10<<4 | (0 & $0f))  ; SR
      opl_reg $e0,  WS_ABS_SIN;PULSE_SIN
      ;carrier op2
      opl_reg $23,  1
      opl_reg $43,  (SCALE_0 | ($3f-59))
      opl_reg $63,  (13<<4 | (2 & $0f))  ; attack / decay
      opl_reg $83,  (8<<4 | (12 & $0f))  ; sustain / release        
      opl_reg $e3,  WS_ABS_SIN;PULSE_SIN

      ;channel 2 - rhodes piano
      ; modulator op1
      opl_reg $21,  0
      opl_reg $41,  (SCALE_3 | ($3f-48)) ; key scale / level
      opl_reg $61,  (15<<4 | (1 & $0f))   ; AD
      opl_reg $81,  (10<<4 | (0 & $0f))  ; SR
      opl_reg $e1,  WS_PULSE_SIN
      ;carrier op2
      opl_reg $24,  0
      opl_reg $44,  (SCALE_0 | ($3f-59))
      opl_reg $64,  (13<<4 | (2 & $0f))  ; attack / decay
      opl_reg $84,  (8<<4 | (12 & $0f))  ; sustain / release        
      opl_reg $e4,  WS_PULSE_SIN
      
      initvoice voice1, sound_game_start_v1
      initvoice voice2, sound_game_start_v2
      
      lda #1
      sta sound_play_state
      rts
      
sound_game_start_v1:
      .word game_start_voice1;    p_note    .word
      .byte game_start_voice1_end-game_start_voice1
sound_game_start_v2:
      .word game_start_voice2;    p_delay   .word
      .byte game_start_voice2_end-game_start_voice2

.data
_save_irq:  .res 2, 0
_freq:      .res 1, 0

sound_voices:
voice1:
    ;.tag voice
    .byte $a0
    .byte $b0
    .byte L64;             cnt .byte
    .byte 0;               ix  .byte
    .word 0;game_start_voice1;    p_note    .word
    .byte 0;game_start_voice1_end-game_start_voice1
    
voice2: 
    ;.tag voice
    .byte $a1
    .byte $b1
    .byte L64;              cnt .byte
    .byte 0;              ix        .byte
    .word 0;game_start_voice2;    p_delay   .word
    .byte 0;game_start_voice2_end-game_start_voice2

; game start sound
game_start_voice1: ; piano
      ;1 takt
      sound NOTE_C, 4, L8
      sound NOTE_C, 5, L8
      sound NOTE_G, 4, L8
      sound NOTE_E, 4, L8
      sound NOTE_C, 5, L16
      sound NOTE_G, 4, L16
      pause L8
      sound NOTE_E, 4, L8
      pause L8
      ; 2nd takt
      sound NOTE_Cis, 4, L8
      sound NOTE_Cis, 5, L8
      sound NOTE_Gis, 4, L8
      sound NOTE_F, 4, L8
      sound NOTE_Cis, 5, L16
      sound NOTE_Gis, 4, L16
      pause L8
      sound NOTE_F, 4, L8
      pause L8
      ;3 takt
      sound NOTE_C, 4, L8
      sound NOTE_C, 5, L8
      sound NOTE_G, 4, L8
      sound NOTE_E, 4, L8
      sound NOTE_C, 5, L16
      sound NOTE_G, 4, L16
      pause L8
      sound NOTE_E, 4, L8
      pause L8
      ; 4 takt
      sound NOTE_E, 4, L16
      sound NOTE_F, 4, L16
      sound NOTE_Fis, 4, L16
      pause L16
      sound NOTE_Fis, 4, L16
      sound NOTE_G, 4, L16
      sound NOTE_Gis, 4, L16
      pause L16
      sound NOTE_Gis, 4, L16
      sound NOTE_A, 4, L16
      sound NOTE_Ais, 4, L16
      pause L16
      sound NOTE_C, 5, 3*L16
      pause L16
      soundEnd
game_start_voice1_end:

game_start_voice2:
      sound NOTE_C, 2, L8
      pause L4      
      sound NOTE_G, 2, L8
      sound NOTE_C, 2, L8
      pause L4
      sound NOTE_G, 2, L8
      ; 2nd takt
      sound NOTE_Cis, 2, L8
      pause L4
      sound NOTE_Gis, 2, L8
      sound NOTE_Cis, 2, L8
      pause L4
      sound NOTE_Gis, 2, L8
      ; 3nd takt 
      sound NOTE_C, 2, L8
      pause L4
      sound NOTE_G, 2, L8
      sound NOTE_C, 2, L8
      pause L4
      sound NOTE_G, 2, L8
      ; 4nd takt 
      sound NOTE_G, 2, L8
      pause L8
      sound NOTE_A, 2, L8
      pause L8
      sound NOTE_B, 2, L8
      pause L8
      sound NOTE_C, 3, L8
      pause L8
      soundEnd
      
game_start_voice2_end:

; ghost alarm sound
ghost_alarm:
     .byte 16,32,48,64,80,96,112,128,144,160,176,192,208,224,240


        ;"Recorder"
        ;opl_reg $20,  (1<<KSR | 1<<EG | 2)
        ;opl_reg $40,  (SCALE_1_5 | ($3f-47)) ; key scale / level
        ;opl_reg $60,  (15<<4 | (1 & $0f))   ; AD
        ;opl_reg $80,  (15<<4 | (4 & $0f))  ; SR
        ;carrier op2
        ;   ADSR 6, 0, 12, 9
        ;   sinus
        ;   EG sustaining voice
        ;   level 62
        ;   freq scale 1
        ;   key scale 2
        ;opl_reg $23,  (1<<EG | 1)
        ;opl_reg $43,  (SCALE_1_5 | ($3f-62))
        ;opl_reg $63,  (15<<4 | (0 & $0f))  ; attack / decay
        ;opl_reg $83,  (15<<4 | (4 & $0f))  ; sustain / release
      
        ; slap bass 1
        ; modulator
        ;opl_reg $21,  (1<<EG | 1<<KSR |1)
        ;opl_reg $41,  (SCALE_0 | ($3f-52))
        ;opl_reg $61,  (7<<4 | (2 & $0f))  ; attack / decay
        ;opl_reg $81,  (4<<4 | (5 & $0f))  ; sustain / release

        ;opl_reg $24,  (1<<EG | 1)
        ;opl_reg $44,  (SCALE_0 | ($3f-63))
        ;opl_reg $64,  (13<<4 | (5 & $0f))   ; attack / decay
        ;opl_reg $84,  (6<<4 | (8 & $0f))    ; sustain / release
        
;     .word $181,$1CA,$241,$181,$1CA,$241,$181,$1CA,$241,$181,$1CA,$241,$181,$202,$287,$181,$202,$287,$181,$202,$287,$181,$202,$287,$181,$1CA,$241,$181,$181,$1CA,$241,$181,$1CA,$241,$2AE,$1CA,$241,$2AE
     .word 0
      
      stefan NOTE_D, 4, 15, 0, 7, 0
      stefan NOTE_F, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0 
      stefan NOTE_D, 4, 15, 0, 7, 0
      stefan NOTE_F, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0
      stefan NOTE_D, 4, 15, 0, 7, 0
      stefan NOTE_F, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0
      stefan NOTE_D, 4, 15, 0, 7, 0
      stefan NOTE_F, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_F, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_F, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_F, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_F, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_E, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_E, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_E, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_E, 4, 15, 0, 7, 0 
      stefan NOTE_A, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_E, 4, 15, 0, 7, 0 
      stefan NOTE_G, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_E, 4, 15, 0, 7, 0 
      stefan NOTE_G, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_E, 4, 15, 0, 7, 0 
      stefan NOTE_G, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_E, 4, 15, 0, 7, 0 
      stefan NOTE_G, 4, 15, 0, 7, 0
      stefan NOTE_C, 4, 15, 0, 7, 0
      stefan NOTE_E, 4, 15, 0, 7, 0 
      stefan NOTE_G, 4, 15, 0, 7, 0
