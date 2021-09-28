.include "steckos.inc"
.include "vdp.inc"

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

      lda #<circle_0
      ldy #>circle_0
      jsr gfx_circle

    keyin

    jsr	krn_textui_init

    jmp (retvec)

.data
line_0:
   .word 0,0,511,191
   .byte Cyan<<4|White ; color
line_1:
   .word 0,191,511,0
   .byte Cyan<<4|White ; color
line_2:
   .word 255,0,257,191
   .byte Cyan<<4|White ; color
line_3:
   .word 0,96,511,96
   .byte Cyan<<4|White ; color

circle_0:
   .word 256
   .byte 96
   .byte 80
   .byte Cyan; color

charset:
    .include "../bios/charset_8x8.asm"
