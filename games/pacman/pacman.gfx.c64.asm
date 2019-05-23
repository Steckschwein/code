      .export gfx_init
      .export gfx_mode_on
      .export gfx_mode_off
      .export gfx_blank_screen
      .export gfx_sprites_off
      .export gfx_bgcolor
      .export gfx_bordercolor
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
      .export Color_Dark_Pink
      
      .import game_state
      
      .import sys_crs_x,sys_crs_y
      
      .include "pacman.c64.inc"

      
      ;sprite y = 50, 250 off
      ;sprite x = 24
      ;
.code
gfx_mode_off:
      
gfx_mode_on:
      lda #(VRAM_SCREEN>>6 | VRAM_PATTERN>>10)
      sta VIC_VIDEO_ADR
      
      lda #$ff
      sta VIC_SPR_ENA
      lda #%01010100
      sta VIC_SPR_MCOLOR
      
gfx_rotate_pal:
      rts
      
gfx_vblank:
      lda #254
:     cmp VIC_HLINE
      bne :-
      lda Color_Blue
      sta VIC_BORDERCOLOR
      sta VIC_BG_COLOR0
      lda #255
:     cmp VIC_HLINE
      bne :-
      lda Color_Bg
      sta VIC_BORDERCOLOR
      sta VIC_BG_COLOR0
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
      jsr _gfx_memcpy
gfx_init_sprites:
      lda sprite_patterns
      setPtr VRAM_SCREEN, p_video

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
      rts

gfx_update:
      lda #7
      sta gfx_tmp
:     lda gfx_tmp
      tax
      asl
      asl
      tay
      lda sprite_tab_attr+SpriteTab::shape,y
      sta VRAM_SPRITE_POINTER, x
      lda sprite_tab_attr+SpriteTab::color,y
      sta VIC_SPR0_COLOR, x
      
      lda gfx_tmp
      asl
      tax
      lda sprite_tab_attr+SpriteTab::xpos,y
      sta VIC_SPR0_X, x
      lda sprite_tab_attr+SpriteTab::ypos,y
      sta VIC_SPR0_Y, x
      dec gfx_tmp
      bpl :-

      rts
gfx_sprites_off:
      rts
      
gfx_display_maze:
_gfx_setcolor:
      ldx #4
      ldy #0
      sty sys_crs_x
      sty sys_crs_y
      setPtr game_maze, p_maze
@loop:
      lda (p_maze), y
      sta gfx_tmp
      cmp #Char_Food
      bne @s_food
      lda Color_Food
      bne @color
@s_food:
      cmp #Char_Superfood
      bne @text
      lda Color_Food
      bne @color
@text:
      cmp #Char_Bg
      bne @color_border
      lda Color_Pink
      bne @color
@color_border:
      bcs @color_bg
      lda Color_Gray
      bne @color
@color_bg:
      lda Color_Border
@color:
      sta text_color
      lda gfx_tmp
      jsr gfx_charout
      inc sys_crs_x
      lda sys_crs_x
      cmp #32
      bne @next
      inc sys_crs_y
      lda #0
      sta sys_crs_x
@next:
      iny 
      bne @loop
      inc p_maze+1
      dex
      bne @loop
      rts 
      
      setPtr game_maze, p_tmp
      setPtr VRAM_SCREEN, p_video
      ldx #4
_gfx_memcpy:
      ldy #0
:     lda (p_tmp),y
      sta (p_video),y
      iny
      bne :-
      inc p_tmp+1
      inc p_video+1
      dex
      bne :-
      rts
      
gfx_charout:
      pha
      sty gfx_tmp
      
      lda #0
      sta p_video+1
      sta p_tmp+1
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
      sta p_tmp
      lda #>VRAM_SCREEN
      adc p_video+1
      sta p_video+1
      clc
      adc #>(VRAM_COLOR-VRAM_SCREEN)
      sta p_tmp+1
      pla
      ldy #0
      sta (p_video),y
      lda text_color
      sta (p_tmp),y
      ldy gfx_tmp
      rts
      
gfx_hires_off:  ;?!?
      rts
gfx_bordercolor:
      sta VIC_BORDERCOLOR
      rts
gfx_bgcolor:
      sta VIC_BG_COLOR0
      rts
      
gfx_pause:
      rts


.data
.export sprite_patterns
sprite_patterns:
      .include "pacman.ghosts.res"
      .include "pacman.pacman.res"
tiles:
      .include "pacman.tiles.rot.inc"

Color_Bg:         .byte COLOR_BLACK
Color_Red:        .byte COLOR_RED
Color_Pink:       .byte COLOR_VIOLET
Color_Cyan:       .byte COLOR_CYAN
Color_Light_Blue: .byte COLOR_LIGHTBLUE
Color_Orange:     .byte COLOR_ORANGE
Color_Yellow:     .byte COLOR_YELLOW
Color_Dark_Cyan:  .byte COLOR_CYAN
Color_Blue:       .byte COLOR_BLUE
Color_Gray:       .byte COLOR_GRAY3
Color_Dark_Pink:  .byte COLOR_LIGHTRED

gfx_Sprite_Adjust_X:
      .byte 24+8
gfx_Sprite_Adjust_Y:
      .byte 50+8
gfx_Sprite_Off:
      .byte 250
      