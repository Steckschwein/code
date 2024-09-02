;sound
.include "pacman.sts.inc"

.export sound_init
.export sound_reset
.export sound_off
.export sound_update
.export sound_play_game_prelude
.export sound_play_eat_dot
.export sound_play_eat_fruit
.export sound_play_ghost_catched
.export sound_play_ghost_alarm
.export sound_play_ghost_frightened
.export sound_play_pacman_dying

.import opl2_init
.import opl2_reg_write

.autoimport

.zeropage
              r1:  .res 1

; note/frequency assignments - https://shipbrook.net/jeff/sb.html#a0-b8
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

; frame count (note length)
L2    =32
L4    =16
L8    =8
L16   =4
L32   =2
L64   =1

TREM=7
VIB=6
EG=5
KSR=4

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
.macro note _note, octave, delay
   .if _note = NOTE_C ;adjust octave, ym3812 ends with C ... weird
    .byte <_note
    .byte (1<<5) | ((octave-1)<<2) | (>_note & $03)
    .byte delay>>tempo
   .else
    .byte <_note
    .byte (1<<5) | (octave<<2) | (>_note & $03)
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

.macro init_channel s, e
    .addr s
    .byte e-s
.endmacro

.struct channel
   nr         .byte
   cnt        .byte ; pause
   ix         .byte ; index
   notes      .addr ; data address
   length     .byte ; snd length
   state_bit  .byte
.endstruct

.code

SOUND_GAME_PRELUDE      = 1<<0 | 1<<1 ; channel 1,2
SOUND_PACMAN            = 1<<2        ; channel 3
SOUND_EAT_FRUIT         = 1<<3        ; ...
SOUND_GHOST_ALARM       = 1<<4
SOUND_GHOST_CATCHED     = 1<<5        ; ...
SOUND_GHOST_FRIGHTENED  = 1<<6        ; channel 7
SOUND_PACMAN_DYING      = 1<<7

sound_play_eat_dot:
              lda #SOUND_PACMAN
sound_play:   ora sound_play_state
              sta sound_play_state
              rts
sound_play_game_prelude:
.ifdef __DEVMODE
              rts
.endif
              lda #SOUND_GAME_PRELUDE
              bne sound_play
sound_play_eat_fruit:
              lda #SOUND_EAT_FRUIT
              bne sound_play
sound_play_ghost_alarm:
.ifdef __DEVMODE
              rts
.endif
              lda #SOUND_GHOST_ALARM
              bne sound_play
sound_play_ghost_catched:
              lda #SOUND_GHOST_CATCHED
              bne sound_play
sound_play_ghost_frightened:
              lda #SOUND_GHOST_FRIGHTENED
              bne sound_play
sound_play_pacman_dying:
              lda #SOUND_PACMAN_DYING
              bne sound_play

snd_wait:
              cmp game_state+GameState::frames
              bne snd_wait
              stz game_state+GameState::frames
              rts

sound_update: bit game_state+GameState::state
              bmi @exit
              ldx #0  ; start with channel 0
              lda sound_play_state
              sta r1
:             lsr r1
              bcc :+
              jsr sound_play_chn
:             inx
              cpx #channels
              bne :--
@exit:        rts

; X - channel
sound_play_chn:
.ifdef __ASSERTIONS
              cpx #channels+1
              bcc :+
              stp
          :   nop
.endif
              dec chn_cnt,x
              bne @exit
              lda chn_ix,x    ; data channel
              cmp chn_length,x
              bne @next_note
              stz chn_ix,x
              lda #L64
              sta chn_cnt,x
              ;stp
              lda sound_play_state
              eor chn_bit,x
              sta sound_play_state
              rts

@next_note:   stx sound_tmp
              tay ; index to y
              lda chn_notes_l,x
              sta p_sound+0
              lda chn_notes_h,x
              sta p_sound+1

              txa
              ora #$a0
              tax
              lda (p_sound), y   ; note F-Number lsb
              iny
.ifndef __NO_SOUND
              jsr opl2_reg_write
.endif
              lda sound_tmp
              ora #$b0
              tax                ; register to X
              lda (p_sound), y   ; note Key-On / Octave / F-Number msb
              iny
.ifndef __NO_SOUND
              jsr opl2_reg_write
.endif
              lda (p_sound), y   ; delay
              iny
              ldx sound_tmp
              sta chn_cnt,x
              tya
              sta chn_ix,x

@exit:        rts


sound_init:   jsr sound_off

              opl_reg $c0, 0 ; FM mode
              opl_reg 1,   1<<5 ; WS on
              ;TODO FIXME instrument table
              ;channel 1 - rhodes piano
              ;modulator op1
              opl_reg $20,  1
              opl_reg $40,  (SCALE_3 | ($3f-48)) ; key scale / level
              opl_reg $60,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $80,  (10<<4 | (0 & $0f))  ; SR
              opl_reg $e0,  WS_ABS_SIN ;PULSE_SIN
              ;carrier op2
              opl_reg $23,  1
              opl_reg $43,  (SCALE_0 | ($3f-59))
              opl_reg $63,  (13<<4 | (2 & $0f))  ; attack / decay
              opl_reg $83,  (8<<4 | (12 & $0f))  ; sustain / release
              opl_reg $e3,  WS_ABS_SIN ;PULSE_SIN

              ;channel 2 - rhodes piano
              ; modulator op1
              opl_reg $21,  0
              opl_reg $41,  (SCALE_3 | ($3f-48)) ; key scale / level
              opl_reg $61,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $81,  (10<<4 | (0 & $0f))  ; SR
              opl_reg $e1,  WS_PULSE_SIN
              ;carrier op2
              opl_reg $24,  0
              opl_reg $44,  (SCALE_0 | ($3f-59))
              opl_reg $64,  (13<<4 | (2 & $0f))  ; attack / decay
              opl_reg $84,  (8<<4 | (12 & $0f))  ; sustain / release
              opl_reg $e4,  WS_PULSE_SIN

              ;channel 3 - pacman dots
              ;modulator op1
              opl_reg $22,  1
              opl_reg $42,  (SCALE_0 | ($3f-48)) ; key scale / level
              opl_reg $62,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $82,  (10<<4 | (0 & $0f))  ; SR
              opl_reg $e2,  WS_PULSE_SIN ; wave select
              ;carrier op2
              opl_reg $25,  1
              opl_reg $45,  (SCALE_0 | ($3f-59))
              opl_reg $65,  (13<<4 | (2 & $0f))  ; attack / decay
              opl_reg $85,  (8<<4 | (12 & $0f))  ; sustain / release
              opl_reg $e5,  WS_HALF_SIN

              ;channel 4 - fruits
              ;modulator op1
              opl_reg $28,  1
              opl_reg $48,  (SCALE_1_5 | ($3f-48)) ; key scale / level
              opl_reg $68,  ($f<<4 | ($f & $0f))  ; AD
              opl_reg $88,  (0<<4 | ($0 & $0f))  ; SR
              opl_reg $e8,  WS_HALF_SIN ; wave select
              ;carrier op2
              opl_reg $2b,  1
              opl_reg $4b,  (SCALE_1_5 | ($3f-59))
              opl_reg $6b,  ($f<<4 | ($f & $0f))  ; attack / decay
              opl_reg $8b,  (0<<4 | ($0 & $0f))  ; sustain / release
              opl_reg $eb,  WS_HALF_SIN

              ;channel 5 - alarm
              ;modulator op1
              opl_reg $29,  1
              opl_reg $49,  (SCALE_0 | ($3f-38)) ; key scale / level
              opl_reg $69,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $89,  (10<<4 | (3 & $0f))  ; SR
              opl_reg $e9,  WS_SIN ; wave select
              ;carrier op2
              opl_reg $2c,  1
              opl_reg $4c,  (SCALE_0 | ($3f-39))
              opl_reg $6c,  (13<<4 | (2 & $0f))  ; attack / decay
              opl_reg $8c,  (8<<4 | (13 & $0f))  ; sustain / release
              opl_reg $ec,  WS_SIN

              ;channel 6 - catched
              ;modulator op1
              opl_reg $2a,  1
              opl_reg $4a,  (SCALE_0 | ($3f-48)) ; key scale / level
              opl_reg $6a,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $8a,  (10<<4 | (0 & $0f))  ; SR
              opl_reg $ea,  WS_SIN ; wave select
              ;carrier op2
              opl_reg $2d,  1
              opl_reg $4d,  (SCALE_0 | ($3f-59))
              opl_reg $6d,  (13<<4 | (2 & $0f))  ; attack / decay
              opl_reg $8d,  (8<<4 | (15 & $0f))  ; sustain / release
              opl_reg $ed,  WS_SIN

              ;channel 7 - frightened
              ;modulator op1
              opl_reg $30,  1
              opl_reg $50,  (SCALE_0 | ($3f-48)) ; key scale / level
              opl_reg $70,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $90,  (10<<4 | (0 & $0f))  ; SR
              opl_reg $f0,  WS_PULSE_SIN  ; wave select
              ;carrier op2
              opl_reg $33,  1
              opl_reg $53,  (SCALE_0 | ($3f-59))
              opl_reg $73,  (13<<4 | (2 & $0f))  ; attack / decay
              opl_reg $93,  (8<<4 | (15 & $0f))  ; sustain / release
              opl_reg $f3,  WS_PULSE_SIN

              ;channel 8 - pacman dying
              ;modulator op1
              opl_reg $31,  1
              opl_reg $51,  (SCALE_0 | (0)) ; key scale / level
              opl_reg $71,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $91,  (10<<4 | (3 & $0f))  ; SR
              opl_reg $f1,  WS_HALF_SIN ; wave select
              ;carrier op2
              opl_reg $34,  1
              opl_reg $54,  (SCALE_0 | (0))
              opl_reg $74,  (13<<4 | (2 & $0f))  ; attack / decay
              opl_reg $94,  (8<<4 | (13 & $0f))  ; sustain / release
              opl_reg $f4,  WS_HALF_SIN

channels=8
              ldy #channels*3-1
              ldx #channels-1
              lda #1<<(channels-1)
              sta r1
:             stz chn_ix,x
              lda #L64
              sta chn_cnt,x
              lda channel_init,y
              sta chn_length,x
              dey
              lda channel_init,y
              sta chn_notes_h,x
              dey
              lda channel_init,y
              sta chn_notes_l,x
              dey
              lda r1
              sta chn_bit,x
              lsr r1
              dex
              bpl :-
              rts

sound_off:    stz sound_play_state
sound_reset:  jmp opl2_init

.data


channel_init:
    init_channel game_start_sound1, game_start_sound1_end
    init_channel game_start_sound2, game_start_sound2_end
    init_channel game_sfx_pacman, game_sfx_pacman_end
    init_channel game_sfx_eat_fruit,game_sfx_eat_fruit_end
    init_channel game_sfx_ghost_alarm, game_sfx_ghost_alarm_end
    init_channel game_sfx_eat_ghost, game_sfx_eat_ghost_end
    init_channel game_sfx_frightened, game_sfx_frightened_end
    init_channel game_snd_pacman_dying, game_snd_pacman_dying_end

game_snd_pacman_dying:
              .include "pacman.dying.dat"
              soundEnd
game_snd_pacman_dying_end:

game_sfx_frightened:
              .repeat 8, i
                note 384, 1+i, L64
              .endrepeat
              soundEnd
game_sfx_frightened_end:

game_sfx_eat_ghost:
              .repeat 32, i
                note ((i+1)*$0020), 4, L64
              .endrepeat
              soundEnd
game_sfx_eat_ghost_end:

.export game_sfx_eat_fruit
game_sfx_eat_fruit:
              .repeat 4, i
                note ($b00-(i*$e0)), 2, L64
              .endrepeat
              .repeat 10, i
                note ((i+1)*$e0), 2, L64
              .endrepeat
              soundEnd
game_sfx_eat_fruit_end:

.export game_sfx_ghost_alarm
game_sfx_ghost_alarm:
              .repeat 12, i
                note (400+(i*10)), 5, L64
              .endrepeat
              .repeat 12, i
                note (400+(12*10)-(i*10)), 5, L64
              .endrepeat
              soundEnd
game_sfx_ghost_alarm_end:

; game sfx eaten pac
game_sfx_pacman:
              note NOTE_B,    4, L64
              note NOTE_Gis,  4, L64
              note NOTE_F,    4, L64
              note NOTE_Cis,  4, L64
              note NOTE_Gis,  3, L64
              pause L64
;              pause L64
              pause L64
              note NOTE_Gis,  3, L64
              note NOTE_Cis,  4, L64
              note NOTE_F,    4, L64
              note NOTE_Gis,  4, L64
              note NOTE_B,    4, L64
;              note NOTE_E,    3, L64
 ;             note NOTE_Gis,  3, L64
  ;            note NOTE_Dis,  4, L64
   ;           note NOTE_Fis,  4, L64
    ;          note NOTE_A,    4, L64
              soundEnd
game_sfx_pacman_end:

; game start sound
game_start_sound1: ; piano
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
game_start_sound1_end:

game_start_sound2:
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
game_start_sound2_end:

      ;"Recorder"
      ;opl_reg $20,  (1<<KSR | 1<<EG | 2)
      ;opl_reg $40,  (SCALE_1_5 | ($3f-47)) ; key scale / level
      ;opl_reg $60,  (15<<4 | (1 & $0f))  ; AD
      ;opl_reg $80,  (15<<4 | (4 & $0f))  ; SR
      ;carrier op2
      ;  ADSR 6, 0, 12, 9
      ;  sinus
      ;  EG sustaining voice
      ;  level 62
      ;  freq scale 1
      ;  key scale 2
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
      ;opl_reg $64,  (13<<4 | (5 & $0f))  ; attack / decay
      ;opl_reg $84,  (6<<4 | (8 & $0f))   ; sustain / release

.bss
      sound_play_state: .res 1


      chn_cnt:      .res 8
      chn_ix:       .res 8
      chn_notes_l:  .res 8
      chn_notes_h:  .res 8
      chn_length:   .res 8
      chn_bit:      .res 8


; game start
; pacman
; sirene
; catched

;   .byte 0
 ;  .byte L64;        cnt .byte
  ; .byte 0;          ix  .byte

   ;.word 0;game_sfx_pacman
   ;.byte 0;game_sfx_pacman_end-game_sfx_pacman

;   .word 0;game_start_sound1    ;   p_note   .word
;   .byte 0;game_start_sound1_end-game_start_sound1

;   .byte 1
 ;  .byte L64;        cnt .byte
  ; .byte 0;          ix      .byte

;   .word 0;game_start_sound2;   p_delay  .word
;   .byte 0;game_start_sound2_end-game_start_sound2

