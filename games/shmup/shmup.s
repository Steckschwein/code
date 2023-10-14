.include "steckos.inc"
.include "vdp.inc"

.autoimport

;.export char_out=krn_chrout

appstart $1000

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

    vdp_vram_w ADDRESS_GFX7_SPRITE_PATTERN
    lda #<sprite_pattern
    ldy #>sprite_pattern
    ldx #(sprite_pattern_end - sprite_pattern)
    jsr vdp_memcpys

    vdp_vram_w ADDRESS_GFX7_SPRITE_COLOR
    lda #<sprite_color
    ldy #>sprite_color
    ldx #2*16 ; 16x16 sprites
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
  bpl  isr_end
  lda  #%00011100
  jsr vdp_bgcolor

  lda  #0
   jsr  vdp_bgcolor
isr_end:
  rts


.data
sprite_attr:
sprite_attr_1:
  sprite_y: .byte 150
  sprite_x: .byte 150
  pattern:  .byte 0
  .byte 0
sprite_attr_2:
  sprite_2_y: .byte 100
  sprite_2_x: .byte 100
  pattern_2:  .byte 4
  .byte 0

  .byte SPRITE_OFF+8  ; all other sprites off
sprite_attr_end:

sprite_pattern:
sprite_0:
  .byte 255
  .byte 254
  .byte 255
  .byte 255
  .byte 254
  .byte 255
  .byte 1
  .byte 3

  .byte $0
  .byte $0
  .byte $0
  .byte $0
  .byte $0
  .byte $0
  .byte $0
  .byte $0

  .byte $0
  .byte $0
  .byte $0
  .byte $0
  .byte $0
  .byte $0
  .byte $0
  .byte $0

  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255
  .byte 255

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
  .byte Cyan
  .byte Light_Red
  .byte Light_Blue
  .byte Light_Yellow
  .byte Dark_Green
  .byte Gray
  .byte White

  .byte Medium_Red
  .byte Medium_Green
  .byte Light_Green
  .byte Magenta
  .byte Dark_Blue
  .byte Dark_Yellow
  .byte Dark_Red
  .byte Gray
; sprite 2 color
  .byte White
  .byte White
  .byte White
  .byte White
  .byte White
  .byte White
  .byte White
  .byte White

  .byte White
  .byte White
  .byte White
  .byte White
  .byte White
  .byte White
  .byte White
  .byte White
sprite_color_end:

.bss
save_isr: .res 2
