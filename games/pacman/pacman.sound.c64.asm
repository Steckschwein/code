.p02
.include "pacman.c64.inc"

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

.autoimport

.zeropage
              r1:         .res 1
              sound_tmp:  .res 1
              p_sound:    .res 2

.code


SOUND_GAME_PRELUDE      = 1<<0 | 1<<1 ; channel 1,2
SOUND_PACMAN            = 1<<2        ; channel 3
SOUND_EAT_FRUIT         = 1<<3        ; ...
SOUND_GHOST_ALARM       = 1<<4
SOUND_GHOST_CATCHED     = 1<<5        ; ...
SOUND_GHOST_FRIGHTENED  = 1<<6        ; channel 7
SOUND_PACMAN_DYING      = 1<<7
SOUND_GAME_INTERLUDE    = 1<<0 | 1<<1

L2        =32
L4        =16
L8        =8
L16       =4
L32       =2
L64       =1

BASEFREQ=440
PAL_PHI = 985248
NTSC_PHI = 1022727; //This is for machines with 6567R8 VIC. 6567R56A is slightly different.
CONSTANT = (256*256*256) / PAL_PHI; //Select the constant appropriate for your machine (PAL vs NTSC).

;SID_FREQ = CONSTANT * FREQ_HZ; //Calculate SID freq for a certain note (specified in Hz).

NOTE_C    =CONSTANT * 523;523,3
NOTE_Cis  =CONSTANT * 554;554,4
NOTE_D    =CONSTANT * 587;587,3
NOTE_Dis  =CONSTANT * 622;622,3
NOTE_E    =CONSTANT * 659;659,3
NOTE_F    =CONSTANT * 699;698,5
NOTE_Fis  =CONSTANT * 740
NOTE_G    =CONSTANT * 784
NOTE_Gis  =CONSTANT * 830;830,6
NOTE_A    =CONSTANT * 880
NOTE_Ais  =CONSTANT * 932;932,4
NOTE_B    =CONSTANT * 988;987,8

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

.macro init_channel s, e
    .addr s
    .byte e-s
.endmacro

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

sound_off:
sound_reset:
              rts

sound_init:

    ;lda #(15<<4 | (1 & $0f))  ; AD
    lda #$22;#97
    sta SID_AD1
;    lda #(10<<4 | (0 & $0f))  ; SR
    lda #$c0
    sta SID_SUR1

    lda #$ff
;    sta SID_PB1Lo
;    sta SID_PB1Hi

    lda #33  ; 1<<6|1      ;PULSE_SIN
    sta SID_Ctl1

;    lda #<(SCALE_3 | ($3f-48)) ; key scale / level

;    lda #(15<<4 | (1 & $0f))  ; AD
    lda #$00
    sta SID_AD2
;    lda #(10<<4 | (0 & $0f))  ; SR
    lda #$80
    sta SID_SUR2
    lda #$17
    sta SID_Ctl2  ; WS_PULSE_SIN

    lda #$f8
    sta SID_PB1Lo
    sta SID_PB1Hi

    lda #$0f
    sta SID_Amp
    lda #$0  ;Filter used on middle (melody) voice.
;    sta SID_FltCtl

    rts

sound_play_eat_dot:
.ifdef __DEVMODE
              rts
.endif
              lda #SOUND_PACMAN
sound_play:   bit game_state+GameState::state ; intro?
              bmi @exit
              ora sound_play_state
              sta sound_play_state
@exit:        rts
sound_play_game_interlude:
              lda #SOUND_GAME_INTERLUDE
              bne sound_play
sound_play_game_prelude:
.ifdef __DEVMODE
;              rts
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

sound_update: ldx #0  ; start with channel 1 (bit 0)
              lda sound_play_state
:             lsr
              sta r1
              bcc :+
              jsr sound_play_chn
:             inx
              lda r1
              bne :--
@exit:        rts

sound_play_chn:
              dec chn_cnt,x
              bne @exit
              lda chn_ix,x    ; data channel
              cmp chn_length,x
              bne @next_note
              lda #0
              sta chn_ix,x
              lda #L64
              sta chn_cnt,x
              ;stp
              lda sound_play_state
              eor chn_bit,x
              sta sound_play_state
              rts

@next_note:   stx sound_tmp  ; voice ix
              tay ; index to y
              lda chn_notes_l,x
              sta p_sound+0
              lda chn_notes_h,x
              sta p_sound+1

              txa
              asl
              asl
              asl
              tax
              dex
              lda #8
              sta SID_Ctl1,x

              lda (p_sound), y   ; note F-Number lsb
              iny
              sta SID_S1Lo,x
              lda (p_sound), y   ; note Key-On / Octave / F-Number msb
              iny
              sta SID_S1Hi,x

              lda #21
              sta SID_Ctl1,x

              lda (p_sound), y   ; delay
              iny
              ldx sound_tmp
              sta chn_cnt,x
              tya
              sta chn_ix,x
@exit:
              rts

.data

channel_init:
;    init_channel game_interlude_sound, game_interlude_sound_end
 ;   init_channel game_interlude_sound_bass, game_interlude_sound_bass_end
    init_channel game_start_sound1, game_start_sound1_end
    init_channel game_start_sound2, game_start_sound2_end
;    init_channel game_sfx_pacman, game_sfx_pacman_end
 ;   init_channel game_sfx_eat_fruit,game_sfx_eat_fruit_end
  ;  init_channel game_sfx_ghost_alarm, game_sfx_ghost_alarm_end
   ; init_channel game_sfx_eat_ghost, game_sfx_eat_ghost_end
    ;init_channel game_sfx_frightened, game_sfx_frightened_end
    ;init_channel game_snd_pacman_dying, game_snd_pacman_dying_end

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

.bss
      sound_play_state:   .res 1
      chn_cnt:            .res 8
      chn_ix:             .res 8
      chn_notes_l:        .res 8
      chn_notes_h:        .res 8
      chn_length:         .res 8
      chn_bit:            .res 8
