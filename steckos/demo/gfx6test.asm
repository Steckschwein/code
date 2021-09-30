.include "steckos.inc"
.include "vdp.inc"
.include "gfx.inc"

.import vdp_gfx6_on
.import vdp_gfx6_blank
.import vdp_fill

.import gfx_line
.import gfx_circle

appstart

.code

    jsr	krn_textui_disable			;disable textui

    jsr vdp_gfx6_on

    lda #Black<<4|Black
    jsr vdp_gfx6_blank

    vdp_vram_r ADDRESS_TEXT_PATTERN
    vdp_vram_w ADDRESS_GFX6_SCREEN

;    lda #Cyan<<4
;    ldx #192  ;lines
;    jsr vdp_fill

      lda #<line_0
      ldy #>line_0
      jsr gfx_line

      lda #<line_1
      ldy #>line_1
      jsr gfx_line

      lda #<line_2
      ldy #>line_2
      jsr gfx_line

      lda #<line_3
      ldy #>line_3
      jsr gfx_line

:     lda #<circle_0
      ldy #>circle_0
      jsr gfx_circle
      lsr circle_0+circle_t::radius

      bne :-

    keyin

    jsr	krn_textui_init

    jmp (retvec)

.data
line_0:
   .word 0
   .byte 0
   .word 511
   .byte 191
   .byte Cyan<<4|White ; color
   .byte 0 ; op
line_1:
   .word 0
   .byte 191
   .word 511
   .byte 0
   .byte Cyan<<4|White ; color
   .byte 0 ; op
line_2:
   .word 255
   .byte 0
   .word 257
   .byte 191
   .byte Cyan<<4|White ; color
   .byte 0 ; op
line_3:
   .word 0
   .byte 96
   .word 511
   .byte 96
   .byte Cyan<<4|White ; color
   .byte 0 ; op

circle_0:
   .word 256
   .byte 96
   .word 72
   .byte Cyan; color
   .byte 0 ; op

charset:
    .include "../bios/charset_8x8.asm"
