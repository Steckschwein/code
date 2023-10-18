.include "steckos.inc"
.include "vdp.inc"

.autoimport

;.export char_out=krn_chrout

appstart $1000


.macro sp_pattern sp, chr
    vdp_vram_w (ADDRESS_GFX7_SPRITE_PATTERN + (sp*32));
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

    sei
    copypointer user_isr, save_isr
    SetVector isr, user_isr

    jsr gfxui_on

    vdp_vram_w ADDRESS_GFX7_SPRITE
    lda #<sprite_attr
    ldy #>sprite_attr
    ldx #(sprite_attr_end - sprite_attr)
    jsr vdp_memcpys

    sp_pattern 0, ('V'-64)  ;petscii
    sp_pattern 1, ('C'-64)
    sp_pattern 2, ('F'-64)
    sp_pattern 3, ('B'-64)

    sp_pattern 4, '2'
    sp_pattern 5, '0'
    sp_pattern 6, '2'
    sp_pattern 7, '3'
    lda #SPRITE_OFF+8 ; vram pointer still setup correctly
    sta a_vram

    cli

    lda #GFX7_Cyan
    sta sp_color

:   keyin
    cmp #KEY_ESCAPE
    beq @exit
    cmp #'n'
    bne :-
    inc sp_color

    bra :-
@exit:

    jsr gfxui_off

    sei
    copypointer save_isr, user_isr
    cli

    jmp (retvec)

gfxui_on:
  jsr krn_textui_disable      ;disable textui

  jsr vdp_mode7_on         ;enable gfx7 mode

  vdp_sreg v_reg8_VR, v_reg8
  vdp_sreg v_reg9_ln | v_reg9_nt, v_reg9  ; 212px

  ldy #0
  jsr vdp_mode7_blank

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

SP_OFFS_Y = 100

isr:
  bit  a_vreg
  bmi @go
  jmp  isr_end
@go:
  lda  #%00011100
  jsr vdp_bgcolor

  vdp_vram_w ADDRESS_GFX7_SPRITE_COLOR
  lda sp_color
  eor #$80
  ldx #(16*8)
  jsr vdp_fills

  ldx sprite_1_x
  lda sintable,x
  lsr
  clc
  adc #SP_OFFS_Y
  sta sprite_1_y
  dec sprite_1_x

  ldx sprite_2_x
  lda sintable,x
  lsr
  clc
  adc #SP_OFFS_Y
  sta sprite_2_y
  dec sprite_2_x

  ldx sprite_3_x
  lda sintable,x
  lsr
  clc
  adc #SP_OFFS_Y
  sta sprite_3_y
  dec sprite_3_x

  ldx sprite_4_x
  lda sintable,x
  lsr
  clc
  adc #SP_OFFS_Y
  sta sprite_4_y
  dec sprite_4_x

  ldx sprite_5_x
  lda sintable,x
  lsr
  clc
  adc #SP_OFFS_Y
  sta sprite_5_y
  dec sprite_5_x

  ldx sprite_6_x
  lda sintable,x
  lsr
  clc
  adc #SP_OFFS_Y
  sta sprite_6_y
  dec sprite_6_x

  ldx sprite_7_x
  lda sintable,x
  lsr
  clc
  adc #SP_OFFS_Y
  sta sprite_7_y
  dec sprite_7_x

  ldx sprite_8_x
  lda sintable,x
  lsr
  clc
  adc #SP_OFFS_Y
  sta sprite_8_y
  dec sprite_8_x

  vdp_vram_w ADDRESS_GFX7_SPRITE
  lda #<sprite_attr
  ldy #>sprite_attr
  ldx #(sprite_attr_end - sprite_attr)
  jsr vdp_memcpys

  lda  #0
  jsr  vdp_bgcolor
isr_end:
  rts


.data
sprite_attr:
sprite_attr_1:
  sprite_1_y: .byte 0
  sprite_1_x: .byte 95
  pattern:  .byte 0
  .byte 0
sprite_attr_2:
  sprite_2_y: .byte 0
  sprite_2_x: .byte 105
  pattern_2:  .byte 4
  .byte 0
sprite_attr_3:
  sprite_3_y: .byte 0
  sprite_3_x: .byte 115
  pattern_3:  .byte 8
  .byte 0
sprite_attr_4:
  sprite_4_y: .byte 0
  sprite_4_x: .byte 125
  pattern_4:  .byte 12
  .byte 0
sprite_attr_5:
  sprite_5_y: .byte 0
  sprite_5_x: .byte 145
  pattern_5:  .byte 16
  .byte 0
sprite_attr_6:
  sprite_6_y: .byte 0
  sprite_6_x: .byte 155
  pattern_6:  .byte 20
  .byte 0
sprite_attr_7:
  sprite_7_y: .byte 0
  sprite_7_x: .byte 165
  pattern_7:  .byte 24
  .byte 0
sprite_attr_8:
  sprite_8_y: .byte 0
  sprite_8_x: .byte 175
  pattern_8:  .byte 28
  .byte 0


  .byte SPRITE_OFF+8  ; all other sprites off
sprite_attr_end:

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
.byte 128, 132, 136, 140, 143, 146, 148, 151, 153, 154, 155, 156, 156, 156, 155, 154, 153, 151, 149, 146, 143, 140, 136, 132, 128, 124, 119, 115, 110, 105, 100, 95, 90, 86, 81

font:
.include "../demo/2x2_font.inc"

.bss
sp_color: .res 1
save_isr: .res 2
