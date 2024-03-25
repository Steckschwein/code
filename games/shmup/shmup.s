.include "shmup.inc"

.autoimport

.export fopen=krn_fopen
.export fclose=krn_close
.export fread_byte=krn_fread_byte

appstart $1000
PLAYER_SPRITE_NR = 7

.zeropage
    r1:  .res 1

    rx1:  .res 2

    scr_offs: .res 1

    seed: .res 1
    frames: .res 1
    hblank: .res 1


.code
    stz keyb

    sei
    copypointer SYS_VECTOR_IRQ, save_isr
    SetVector isr, SYS_VECTOR_IRQ

    jsr gfxui_on

    vdp_vram_w ADDRESS_GFX3_SPRITE
    lda #<sprite_attr
    ldy #>sprite_attr
    ldx #(sprite_attr_end - sprite_attr)
    jsr vdp_memcpys

    vdp_vram_w ADDRESS_GFX3_SPRITE_COLOR
    ldy #0
:   lda sprite_colors,y
    ldx #16
    jsr vdp_fills
    iny
    cpy #8
    bne :-

chroffs=-48
    sp_pattern 0, ('0' + chroffs)
    sp_pattern 1, ('1' + chroffs)
    sp_pattern 2, ('2' + chroffs)
    sp_pattern 3, ('3' + chroffs)
    sp_pattern 4, ('4' + chroffs)
    sp_pattern 5, ('5' + chroffs)
    sp_pattern 6, ('6' + chroffs)
    sp_pattern 7, ('7' + chroffs)
    ;lda #SPRITE_OFF+8 ; vram pointer still setup correctly
    ;sta a_vram
    cli

@loop:
  lda keyb

  cmp #KEY_ESCAPE
  beq @exit

  jsr krn_getkey
  sta keyb

  cmp #KEY_CRSR_UP
  beq @up

  cmp #KEY_CRSR_DOWN
  beq @down

  cmp #KEY_CRSR_LEFT
  beq @left

  cmp #KEY_CRSR_RIGHT
  beq @right

  bra @loop

@up:
  dec sprite_attr + 4*PLAYER_SPRITE_NR + SPRITE_Y
  bra @loop
@down:
  inc sprite_attr + 4*PLAYER_SPRITE_NR + SPRITE_Y
  bra @loop
@left:
  dec sprite_attr + 4*PLAYER_SPRITE_NR + SPRITE_X
  bra @loop
@right:
  inc sprite_attr + 4*PLAYER_SPRITE_NR + SPRITE_X
  bra @loop

; @set_dingsbit:
;   ldx #15
; :
;   lda sprite_color_6,x
;   ora #$80
;   sta sprite_color_6,x
;   dex
;   bne :-

;   bra @write_colortable

; @unset_dingsbit:
;   ldx #15
; :
;   lda sprite_color_6,x
;   and #%01111111
;   sta sprite_color_6,x
;   dex
;   bne :-



@exit:
              php
              sei
              jsr gfxui_off
              copypointer save_isr, SYS_VECTOR_IRQ
              plp
              jmp (retvec)


gfxui_on:
              jsr krn_textui_disable      ; disable textui

              jsr vdp_mode2_on                        ; enable gfx2 mode
              vdp_sreg v_reg0_m4 | v_reg0_IE1, v_reg0 ; R#0 enable gfx3 mode with h blank irq
              vdp_sreg >(ADDRESS_GFX3_COLOR<<2) | $0f , v_reg3      ; R#3 - color table setting for gfx mode 2 --> only Bit 7 is taken into account 0 => at vram $0000, 1 => at vram $2000, Bit 6-0 AND to character number
              vdp_sreg >(ADDRESS_GFX3_PATTERN>>3) , v_reg4    ; R#4 - pattern table base address - Bit 0,1 are AND to select the pattern array

              vdp_sreg v_reg8_VR, v_reg8
              vdp_sreg v_reg9_nt, v_reg9  ; 212px

              vdp_sreg 191-(4*8), v_reg19 ; h blank - scoreboard

              lda #33
              sta seed

              stz frames
              stz hblank
              stz _scroll_x_l
              stz _scroll_x_h
              stz _scroll_y

              lda #<ADDRESS_GFX3_SCREEN
              sta scr_offs

              vdp_vram_w (ADDRESS_GFX3_PATTERN)
              lda #<chars_2x2_numbers
              ldy #>chars_2x2_numbers
              ldx #2
              jsr vdp_memcpy

              ldx #6
              ldy #0
:             jsr rnd
              sta a_vram
              dey
              bne :-
              dex
              bne :-

              vdp_vram_w (ADDRESS_GFX3_COLOR)
              lda #Dark_Yellow<<4|Transparent
              ldx #2
              jsr vdp_fill
              lda #Dark_Blue<<4|Gray
              ldx #6
;              jsr vdp_fill
              ldy #0
:             jsr rnd
              sta a_vram
              dey
              bne :-
              dex
              bne :-

              jsr starfield_init

              vdp_vram_w (ADDRESS_GFX3_PATTERN+CHAR_BLANK*8)
              ldx #8
              lda #$0
              jsr vdp_fills
              vdp_vram_w (ADDRESS_GFX3_COLOR+CHAR_BLANK*8)
              ldx #8
              lda #Transparent<<4|Transparent
              jsr vdp_fills

CHAR_BLANK=$80
              vdp_vram_w ADDRESS_GFX3_SCREEN
              ldx #3
              lda #CHAR_BLANK
              jsr vdp_fill

              jsr starfield_screen

              stz score
              stz score+1
              stz score+2

              rts

gfxui_off:
              pha
              phx
              vdp_sreg v_reg9_nt, v_reg9  ; 192px
              jsr krn_textui_init
              plx
              pla
              rts

SP_OFFS_Y = 10

starfield_screen:
              vdp_vram_w (ADDRESS_GFX3_SCREEN)
              ldy #20-1 ; 20 lines
:             lda stars_distance,y
              ora #$40  ; char offset +64
              ldx #32   ; 32 chars per row
:             vdp_wait_l
              and #$5f  ; mask chars $40-$5f
              sta a_vram
              ina
              dex
              bne :-
              dey
              bpl :--
              rts

starfield_init:
              ldx #0  ; blank
:             stz starfield_chars,x
              dex
              bne :-

              ldy @stars_position ; n stars per 256x8 line
:             lda @stars_position,y
              and #$f8
              sta r1
              tya
              and #$07
              ora r1
              pha
              lda @stars_position,y
              and #$07
              tax
              lda @bitmask,x
              plx
              sta starfield_chars,x
              dey
              bne :-

              vdp_vram_w (ADDRESS_GFX3_COLOR+16*8*4)
              ldy #0 ; 32x8
:             tya
              and #$07
              tax
              lda @stars_colors,x
              vdp_wait_l
              sta a_vram
              iny
              bne :-
              rts

@stars_colors:
  .byte Dark_Yellow<<4,Light_Blue<<4,Dark_Yellow<<4,Gray<<4
  .byte Dark_Blue<<4,Dark_Yellow<<4,Dark_Yellow<<4,Dark_Blue<<4

; n=15 && (echo -n ".byte $n" && for i in $(seq 0 $n);do [ "$(expr $i % 8)" -eq 0 ] && echo && echo -n ".byte ";echo -n $(expr $RANDOM % 256); [ "$(expr $i % 8)" -lt 7 ] && echo -n ",";done;echo) > games/shmup/stars.inc
@stars_position:
  .include "stars.inc"
@bitmask:
  .byte $80,$40,$20,$10,$08,$04,$02,$01

starfield_scroll:
              lda #Dark_Green<<4|Dark_Green
              ;jsr vdp_bgcolor

              lda frames
              and #$07
              tay
              lda @stars_delay,y
              beq @exit
              sta r1
              ldx #$ff
:             inx
              cpx #8
              beq @exit
              asl r1
              bcc :-
              jsr @rotate
              bra :-
@exit:        rts

@stars_delay:
  .byte %00000000 ;
  .byte %11111111
  .byte %01111001
  .byte %10111110
  .byte %01011001
  .byte %11111111
  .byte %00110100
  .byte %11111111
;  2,3,4,5,5,4,2,3


@rotate:      lda starfield_chars+31*8,x
              lsr
              .repeat 32, i
                ror starfield_chars+i*8,x
              .endrepeat
              rts

startfield_update:
              vdp_vram_w (ADDRESS_GFX3_PATTERN+16*8*4)  ; cp star pattern to vram after numbers
              ldx #0 ; 32x8
              lda #<starfield_chars
              ldy #>starfield_chars
              jmp vdp_memcpys

level_script:
              lda #Light_Blue<<4|Light_Blue
              ;jsr vdp_bgcolor

              ; layer 0 - starfield
              ldy #20-1 ; 20 rows
              clc
:             lda stars_distance,y
              adc _scroll_x_h ; add scroll offset
              ora #$40  ; char offset +64
              and #$5f  ; mask starfield chars $40-$5f
              sta level_data,y
              dey
              bpl :-

; some random foreground
              jsr rnd
              and #$7
              sta r1
              tay
:
              jsr rnd
              ora #$80
              sta level_data,y
              dey
              bpl :-

              lda #13
              sec
              sbc r1
;              jsr rnd
              and #$7
              tax
              ldy #7
:
              jsr rnd
              ora #$80
              sta level_data+12,y
              dey
              dex
              bpl :-

              rts

rnd:
    lda seed
    beq @doEor
    asl
    beq @noEor ;if the input was $80, skip the EOR
    bcc @noEor
@doEor:
    eor #$1d
@noEor:
    sta seed
    rts

update_vram:
              lda #Magenta<<4|Magenta
              ;jsr vdp_bgcolor

              jsr startfield_update

              lda _scroll_x_l     ; only if soft scroll turns over
              bne @exit

              lda #<ADDRESS_GFX3_SCREEN
              clc
              adc _scroll_x_h
              and #$1f
              sta rx1
              lda #>ADDRESS_GFX3_SCREEN | WRITE_ADDRESS
              sta rx1+1

              ldy #20-1
:             lda rx1
              sta a_vreg
              clc
              adc #$20
              sta rx1
              lda rx1+1
              sta a_vreg         ; screen address
              adc #0
              sta rx1+1          ; rx1 next row
              lda level_data,y
              sta a_vram
              dey
              bpl :-
@exit:
              rts

score_board:
              lda #White<<4|White
              jsr vdp_bgcolor

              vdp_vram_w (ADDRESS_GFX3_SCREEN+(19+21*32))
              ldy #2
:             lda score,y
              lsr
              lsr
              lsr
              lsr
              vdp_wait_l 12
              sta a_vram
              ora #$10
              vdp_wait_l 2
              sta a_vram

              lda score,y
              and #$0f
              vdp_wait_l 6
              sta a_vram
              ora #$10
              vdp_wait_l 2
              sta a_vram
              dey
              bpl :-

              vdp_vram_w (ADDRESS_GFX3_SCREEN+(19+22*32))
              ldy #2
:             lda score,y
              lsr
              lsr
              lsr
              lsr
              ora #$20
              vdp_wait_l 14
              sta a_vram
              ora #$30
              vdp_wait_l 2
              sta a_vram

              lda score,y
              and #$0f
              ora #$20
              vdp_wait_l 6
              sta a_vram
              ora #$30
              vdp_wait_l 2
              sta a_vram
              dey
              bpl :-

              sed
              clc
              lda score
              adc #1
              sta score
              lda score+1
              adc #0
              sta score+1
              lda score+2
              adc #0
              sta score+2
              cld

              rts

isr:
              save

              lda a_vreg  ; check bit 0 of S#1
              ror
              bcc @is_vblank
@hblank_score:
              lda hblank
              bne @hblank_score_1
              vdp_sreg Gray<<4|Gray, v_reg7
              vdp_sreg v_reg25_wait, v_reg25  ; disable small border
              vdp_sreg 0, v_reg26             ; stop scrolling
              vdp_sreg 7, v_reg27
              lda #Gray<<4|Gray
              ldx #191-(4*8)+1              ; h blank - scoreboard + 1
              bra @score_board_line
@hblank_score_1:
              cmp #$01
              bne @hblank_score_2
              lda #Black<<4|Black
              ldx #190                      ; h blank - scoreboard
              bra @score_board_line
@hblank_score_2:
              cmp #$02
              bne @hblank_score_3
              lda #Gray<<4|Gray
              ldx #191                      ; h blank - scoreboard
              bra @score_board_line
@hblank_score_3:
              lda #Black<<4|Black
              ldx #191-(4*8)                ; h blank - scoreboard
              bra @score_board_line
@is_vblank:
              vdp_sreg 0, v_reg15       ; 0 - set status register selection to S#0
              vdp_wait_s
              bit a_vreg
              bpl @isr_end              ; VDP IRQ flag set?

              lda #Black<4|Black
              jsr vdp_bgcolor


              jsr sprity_mc_spriteface

              jsr starfield_scroll
              jsr level_script

              jsr update_vram
              jsr scroll

              jsr score_board
              inc frames
              stz hblank

              lda #Black<4|Black
              jsr vdp_bgcolor
              vdp_sreg v_reg25_wait | v_reg25_cmd | v_reg25_msk | v_reg25_sp2, v_reg25 ; mask left border, activate 2 pages (4x16k mode 3 screens)

@isr_end:
              vdp_sreg 1, v_reg15 ; setup status S#1 already

              restore
              rti

@score_board_line:
              inc hblank
              jsr vdp_bgcolor
              txa
              ldy #v_reg19
              jsr vdp_set_reg
              bra @isr_end

scroll:
              ldy #v_reg27
              lda _scroll_x_l
              ;dea
              dea
              bpl :+
              lda #$07
:             sta _scroll_x_l
              vdp_sreg

              cmp #$07
              bne @scroll_h

              inc scr_offs
              lda _scroll_x_h
              ina
              cmp #32 ; 32 8x8 tiles
              bne :+
              lda #<ADDRESS_GFX3_SCREEN
              sta scr_offs
              lda #0
:             sta _scroll_x_h
@scroll_h:    lda _scroll_x_h
              ldy #v_reg26
              vdp_sreg
              rts


sprity_mc_spriteface:

  lda #Cyan<<4|Cyan
;  jsr vdp_bgcolor

  ; start with sprite 0
  ldx #0
:
  ldy sprite_attr + SPRITE_X,x
  lda sintable,y
  lsr
  clc
  adc #SP_OFFS_Y
  sta sprite_attr + SPRITE_Y,x

  dec sprite_attr + SPRITE_X,x

  ; next sprite
  ; 4 bytes per sprite attr table entry
  inx
  inx
  inx
  inx

  cpx #(4*7)
  bne :-

  vdp_vram_w ADDRESS_GFX3_SPRITE
  lda #<sprite_attr
  ldy #>sprite_attr
  ldx #(sprite_attr_end - sprite_attr)
  jsr vdp_memcpys
  rts

.data

sprite_attr:
  sprite_0_y: .byte 0
  sprite_0_x: .byte 95
  pattern_0:  .byte 0
  .byte 0
  sprite_1_y: .byte 0
  sprite_1_x: .byte 105
  pattern_1:  .byte 4
  .byte 0
  sprite_2_y: .byte 0
  sprite_2_x: .byte 115
  pattern_2:  .byte 8
  .byte 0
  sprite_3_y: .byte 0
  sprite_3_x: .byte 125
  pattern_3:  .byte 12
  .byte 0
  sprite_4_y: .byte 0
  sprite_4_x: .byte 135
  pattern_4:  .byte 16
  .byte 0
  sprite_5_y: .byte 0
  sprite_5_x: .byte 145
  pattern_5:  .byte 20
  .byte 0
  sprite_6_y: .byte 0
  sprite_6_x: .byte 32
  pattern_6:  .byte 24
  .byte 0
  sprite_7_y: .byte 0
  sprite_7_x: .byte 165
  pattern_7:  .byte 28
  .byte 0
  sprite_last_y: .byte SPRITE_OFF+8  ; all other sprites off
  .byte 0,0,0
sprite_attr_end:

sprite_colors:
; sprite 0
  .byte Light_Blue | $20
; sprite 1
  .byte Light_Red | $20
; sprite 2
  .byte Light_Yellow | $20
; sprite 3
  .byte Light_Green | $20
; sprite 4
  .byte Magenta | $20
; sprite 5
  .byte White | $20
; sprite 6
  .byte Cyan | $20
; sprite 7
  .byte Gray | $20
sprite_color_end:

sintable:
.byte 105, 110, 114, 119, 124, 128, 132, 136
.byte 140, 143, 146, 148, 151, 153, 154, 155
.byte 156, 156, 156, 155, 154, 153, 151, 148
.byte 146, 143, 140, 136, 132, 128, 124, 119
.byte 114, 110, 105, 100, 95, 90, 86, 81, 76
.byte 72, 68, 64, 60, 57, 54, 52, 49, 47, 46
.byte 45, 44, 44, 44, 45, 46, 47, 49, 51, 54
.byte 57, 60, 64, 68, 72, 76, 81, 85, 90, 95
.byte 100, 105, 110, 114, 119, 124, 128, 132
.byte 136, 140, 143, 146, 148, 151, 153, 154
.byte 155, 156, 156, 156, 155, 154, 153, 151
.byte 149, 146, 143, 140, 136, 132, 128, 124
.byte 119, 115, 110, 105, 100, 95, 90, 86, 81
.byte 76, 72, 68, 64, 60, 57, 54, 52, 49, 47
.byte 46, 45, 44, 44, 44, 45, 46, 47, 49, 51
.byte 54, 57, 60, 64, 68, 72, 76, 81, 85, 90
.byte 95, 100, 105, 110, 114, 119, 124, 128
.byte 132, 136, 140, 143, 146, 148, 151, 153
.byte 154, 155, 156, 156, 156, 155, 154, 153
.byte 151, 149, 146, 143, 140, 136, 132, 128
.byte 124, 119, 115, 110, 105, 100, 95, 90
.byte 86, 81, 76, 72, 68, 64, 60, 57
.byte 54, 52, 49, 47, 46, 45, 44, 44
.byte 44, 45, 46, 47, 49, 51, 54, 57
.byte 60, 64, 68, 72, 76, 81, 85, 90
.byte 95, 100, 105, 110, 114, 119, 124
.byte 128, 132, 136, 140, 143, 146, 148, 151
.byte 153, 154, 155, 156, 156, 156, 155, 154
.byte 153, 151, 149, 146, 143, 140, 136, 132
.byte 128, 124, 119, 115, 110, 105, 100, 95
.byte 90, 86, 81

; (echo -n ".byte " && for i in $(seq 0 20);do echo -n $(expr $RANDOM % 32);[ "$(expr $i % 32)" -lt 20 ] && echo -n ",";done) > games/shmup/stars_dist.inc
stars_distance:
  .include "stars_dist.inc"

.bss
  level_data: .res 20 ; most right screen column where we put our level data into
  starfield_chars:  .res 32*8

  score:    .res 3 ; 000000
  save_isr: .res 2
  keyb: .res 1

_scroll_x_l:  .res 1
_scroll_x_h:  .res 1
_scroll_y:    .res 1