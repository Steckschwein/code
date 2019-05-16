      .export gfx_init
      .export gfx_mode_on
      .export gfx_mode_off
      .export gfx_blank_screen
      .export gfx_sprites_off
      .export gfx_bgcolor
      .export gfx_vblank

      .export gfx_charout
      .export gfx_rotate_pal
      .export gfx_update
      .export gfx_display_maze
      .export gfx_hires_off
      .export gfx_pause
      .export gfx_Sprite_Adjust_X,gfx_Sprite_Adjust_Y
      .export gfx_Sprite_Off

      .export Color_Bg
      .export Color_Red
      .export Color_Pink
      .export Color_Cyan
      .export Color_Light_Blue
      .export Color_Orange
      .export Color_Yellow
      .export Color_Dark_Cyan
      .export Color_Blue
      .export Color_Gray
      
      .import vdp_init_reg
      .import vdp_memcpy
      .import vdp_fill
      .import game_state;
      
      .import sys_crs_x,sys_crs_y
      
      .include "pacman.c64.inc"

      
      ;sprite y = 50, 250 off
      ;sprite x = 24
      ;
.code
      Color_Bg:         .byte $00
      Color_Red:        .byte $02
      Color_Pink:       .byte $04
      Color_Cyan:       .byte $03
      Color_Light_Blue: .byte $0e
      Color_Orange:     .byte $02
      Color_Yellow:     .byte $07
      Color_Dark_Cyan:  .byte $03
      Color_Blue:       .byte $06
      Color_Gray:       .byte COLOR_GRAY3

gfx_mode_off:
      
gfx_mode_on:
      lda #(VRAM_SCREEN>>6 | VRAM_PATTERN>>10)
      sta VIC_VIDEO_ADR
      
gfx_rotate_pal:
      rts
      
gfx_init:
      lda Color_Bg
      sta VIC_BORDERCOLOR
      sta VIC_BG_COLOR0
gfx_init_pal:
gfx_init_chars:
      ldx #8
      setPtr tiles,  p_tmp
      setPtr VRAM_PATTERN, p_video
      ldy #0
:     lda (p_tmp),y
      sta (p_video),y
      iny
      bne :-
      inc p_tmp+1
      inc p_video+1
      dex
      bne :-
gfx_init_sprites:
gfx_blank_screen:
      setPtr VRAM_SCREEN, p_video
      ldx #4
      ldy #0
      lda #0
:     sta (p_video),y
      iny
      bne :-
      inc p_video+1
      dex
      bne :-
      ldy #0
      lda #COLOR_GRAY3<<4|COLOR_GRAY3
:     sta VRAM_COLOR+$000,y
      sta VRAM_COLOR+$100,y
      sta VRAM_COLOR+$200,y
      sta VRAM_COLOR+$300,y
      dey 
      bne :-
      rts
      
gfx_sprites_off:

gfx_update:

gfx_display_maze:

gfx_charout:
      pha
      sty gfx_tmp
      lda #0
      sta p_video+1
      lda sys_crs_y ;.Y * 40 => y*8 + y*32
      asl
      asl
      asl
      sta p_video
      asl
      rol p_video+1
      asl
      rol p_video+1
      adc p_video
      bcc l_add
      inc	p_video+1; overflow inc page count
      clc
l_add:
      adc sys_crs_x
      sta p_video
      lda #>VRAM_SCREEN
      adc p_video+1
      sta p_video+1
      pla
      ldy #0
      sta (p_video),y
      ldy gfx_tmp
      rts
      
gfx_vblank:
gfx_hires_off:  ;?!?
      rts
gfx_bgcolor:
      sta VIC_BORDERCOLOR
      sta VIC_BG_COLOR0
      rts
      
gfx_pause:
      rts


.data
gfx_Sprite_Adjust_X:
      .byte 24+8
gfx_Sprite_Adjust_Y:
      .byte 50+8
gfx_Sprite_Off:
      .byte 250
      
tiles:
      .include "pacman.tiles.rot.inc"
sprite_patterns:
      .include "pacman.ghosts.res"
      .include "pacman.pacman.res"