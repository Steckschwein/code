      .include "steckos.inc"
      .include "vdp.inc"

      .import vdp_gfx6_on
      .import vdp_gfx6_blank
      .import vdp_fill

.import gfx_line

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

    keyin

    jsr	krn_textui_init

    jmp (retvec)

.data
line_0:
   .word 0,0,511,211
   .byte White<<4|White ; color
line_1:
   .word 0,106,511,106
   .byte Cyan<<4|Cyan ; color

charset:
    .include "../bios/charset_8x8.asm"
