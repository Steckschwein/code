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

.include "pacman.inc"
.include "ym3812.inc"

.export sound_init
.export sound_reset
.export sound_off
.export sound_update
.export sound_play_game_prelude
.export sound_play_game_interlude
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
              p_sound:    .res 2
              sound_tmp:  .res 1
              r1:         .res 1

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
NOTE_B    =$287 ; (H)
NOTE_C    =$2AE

; frame count (note length)
; punctuation, use multiplier
L2    =28 ;32
L4    =14 ;16
L8    =7 ;8
L16   =4 ;4
L32   =2
L64   =1

TREM=7
VIB=6
EG=5
KSR=4

SCALE_0=0
SCALE_1_5=1<<7
SCALE_3=1<<6

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

.macro init_channel_sfx s, e
    init_channel s, e, 0
.endmacro

.macro init_channel_snd s, e
    init_channel s, e, 1<<7 ; key on/off bit
.endmacro

.macro init_channel s, e, m
    .addr s
    .byte e-s
    .byte m
.endmacro

.code

SOUND_GAME_MELODY       = 1<<0 | 1<<1 ; channel 1,2 - prelude, interluded, ...
SOUND_PACMAN            = 1<<2        ; channel 3
SOUND_EAT_FRUIT         = 1<<3        ; ...
SOUND_GHOST_ALARM       = 1<<4
SOUND_GHOST_CATCHED     = 1<<5        ; ...
SOUND_GHOST_FRIGHTENED  = 1<<6        ; channel 7
SOUND_PACMAN_DYING      = 1<<7

sound_play_eat_dot:
.ifdef __DEVMODE
              rts
.endif
              lda #SOUND_PACMAN
sound_play:   ora sound_play_state
              sta sound_play_state
@exit:        rts
sound_play_game_interlude:
              ldx #<channel_init_interlude
              ldy #>channel_init_interlude
              bra sound_play_melody
sound_play_game_prelude:
              ldx #<channel_init_prelude
              ldy #>channel_init_prelude
sound_play_melody:
              lda #1<<1 ; channel 1/0
              jsr sound_init_channel
              lda #SOUND_GAME_MELODY
              bra sound_play
sound_play_eat_fruit:
              lda #SOUND_EAT_FRUIT
              bra sound_play
sound_play_ghost_alarm:
.ifdef __DEVMODE
              rts
.endif
              lda #SOUND_GHOST_ALARM
              bra sound_play
sound_play_ghost_catched:
              lda #SOUND_GHOST_CATCHED
              bra sound_play
sound_play_ghost_frightened:
              lda #SOUND_GHOST_FRIGHTENED
              bra sound_play
sound_play_pacman_dying:
              lda #SOUND_PACMAN_DYING
              bra sound_play

sound_update: ldx #0  ; start with channel 1 (bit 0)
              lda sound_play_state
@next:        lsr
              sta r1
              bcc :+
              jsr sound_play_chn
:             inx
              lda r1
              bne @next
@exit:        rts

; X - channel
sound_play_chn:
.ifdef __ASSERTIONS
              cpx #channels+1
              bcc :+
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

              bit chn_meta,x
              bpl :+
.ifndef __NO_SOUND
              lda sound_tmp
              ora #$a0
              tax
              lda #0             ; key off
              jsr opl2_reg_write
              lda sound_tmp
              ora #$b0
              tax
              lda #0             ; key off
              jsr opl2_reg_write
.endif
:             lda sound_tmp      ; channel 0..8
              ora #$a0
              tax                ; register to X
              lda (p_sound), y   ; note F-Number lsb
              iny
.ifndef __NO_SOUND
              jsr opl2_reg_write
.endif
              lda sound_tmp
              ora #$b0
              tax                ; register to X
              lda (p_sound), y    ; note Key-On / Octave / F-Number msb
              iny
.ifndef __NO_SOUND
              jsr opl2_reg_write
.endif
              lda (p_sound),y     ; delay
              iny
              ldx sound_tmp
              sta chn_cnt,x
              tya
              sta chn_ix,x

@exit:        rts


sound_init:   jsr sound_off

              opl_reg $c0, 0 ; FM mode
              opl_reg $01, 1<<5 ; WS on
              ;IMPROVE - use instrument table
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

              ;modulator op1  - interlude
              opl_reg $20,  1
              opl_reg $40,  (SCALE_3 | ($3f-48)) ; key scale / level
              opl_reg $60,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $80,  (10<<4 | (15 & $0f)) ; SR
              opl_reg $e0,  WS_ABS_SIN ;PULSE_SIN
              ;carrier op2
              opl_reg $23,  1
              opl_reg $43,  (SCALE_0 | ($3f-59))
              opl_reg $63,  (13<<4 | (4 & $0f))  ; attack / decay
              opl_reg $83,  (11<<4 | (13 & $0f))  ; sustain / release
              opl_reg $e3,  WS_ABS_SIN ;PULSE_SIN

              ;channel 2
              ; modulator op1
              opl_reg $21,  1
              opl_reg $41,  (SCALE_3 | ($3f-48)) ; key scale / level
              opl_reg $61,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $81,  (10<<4 | (15 & $0f))  ; SR
              opl_reg $e1,  WS_PULSE_SIN
              ; carrier op2
              opl_reg $24,  1
              opl_reg $44,  (SCALE_0 | ($3f-59))
              opl_reg $64,  (13<<4 | (4 & $0f))   ; attack / decay
              opl_reg $84,  (11<<4 | (13 & $0f))  ; sustain / release
              opl_reg $e4,  WS_PULSE_SIN


              ;channel 3 - pacman dots
              ;modulator op1
              opl_reg $22,  1
              opl_reg $42,  (SCALE_0 | ($3f-46)) ; key scale / level
              opl_reg $62,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $82,  (10<<4 | (0 & $0f))  ; SR
              opl_reg $e2,  WS_PULSE_SIN ; wave select
              ;carrier op2
              opl_reg $25,  1
              opl_reg $45,  (SCALE_0 | ($3f-46))
              opl_reg $65,  (13<<4 | (2 & $0f))  ; attack / decay
              opl_reg $85,  (8<<4 | (12 & $0f))  ; sustain / release
              opl_reg $e5,  WS_HALF_SIN

              ;channel 4 - fruits/bonus
              ;modulator op1
              opl_reg $28,  1
              opl_reg $48,  (SCALE_1_5 | ($3f-58)) ; key scale / level
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
              opl_reg $49,  (SCALE_0 | ($3f-42)) ; key scale / level
              opl_reg $69,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $89,  (12<<4 | (14 & $0f))  ; SR
              opl_reg $e9,  WS_SIN ; wave select
              ;carrier op2
              opl_reg $2c,  1
              opl_reg $4c,  (SCALE_0 | ($3f-42))
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
              opl_reg $50,  (SCALE_1_5 | ($3f-48)) ; key scale / level
              opl_reg $70,  (15<<4 | (1 & $0f))  ; AD
              opl_reg $90,  (10<<4 | (0 & $0f))  ; SR
              opl_reg $f0,  WS_PULSE_SIN  ; wave select
              ;carrier op2
              opl_reg $33,  1
              opl_reg $53,  (SCALE_0 | ($3f-59))
              opl_reg $73,  (13<<4 | (2 & $0f))   ; attack / decay
              opl_reg $93,  (10<<4 | (14 & $0f))  ; sustain / release
              opl_reg $f3,  WS_PULSE_SIN

              ;channel 8 - pacman dying
              ;modulator op1
              opl_reg $31,  1
              opl_reg $51,  (SCALE_0 | (0)) ; key scale / level
              opl_reg $71,  (15<<4 | (15 & $0f))  ; AD
              opl_reg $91,  (1<<4 | (15 & $0f))  ; SR
              opl_reg $f1,  WS_SIN ; wave select
              ;carrier op2
              opl_reg $34,  1 | 1<<6  ; vibrato on
              opl_reg $54,  (SCALE_0 | (0))
              opl_reg $74,  (15<<4 | (1 & $0f))  ; attack / decay
              opl_reg $94,  (15<<4  | (15 & $0f))  ; sustain / release
              opl_reg $f4,  WS_HALF_SIN
              ; vibrato on, 14ct
              opl_reg $bd, 1<<6

channels=8
              ldx #<channel_init    ; pointer to init data
              ldy #>channel_init
              lda #1<<(channels-1)  ; channel bit, start with highest
sound_init_channel:
              stx p_sound
              sty p_sound+1
              sta r1
              ldx #0
:             inx
              lsr
              bne :-
              txa
              asl                   ; *4 - 4 byte channel init
              asl
              dea
              tay
              dex                   ; x-1 loop count
:             stz chn_ix,x          ; note index
              lda #L64
              sta chn_cnt,x
              lda (p_sound),y
              sta chn_meta,x
              dey
              lda (p_sound),y
              sta chn_length,x
              dey
              lda (p_sound),y
              sta chn_notes_h,x
              dey
              lda (p_sound),y
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
channel_init_prelude:
    init_channel_snd game_sound_prelude_1, game_sound_prelude_1_end
    init_channel_snd game_sound_prelude_2, game_sound_prelude_2_end
    init_channel_sfx game_sfx_pacman, game_sfx_pacman_end
    init_channel_sfx game_sfx_eat_fruit,game_sfx_eat_fruit_end
    init_channel_sfx game_sfx_ghost_alarm, game_sfx_ghost_alarm_end
    init_channel_sfx game_sfx_eat_ghost, game_sfx_eat_ghost_end
    init_channel_sfx game_sfx_frightened, game_sfx_frightened_end
    init_channel_sfx game_sfx_pacman_dying, game_sfx_pacman_dying_end
channel_init_interlude:
    init_channel_snd game_interlude_sound, game_interlude_sound_end
    init_channel_snd game_interlude_sound_bass, game_interlude_sound_bass_end

game_sfx_pacman_dying:
              .include "pacman.dying.dat"
              soundEnd
game_sfx_pacman_dying_end:

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
                note ($200-(i*$50)), 3, L64
              .endrepeat
              .repeat 10, i
                note ((i+1)*$20), 3, L64
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


; game start sound - https://musescore.com/user/26532651/scores/4753776
game_interlude_sound:
    ; 1 takt
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_D, 5, L8
    note NOTE_C, 5, L8
    ; 2 takt
    note NOTE_F, 5, L8
    note NOTE_F, 5, L4
    note NOTE_A, 5, L2
    note NOTE_A, 5, L8
    ; 3 takt
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_D, 5, L8
    note NOTE_C, 5, L8
    ; 4 takt
    note NOTE_F, 5, L8
    note NOTE_F, 5, L4
    note NOTE_D, 5, L2
    note NOTE_D, 5, L8
    ; 5 takt
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_D, 5, L8
    note NOTE_C, 5, L8
    ; 6 takt
    note NOTE_F, 5, L8
    note NOTE_F, 5, L4
    note NOTE_Gis, 5, L4
    note NOTE_Ais, 5, L4
    note NOTE_B, 5, L8
    ; 7 takt
    note NOTE_B, 5, L8
    note NOTE_Ais, 5, L4
    note NOTE_Gis, 5, L4
    note NOTE_F, 5, L4
    note NOTE_Gis, 5, L8
    ; 8 Takt
    note NOTE_Gis, 5, (3*L8)
    note NOTE_Gis, 5, L8
    note NOTE_F, 5, L2
    soundEnd
game_interlude_sound_end:

game_interlude_sound_bass:
    ; 1 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    ; 2 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_A, 2, L8
    note NOTE_Ais, 2, L8
    note NOTE_B, 2, L8
    note NOTE_C, 3, L8
    ; 3 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    ; 4 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_A, 2, L8
    note NOTE_Ais, 2, L8
    note NOTE_B, 2, L8
    note NOTE_C, 3, L8
    ; 5 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    ; 6 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_A, 2, L8
    note NOTE_Ais, 2, L8
    note NOTE_B, 2, L8
    note NOTE_C, 3, L8
    ; 7 Takt
    note NOTE_F, 3, L4
    note NOTE_C, 3, L8
    note NOTE_Ais, 2, L8
    note NOTE_Gis, 2, L4
    note NOTE_F, 2, L4
    ; 8 Takt
    note NOTE_Dis, 2, L4
    note NOTE_E, 2, L4
    note NOTE_F, 2, L4
    pause L4
    soundEnd
game_interlude_sound_bass_end:

; game start sound - https://musescore.com/user/26532651/scores/4753776
;game_interlude_sound:
    ; 1 takt
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_D, 5, L8
    note NOTE_C, 5, L8
    ; 2 takt
    note NOTE_F, 5, L8
    note NOTE_F, 5, L4
    note NOTE_A, 5, L2
    note NOTE_A, 5, L8
    ; 3 takt
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_D, 5, L8
    note NOTE_C, 5, L8
    ; 4 takt
    note NOTE_F, 5, L8
    note NOTE_F, 5, L4
    note NOTE_D, 5, L2
    note NOTE_D, 5, L8
    ; 5 takt
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_F, 5, L4
    note NOTE_D, 5, L8
    note NOTE_C, 5, L8
    ; 6 takt
    note NOTE_F, 5, L8
    note NOTE_F, 5, L4
    note NOTE_Gis, 5, L4
    note NOTE_Ais, 5, L4
    note NOTE_B, 5, L8
    ; 7 takt
    note NOTE_B, 5, L8
    note NOTE_Ais, 5, L4
    note NOTE_Gis, 5, L4
    note NOTE_F, 5, L4
    note NOTE_Gis, 5, L8
    ; 8 Takt
    note NOTE_Gis, 5, (3*L8)
    note NOTE_Gis, 5, L8
    note NOTE_F, 5, L2
    soundEnd
;game_interlude_sound_end:

;game_interlude_sound_bass:
    ; 1 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    ; 2 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_A, 2, L8
    note NOTE_Ais, 2, L8
    note NOTE_B, 2, L8
    note NOTE_C, 3, L8
    ; 3 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    ; 4 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_A, 2, L8
    note NOTE_Ais, 2, L8
    note NOTE_B, 2, L8
    note NOTE_C, 3, L8
    ; 5 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    ; 6 Takt
    note NOTE_F, 2, 3*L8
    note NOTE_F, 2, L8
    note NOTE_A, 2, L8
    note NOTE_Ais, 2, L8
    note NOTE_B, 2, L8
    note NOTE_C, 3, L8
    ; 7 Takt
    note NOTE_F, 3, L4
    note NOTE_C, 3, L8
    note NOTE_Ais, 2, L8
    note NOTE_Gis, 2, L4
    note NOTE_F, 2, L4
    ; 8 Takt
    note NOTE_Dis, 2, L4
    note NOTE_E, 2, L4
    note NOTE_F, 2, L4
    pause L4
    soundEnd
;game_interlude_sound_bass_end:

game_sound_prelude_1: ; piano
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
game_sound_prelude_1_end:

game_sound_prelude_2:
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
game_sound_prelude_2_end:

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

      chn_bit:      .res channels
      chn_cnt:      .res channels
      chn_ix:       .res channels
      chn_notes_l:  .res channels
      chn_notes_h:  .res channels
      chn_length:   .res channels
      chn_meta:     .res channels
