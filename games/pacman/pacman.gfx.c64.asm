		.setcpu "6502"
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

gfx_Sprite_Adjust_X=12
gfx_Sprite_Adjust_Y=39
gfx_Sprite_Off=250

.code
gfx_mode_off:

gfx_mode_on:
		lda #(VRAM_SCREEN>>6 | VRAM_PATTERN>>10)
		sta VIC_VIDEO_ADR	; $d018

		lda #$ff
		sta VIC_SPR_ENA
		lda #%10101010
		sta VIC_SPR_MCOLOR

		lda Color_Gray
		sta VIC_SPR_MCOLOR0
		lda Color_Blue
		sta VIC_SPR_MCOLOR1

gfx_rotate_pal:
		rts

gfx_vblank:
		rts

gfx_init:
		lda Color_Bg
		sta VIC_BORDERCOLOR
		sta VIC_BG_COLOR0
		ldx #$0f
		lda #0
:		sta VIC_SPR0_X,x
		dex
		bpl :-
gfx_init_pal:
gfx_init_chars:
		ldx #8
		setPtr tiles,  p_tmp
		setPtr VRAM_PATTERN, p_video
		jsr _gfx_memcpy
		setPtr sprite_patterns, p_tmp
		setPtr VRAM_SPRITE_PATTERN, p_video
		ldx #9
		jsr _gfx_memcpy

gfx_blank_screen:
		setPtr VRAM_SCREEN, p_video
		ldx #4
		ldy #0
		lda #0
:	   sta (p_video),y
		iny
		bne :-
		inc p_video+1
		dex
		bne :-
		rts


_gfx_is_sp_collision:
		ldy #ACTOR_PACMAN
		ldx #ACTOR_BLINKY
		jsr _gfx_test_sp_y
		bcs  @exit ; no further check
		ldx #ACTOR_INKY
		jsr _gfx_test_sp_y
		bcs  @exit ; no further check
		ldx #ACTOR_PINKY
		jsr _gfx_test_sp_y
		bcs  @exit ; no further check
		ldx #ACTOR_CLYDE
		jsr _gfx_test_sp_y
@exit:
		rts

; test ghost y with pacman y
; X - ghost index
;
_gfx_test_sp_y:	;
		lda actors+actor::sp_y,x
		sec
		sbc actors+actor::sp_y,y
		bpl :+
		eor #$ff ; absolute |y1 - y2|
:		cmp #21 ; >=21px size distance
		rts

gfx_update:
		lda #1
		sta mx_ix
		lda #0
		ldy #ACTOR_BLINKY
		ldx #0
		jsr _gfx_update_sprites
		ldy #ACTOR_INKY
		lda #2
		ldx #4
		jsr _gfx_update_sprites
		ldy #ACTOR_PINKY
		lda #4
		ldx #8
		jsr _gfx_update_sprites
		ldy #ACTOR_CLYDE
		lda #6
		ldx #12
		jsr _gfx_update_sprites
		lda #COLOR_RED
		sta VIC_SPR0_COLOR
		lda #COLOR_CYAN
		sta VIC_SPR2_COLOR
		lda #COLOR_PURPLE
		sta VIC_SPR4_COLOR
		lda #COLOR_ORANGE
		sta VIC_SPR6_COLOR

		jsr _gfx_is_sp_collision
		bcs @set_hline	; C=1 no collision, X ghost, Y pacman
		lda #COLOR_WHITE
		sta VIC_BORDERCOLOR
		rts
@set_hline:
		lda actors+actor::sp_y,y
		cmp actors+actor::sp_y,x
		bcs :+
		adc #(gfx_Sprite_Adjust_Y-2)
		sta VIC_HLINE
		stx mx+0
		sty mx+1
		rts
:		lda actors+actor::sp_y,x
		clc
		adc #(gfx_Sprite_Adjust_Y-2)
		sta VIC_HLINE
		stx mx+1
		sty mx+0
		rts

.export gfx_mx
gfx_mx:
		ldx mx_ix
		ldy mx,x	; actor
		lda #0
		ldx #0
		jsr _gfx_update_sprites
		dec mx_ix
		bmi :+
		ldx mx_ix
		ldy mx,x
		lda actors+actor::sp_y,y
		clc
		adc #(gfx_Sprite_Adjust_Y-2)
		sta VIC_HLINE
		rts
:		lda #Border_HLine
		sta VIC_HLINE
		rts

_gfx_update_sprite_tab:
		sta _i

		lda actors+actor::sp_x,y
		clc
		adc #gfx_Sprite_Adjust_X
		sta sprite_tab_x,x
		sta sprite_tab_x2,x
		bcs :+
		lda #0
:		sta sprite_tab_xe,x	; <>0 to indicate ext x

		lda sprite_tab_xe,x
		bne :+
		;ora spr_mx_ora, x


		lda actors+actor::sp_y,y
		;clc assume no overflow
		adc #gfx_Sprite_Adjust_Y
		sta sprite_tab_y,x

		lda actors+actor::shape,y
		tay
		lda shapes+0,y
		cmp #offs+30		; eyes up? TODO FIXME performance avoid cmp
		bne :+
		dec sprite_tab_x2,x	; adjust 1px left if eyes up on 2nd sprite
:
		ldx _i
		sta sprite_tab_s,x
		lda shapes+2,y
		sta sprite_tab_s2,x
		;lda ?
		sta sprite_tab_c,x
		rts

_mx_code:
		;sta y ;4
		;sta y2 ;4

		;sta x ;4
		;stx s ; 4
		;stx c ; 4
		lda #2 ; 2
		;sta xe ; 4

		lda sprite_tab_y,x	;4	/ 2
		sta VIC_SPR0_Y,y		;5 / 4
		sta VIC_SPR1_Y,y		;5 / 4

		lda sprite_tab_s,x	;4 / 2
		sta VRAM_SPRITE_POINTER,x	;5 / 4
		lda sprite_tab_x,x			;4 / 2
		sta VIC_SPR0_X,y				;5 / 4
		lda sprite_tab_c,x			;4 / 2
		sta VIC_SPR0_COLOR,y			;5 / 4
		;36 / 24
		lda VIC_SPR_HI_X
		;bit
		sta VIC_SPR_HI_X


_gfx_update_sprites:
		sta _i
 		lda actors+actor::sp_y,y
		clc
		adc #gfx_Sprite_Adjust_Y
		sta VIC_SPR0_Y,x
		sta VIC_SPR1_Y,x

		;clc - assume, we never overflow above
		lda actors+actor::sp_x,y
		adc #gfx_Sprite_Adjust_X
		sta VIC_SPR0_X,x
		sta VIC_SPR1_X,x

		lda actors+actor::shape,y
		tay
		lda shapes+0,y
		cmp #offs+30		; eyes up? TODO FIXME performance avoid cmp
		bne :+
		dec VIC_SPR1_X,x	; adjust 1px left if eyes up on 2nd sprite
:
		ldx _i
		sta VRAM_SPRITE_POINTER+1,x
		lda shapes+2,y
		sta VRAM_SPRITE_POINTER+0,x
		rts

gfx_sprites_off:
		lda #0
		sta VIC_SPR_ENA

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
		lda Color_Text
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
:	  	lda (p_tmp),y
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
		inc p_video+1; overflow inc page count
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
shapes:
offs=VRAM_SPRITE_PATTERN / $40
; pacman			[		<	   O     <
		.byte offs+1,offs+0,offs+8,offs+0 ;r  00
		.byte offs+3,offs+2,offs+8,offs+2 ;l  01
		.byte offs+5,offs+4,offs+8,offs+4 ;u  10
		.byte offs+7,offs+6,offs+8,offs+6 ;d  11
; ghosts eyes | body
		.byte offs+28,offs+28,offs+20,offs+21 ;r  00
		.byte offs+29,offs+29,offs+22,offs+23 ;l  01
		.byte offs+30,offs+30,offs+24,offs+25 ;u  10
		.byte offs+31,offs+31,offs+26,offs+27 ;d  11
;

sprite_patterns:
		.include "pacman.c64.res"
tiles:
		.include "pacman.tiles.rot.inc"

Color_Bg:        	.byte COLOR_BLACK
Color_Red:        .byte COLOR_RED
Color_Pink:       .byte COLOR_VIOLET
Color_Cyan:       .byte COLOR_CYAN
Color_Light_Blue: .byte COLOR_LIGHTBLUE
Color_Orange:    	.byte COLOR_ORANGE
Color_Yellow:    	.byte COLOR_YELLOW
Color_Dark_Cyan:  .byte COLOR_CYAN
Color_Blue:       .byte COLOR_BLUE
Color_Gray:       .byte COLOR_GRAY3
Color_Dark_Pink:  .byte COLOR_LIGHTRED

.bss
sprite_tab_x:		.res 5;
sprite_tab_xe:		.res 5;
sprite_tab_x2:		.res 5;
sprite_tab_y:		.res 5;
sprite_tab_s:		.res 5;
sprite_tab_s2:		.res 5;
sprite_tab_c:		.res 5;
sprite_tab_c2:		.res 5;

mx:		.res 2
mx_ix:	.res 1
