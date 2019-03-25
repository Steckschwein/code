      .setcpu "65c02"
      .include "zeropage.inc"
      .include "common.inc"
      .include "kernel_jumptable.inc"
      .include "vdp.inc"
      .include "appstart.inc"

      .import vdp_init_reg
      .import vdp_memcpy
      .import vdp_fill, vdp_fills

appstart

main:
      jsr krn_textui_disable

      jsr intro

      jsr game
      
      keyin

      jmp (retvec)

intro:
      rts

game:
      jsr init_video
      rts

init_video:
      lda #<vdp_init_bytes
      ldy #>vdp_init_bytes
      ldx #(vdp_init_bytes_end-vdp_init_bytes)-1
      jsr vdp_init_reg

      vdp_sreg <ADDRESS_GFX3_PATTERN, WRITE_ADDRESS | >ADDRESS_GFX3_PATTERN
      lda #<tiles
      ldy #>tiles
      ldx #08
      jsr vdp_memcpy
      
      
      vdp_sreg <ADDRESS_GFX3_COLOR, WRITE_ADDRESS | >ADDRESS_GFX3_COLOR
      ldx #$18
      lda #Light_Blue<<4 | Transparent
      jsr vdp_fill

      vdp_sreg <ADDRESS_GFX3_SCREEN, WRITE_ADDRESS | >ADDRESS_GFX3_SCREEN
      ldx #4
      lda #' '
      jsr vdp_fill

      vdp_sreg <ADDRESS_GFX3_SCREEN, WRITE_ADDRESS | >ADDRESS_GFX3_SCREEN
      ldx #128
      lda #'@'
      jsr vdp_fills
      ldx #128
      lda #'0'
      jsr vdp_fills
      ldx #128
      lda #'1'
      jsr vdp_fills
      ldx #128
      lda #'2'
      jsr vdp_fills
      ldx #128
      lda #'3'
      jsr vdp_fills
      ldx #128
      lda #'4'
      jsr vdp_fills
      ldx #32
      lda #'6'
      jsr vdp_fills
      ldx #32
      lda #'7'
      jsr vdp_fills
      ldx #32
      lda #'8'
      jsr vdp_fills
      
      vdp_sreg <ADDRESS_GFX3_SCREEN, WRITE_ADDRESS | >ADDRESS_GFX3_SCREEN
      vdp_wait_s
      lda #'@'
      sta a_vram

      rts

vdp_init_bytes:
			.byte v_reg0_m4		; 
			.byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
			.byte (ADDRESS_GFX3_SCREEN / $400)  ; name table - value * $400
			.byte	$80     ; color table setting for gfx mode 2 --> only Bit 7 is taken into account 0 => at vram $0000, 1 => at vram $2000, Bit 6-0 AND to character number
			.byte	$00     ; pattern table - either at vram $0000 (Bit 2 = 0) or at vram $2000 (Bit 2=1), Bit 0,1 are AND to select the pattern array
			.byte	(ADDRESS_GFX3_SPRITE / $80)	; sprite attribute table - value * $80 --> offset in VRAM
			.byte	(ADDRESS_GFX3_SPRITE_PATTERN / $800)	; sprite pattern table - value * $800  --> offset in VRAM
			.byte	Black
			.byte v_reg8_VR	; VR - 64k VRAM TODO set per define
			.byte v_reg9_nt | v_reg9_ln
vdp_init_bytes_end:

.data
tiles:
      .include "pacman.tiles.inc"