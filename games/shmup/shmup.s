.include "steckos.inc"
.include "vdp.inc"

.autoimport

.export fopen=krn_fopen
.export fclose=krn_close
.export fread_byte=krn_fread_byte

appstart $1000
PLAYER_SPRITE_NR = 6

.macro sp_pattern sp, chr
    vdp_vram_w (ADDRESS_GFX3_SPRITE_PATTERN + (sp*32));
    lda #<(font+(chr*8)+0*$200)
    ldy #>(font+(chr*8)+0*$200)
    ldx #8
    jsr vdp_memcpys
    lda #<(font+(chr*8)+2*$200)
    ldy #>(font+(chr*8)+2*$200)
    ldx #8
    jsr vdp_memcpys
    lda #<(font+(chr*8)+1*$200)
    ldy #>(font+(chr*8)+1*$200)
    ldx #8
    jsr vdp_memcpys
    lda #<(font+(chr*8)+3*$200)
    ldy #>(font+(chr*8)+3*$200)
    ldx #8
    jsr vdp_memcpys
.endmacro

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
    lda #<sprite_color
    ldy #>sprite_color
    ldx #(sprite_color_end - sprite_color)
    jsr vdp_memcpys

    ; vdp_vram_w ADDRESS_GFX3_SPRITE_COLOR
    ; lda #Cyan
    ; ldx #(16*8)
    ; jsr vdp_fills


    sp_pattern 0, ('T' - 64)
    sp_pattern 1, ('H' - 64)
    sp_pattern 2, ('O' - 64)
    sp_pattern 3, ('M' - 64)
    sp_pattern 4, ('A' - 64)
    sp_pattern 5, ('S' - 64)
    sp_pattern 6, ('X' - 64)
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

  jsr vdp_mode2_on                        ; enable gfx3 mode
  vdp_sreg v_reg0_m4 | v_reg0_IE1, v_reg0 ; enable h blank irq

  vdp_sreg v_reg8_VR, v_reg8
  vdp_sreg v_reg9_ln | v_reg9_nt, v_reg9  ; 212px

  vdp_sreg v_reg25_msk | v_reg25_sp2, v_reg25 ; mask left border, activate 2 pages (2x64k mode 7 screens)

  vdp_sreg 212-5*8, v_reg19

  stz _scroll_x_l
  stz _scroll_x_h
  stz _scroll_y

  lda #0
  jsr vdp_mode3_blank

  vdp_vram_w (ADDRESS_GFX3_PATTERN+8)
  lda #1
  sta a_vram
  lda #2
  sta a_vram

  vdp_vram_w (ADDRESS_GFX3_COLOR+8)
  lda #White<<4
  sta a_vram
  lda #Gray<<4
  sta a_vram

  vdp_vram_w (ADDRESS_GFX3_PATTERN+($10*8))
  lda #<chars_text
  ldy #>chars_text
  ldx #10*8
  jsr vdp_memcpys

  vdp_vram_w (ADDRESS_GFX3_COLOR+($10*8))
  lda #White<<4
  ldx #$18
  jsr vdp_fills

  vdp_vram_w ADDRESS_GFX3_SCREEN
  ldx #32
: vdp_wait_l
  lda #1
  sta a_vram
  dex
  bne :-

  vdp_vram_w (ADDRESS_GFX3_SCREEN+(20*32))
  ldx #0
  lda #0
: vdp_wait_l
  sta a_vram
  ina
  dex
  bne :-

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

score_board:
              lda #White<<4|White
              jsr vdp_bgcolor
;              vdp_sreg 0, v_reg0  ;
 ;            vdp_sreg v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_spr_size|v_reg1_m1, v_reg1  ; #R01
              vdp_sreg 0, v_reg26
              vdp_sreg 0, v_reg27

              ldy #120
:             dey
              bne :-
              rts

isr:
              lda a_vreg  ; check bit 0 of S#1
              ror
              bcc @is_vblank
@hblank:
              jsr score_board
              bra @isr_end

@is_vblank:
              vdp_sreg 0, v_reg15      ; 0 - set status register selection to S#0
              vdp_wait_s
              bit a_vreg
              bpl @isr_end       ; VDP IRQ flag set?

              lda #Cyan<<4|Cyan
              jsr vdp_bgcolor
;              vdp_sreg v_reg0_m4 | v_reg0_IE1, v_reg0 ; enable h blank irq
 ;             vdp_sreg v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_spr_size, v_reg1

; @write_colortable:
;   vdp_vram_w ADDRESS_GFX3_SPRITE_COLOR
;   lda #<sprite_color
;   ldy #>sprite_color
;   ldx #(sprite_color_end - sprite_color)
;   jsr vdp_memcpys
              jsr sprity_mc_spriteface
              lda_vdp_rgb 100,100,100
              jsr vdp_bgcolor
              jsr scroll

@isr_end:
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

  cpx #(4*6)
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
  sprite_7_y: .byte SPRITE_OFF+8
  sprite_7_x: .byte 165
  pattern_7:  .byte 28
  .byte 0

  ; .byte SPRITE_OFF+8  ; all other sprites off
sprite_attr_end:
sprite_color:
; sprite 0
  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20

  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20
  .byte Light_Blue | $20

; sprite 1
  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20

  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20
  .byte Light_Red | $20

; sprite 2
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20

  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20
  .byte Light_Yellow | $20

; sprite 3
  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20

  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20
  .byte Light_Green | $20

; sprite 4
  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20

  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20
  .byte Magenta | $20

; sprite 5
  .byte White | $20
  .byte White | $20
  .byte White | $20
  .byte White | $20
  .byte White | $20
  .byte White | $20
  .byte White | $20
  .byte White | $20

  .byte White | $20
  .byte White | $20
  .byte White | $20
  .byte White | $20
  .byte White | $20
  .byte White | $20
  .byte White | $20
  .byte White | $20

; sprite 6
  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20

  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20
  .byte Cyan | $20
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

bgppm01: .asciiz "shmup.ppm"
bgppm02: .asciiz "shmupbg2.ppm"

font:
.include "../demo/2x2_font.inc"

lookup:
  .byte 0,16,32,48,64,80,96
.bss
sp_color: .res 1
save_isr: .res 2
keyb: .res 1

_scroll_x_l:  .res 1
_scroll_x_h:  .res 1
_scroll_y:    .res 1