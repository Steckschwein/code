.include "steckos.inc"
.include "vdp.inc"

.autoimport
appstart $1000
PLAYER_SPRITE_NR = 6

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

    vdp_vram_w ADDRESS_GFX7_SPRITE_COLOR
    lda #<sprite_color
    ldy #>sprite_color
    ldx #(sprite_color_end - sprite_color)
    jsr vdp_memcpys

    ; vdp_vram_w ADDRESS_GFX7_SPRITE_COLOR
    ; lda #GFX7_LightCyan
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
    keyin

    cmp #KEY_CRSR_UP
    beq @up

    cmp #KEY_CRSR_DOWN
    beq @down

    cmp #KEY_CRSR_LEFT
    beq @left

    cmp #KEY_CRSR_RIGHT
    beq @right

    cmp #KEY_ESCAPE
    beq @exit

    bra @loop

@up:
    dec sprite_attr + 4*PLAYER_SPRITE_NR + SPRITE_Y 
    bra @loop
@down:
    inc sprite_attr + 4*PLAYER_SPRITE_NR + SPRITE_Y
    bra @loop
@left:
    dec sprite_attr + 4*PLAYER_SPRITE_NR + SPRITE_X 
    beq @toggle_dingsbit
    bra @loop
@right:
    inc sprite_attr + 4*PLAYER_SPRITE_NR + SPRITE_X 
    bra @loop
@toggle_dingsbit:
    ldx #15
:
    lda sprite_color_6,x
    eor #$80
    sta sprite_color_6,x
    dex
    bne :-
    bra @loop
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

SP_OFFS_Y = 10

isr:
  bit  a_vreg
  bpl isr_end

  lda  #%00011100
  jsr vdp_bgcolor

  jsr sprity_mc_spriteface

  lda  #0
  jsr  vdp_bgcolor
isr_end:
  rts

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

  vdp_vram_w ADDRESS_GFX7_SPRITE
  lda #<sprite_attr
  ldy #>sprite_attr
  ldx #(sprite_attr_end - sprite_attr)
  jsr vdp_memcpys

  vdp_vram_w ADDRESS_GFX7_SPRITE_COLOR
  lda #<sprite_color
  ldy #>sprite_color
  ldx #(sprite_color_end - sprite_color)
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
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80

  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
  .byte GFX7_LightBlue | $20 | $80
; sprite 1
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80

  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80
  .byte GFX7_LightRed | $20 | $80

; sprite 2
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80

  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
  .byte GFX7_LightYellow | $20 | $80
; sprite 3
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80

  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
  .byte GFX7_LightGreen | $20 | $80
; sprite 4
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80

  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
  .byte GFX7_LightMagenta | $20 | $80
; sprite 5
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80

  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
  .byte GFX7_White | $20 | $80
; sprite 6
sprite_color_6:
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80

  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
  .byte GFX7_LightCyan | $20 | $80
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

font:
.include "../demo/2x2_font.inc"

.bss
sp_color: .res 1
save_isr: .res 2
