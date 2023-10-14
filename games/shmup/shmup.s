.include "steckos.inc"
.include "vdp.inc"

.autoimport

;.export char_out=krn_chrout

appstart $1000

.code

    sei
    copypointer user_isr, save_isr
    SetVector isr, user_isr

  ;  lda #255
  ;  sta sprite_1_x
  ;  lda #225
  ;  sta sprite_2_x
  ;  lda #195
  ;  sta sprite_3_x
  ;  lda #165
  ;  sta sprite_4_x

    jsr gfxui_on

    vdp_vram_w ADDRESS_GFX7_SPRITE
    lda #<sprite_attr
    ldy #>sprite_attr
    ldx #(sprite_attr_end - sprite_attr)
    jsr vdp_memcpys

    vdp_vram_w ADDRESS_GFX7_SPRITE_PATTERN
    lda #<sprite_pattern
    ldy #>sprite_pattern
    ldx #(sprite_pattern_end - sprite_pattern)
    jsr vdp_memcpys

    vdp_vram_w ADDRESS_GFX7_SPRITE_COLOR
    lda #<sprite_color
    ldy #>sprite_color
    ldx #4*16
    jsr vdp_memcpys

    cli

    keyin

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

  ldy #$0f
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

isr:
  bit  a_vreg
  bmi @go
  jmp  isr_end
@go:
  lda  #%00011100
  jsr vdp_bgcolor

  vdp_vram_w ADDRESS_GFX7_SPRITE
  lda #<sprite_attr
  ldy #>sprite_attr
  ldx #(sprite_attr_end - sprite_attr)
  jsr vdp_memcpys

  ldx sprite_1_x
  lda sintable,x
  sta sprite_1_y
  dec sprite_1_x

  ldx sprite_2_x
  lda sintable,x
  sta sprite_2_y
  dec sprite_2_x

  ldx sprite_3_x
  lda sintable,x
  sta sprite_3_y
  dec sprite_3_x

  ldx sprite_4_x
  lda sintable,x
  sta sprite_4_y
  dec sprite_4_x

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
  sprite_1_x: .byte 255
  pattern:  .byte 0
  .byte 0
sprite_attr_2:
  sprite_2_y: .byte 0
  sprite_2_x: .byte 205
  pattern_2:  .byte 0
  .byte 0
sprite_attr_3:
  sprite_3_y: .byte 0
  sprite_3_x: .byte 145
  pattern_3:  .byte 0
  .byte 0
sprite_attr_4:
  sprite_4_y: .byte 0
  sprite_4_x: .byte 95
  pattern_4:  .byte 0
  .byte 0

  .byte SPRITE_OFF+8  ; all other sprites off
sprite_attr_end:

sprite_pattern:
sprite_0:
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0

  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255

  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255


  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0
sprite_2:
  .byte 255
  .byte 220
  .byte 100
  .byte 50
  .byte 255
  .byte 220
  .byte 100
  .byte 50

  .byte 255
  .byte 220
  .byte 100
  .byte 50
  .byte 255
  .byte 220
  .byte 100
  .byte 50

  .byte 255
  .byte 220
  .byte 100
  .byte 50
  .byte 255
  .byte 220
  .byte 100
  .byte 50

  .byte 255
  .byte 220
  .byte 100
  .byte 50
  .byte 255
  .byte 220
  .byte 100
  .byte 50
sprite_pattern_end:

sprite_color:
  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue

  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue
  .byte Light_Blue
  ; .byte Light_Blue
  ; .byte Cyan
  ; .byte Light_Red
  ; .byte Light_Blue
  ; .byte Light_Yellow
  ; .byte Dark_Green
  ; .byte Gray
  ; .byte White

  ; .byte Medium_Red
  ; .byte Medium_Green
  ; .byte Light_Green
  ; .byte Magenta
  ; .byte Dark_Blue
  ; .byte Dark_Yellow
  ; .byte Dark_Red
  ; .byte Gray
; sprite 2 color
  .byte Cyan
  .byte Cyan
  .byte Cyan
  .byte Cyan
  .byte Cyan
  .byte Cyan
  .byte Cyan
  .byte Cyan

  .byte Cyan
  .byte Cyan
  .byte Cyan
  .byte Cyan
  .byte Cyan
  .byte Cyan
  .byte Cyan
  .byte Cyan

; sprite 3 color
  .byte Light_Green
  .byte Light_Green
  .byte Light_Green
  .byte Light_Green
  .byte Light_Green
  .byte Light_Green
  .byte Light_Green
  .byte Light_Green

  .byte Light_Green
  .byte Light_Green
  .byte Light_Green
  .byte Light_Green
  .byte Light_Green
  .byte Light_Green
  .byte Light_Green
  .byte Light_Green

; sprite 4 color
  .byte Magenta
  .byte Magenta
  .byte Magenta
  .byte Magenta
  .byte Magenta
  .byte Magenta
  .byte Magenta
  .byte Magenta

  .byte Magenta
  .byte Magenta
  .byte Magenta
  .byte Magenta
  .byte Magenta
  .byte Magenta
  .byte Magenta
  .byte Magenta
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
.byte 128, 132, 136, 140, 143, 146, 148, 151, 153, 154, 155, 156, 156, 156, 155, 154, 153, 151, 149, 146, 143, 140, 136, 132, 128, 124, 119, 115, 110, 105, 100, 95, 90, 86, 81

.bss
save_isr: .res 2
