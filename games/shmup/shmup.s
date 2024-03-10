.include "shmup.inc"

.autoimport

.export fopen=krn_fopen
.export fclose=krn_close
.export fread_byte=krn_fread_byte

appstart $1000
PLAYER_SPRITE_NR = 7

.code
    stz keyb

    sei
    copypointer user_isr, save_isr
    SetVector isr, user_isr

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

  jsr gfxui_off
  sei
  copypointer save_isr, user_isr
  cli
  jmp (retvec)


gfxui_on:
              jsr krn_textui_disable      ;disable textui

              jsr vdp_mode2_on                        ; enable gfx2 mode
              vdp_sreg v_reg0_m4 | v_reg0_IE1, v_reg0 ; enable gfx3 mode with h blank irq
              vdp_sreg >(ADDRESS_GFX3_COLOR<<2) , v_reg3      ; R#3 - color table setting for gfx mode 2 --> only Bit 7 is taken into account 0 => at vram $0000, 1 => at vram $2000, Bit 6-0 AND to character number
              vdp_sreg >(ADDRESS_GFX3_PATTERN>>3) , v_reg4    ; R#4 - pattern table base address - Bit 0,1 are AND to select the pattern array

              vdp_sreg v_reg8_VR, v_reg8
              vdp_sreg v_reg9_nt, v_reg9  ; 212px

              vdp_sreg 191-(4*8), v_reg19

              stz _scroll_x_l
              stz _scroll_x_h
              stz _scroll_y

              vdp_vram_w (ADDRESS_GFX3_PATTERN)
              lda #<chars_2x2_numbers
              ldy #>chars_2x2_numbers
              ldx #2
              jsr vdp_memcpy
              lda #0
              ldx #6
              jsr vdp_fill

              jsr starfield_init

              vdp_vram_w (ADDRESS_GFX3_COLOR)
              lda #Dark_Yellow<<4
              ldx #3
              jsr vdp_fill

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
              sei

              pha
              phx
              vdp_sreg v_reg9_nt, v_reg9  ; 192px
              jsr krn_textui_init
              plx
              pla

              cli

              rts

SP_OFFS_Y = 10

starfield_screen:
              vdp_vram_w (ADDRESS_GFX3_SCREEN)
              ldy #20-1
:             lda @stars_dist,y
              ora #$40
              ldx #32
:             vdp_wait_l
              and #$5f
              sta a_vram
              ina
              dex
              bne :-
              dey
              bpl :--
              rts

; (echo -n ".byte " && for i in $(seq 0 20);do echo -n $(expr $RANDOM % 32);[ "$(expr $i % 32)" -lt 20 ] && echo -n ",";done) > games/shmup/stars_dist.inc
@stars_dist:
  .include "stars_dist.inc"

starfield_init:
              vdp_vram_w (ADDRESS_GFX3_PATTERN+16*8*4)  ; after numbers
              lda #0 ; 32*8 chars blank
              tax
              jsr vdp_fills

              ldy #64-1

:             lda @stars_position,y
              and #$f8
              sta vdp_tmp
              tya
              and #$07
              ora vdp_tmp
              sta a_vreg  ; set vdp vram address low byte
              lda #(>(ADDRESS_GFX3_PATTERN+16*8*4) | WRITE_ADDRESS) ; adjust for write
              vdp_wait_s 2
              sta a_vreg  ; set vdp vram address high byte

              lda @stars_position,y
              and #$07       ;2
              tax            ;2
              lda @bitmask,x ;4
              sta a_vram     ;4 read current byte in vram and OR with new pixel

              dey
              bpl :-
              rts
; (for i in $(seq 0 63);do [ "$(expr $i % 8)" -eq 0 ] && echo && echo -n ".byte ";echo -n $(expr $RANDOM % 256); [ "$(expr $i % 8)" -lt 7 ] && echo -n ",";done;echo) > games/shmup/stars.inc
@stars_position:
  .include "stars.inc"
@bitmask:
  .byte $80,$40,$20,$10,$08,$04,$02,$01


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
              lda a_vreg  ; check bit 0 of S#1
              ror
              bcc @is_vblank
@hblank:
              vdp_sreg $ff, v_reg7
              vdp_sreg 0, v_reg25   ; disable snall border
              vdp_sreg 0, v_reg26   ; stop scrolling
              vdp_sreg 7, v_reg27

              bra @isr_end

@is_vblank:
              vdp_sreg 0, v_reg15       ; 0 - set status register selection to S#0
              vdp_wait_s
              bit a_vreg
              bpl @isr_end              ; VDP IRQ flag set?

              lda #Cyan<<4|Cyan
              jsr vdp_bgcolor

              jsr sprity_mc_spriteface

              lda #Light_Red<<4|Light_Red
              jsr vdp_bgcolor

              ;jsr scroll

              jsr score_board

@isr_end:
              vdp_sreg v_reg25_msk | v_reg25_sp2, v_reg25 ; mask left border, activate 2 pages (4x32k mode 3 screens)
              vdp_sreg 1, v_reg15     ; setup status S#1 already

              lda #Black<4|Black
              jsr vdp_bgcolor

              rts


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
              bne @exit

              lda _scroll_x_h
              ina
              cmp #$40
              bne :+
              lda #0
:             sta _scroll_x_h
              ldy #v_reg26
              vdp_sreg
@exit:        rts


sprity_mc_spriteface:
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

.bss

score:    .res 3 ; 000000
save_isr: .res 2
keyb: .res 1

_scroll_x_l:  .res 1
_scroll_x_h:  .res 1
_scroll_y:    .res 1