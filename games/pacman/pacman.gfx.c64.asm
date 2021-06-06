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

VIC_SPR_MCOLOR_DEFAULT = %00101010 ; 3 ghost eyes as multic color, sprite 7 is multiplexed either ghost eyes or pacman
VIC_SPR_MCOLOR_MX = %10101010 ; 4 ghost exes if multiplexed

SPRITE_SIZE_Y=21
SPRITE_SIZE_X=24

gfx_Sprite_Adjust_X=12
gfx_Sprite_Adjust_Y=39
gfx_Sprite_Off=250

.struct mx_sprite
	xp	.byte
	yp	.byte
	pp	.byte	; pattern
	mc	.byte ; multi color  bitmask
.endstruct

.code
gfx_mode_off:

gfx_mode_on:
		lda #(VRAM_SCREEN>>6 | VRAM_PATTERN>>10)
		sta VIC_VIDEO_ADR	; $d018

		lda #$ff
		sta VIC_SPR_ENA
		lda #VIC_SPR_MCOLOR_DEFAULT
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
		lda #$61		; pattern open border
		sta $3fff	; last byte bank 0 - we open the border
		lda Color_Bg
		sta VIC_BORDERCOLOR
		sta VIC_BG_COLOR0
		ldx #$0f
		lda #0
:		sta VIC_SPR0_X,x
		dex
		bpl :-
		lda Color_Blinky
		sta VIC_SPR0_COLOR
		lda Color_Pinky
		sta VIC_SPR2_COLOR
		lda Color_Inky
		sta VIC_SPR4_COLOR
		lda Color_Clyde
		sta VIC_SPR6_COLOR
		lda Color_Pacman
		sta VIC_SPR7_COLOR

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
		jsr @gfx_test_sp_y
		bcs @exit ; no further check
		ldx #ACTOR_INKY
		jsr @gfx_test_sp_y
		bcs @exit ; no further check
		ldx #ACTOR_PINKY
		jsr @gfx_test_sp_y
		bcs @exit ; no further check
		ldx #ACTOR_CLYDE
		;fall through
; test ghost y with pacman y
; X - ghost index
@gfx_test_sp_y:	;
		lda actors+actor::sp_y,x
		sec
		sbc actors+actor::sp_y,y
		bpl :+
		eor #$ff ; absolute |y1 - y2|
:		cmp #SPRITE_SIZE_Y ; >=21px size distance
@exit:
		rts

.macro _gfx_update_ghost _a, _mx
	.local _n
	_n = _a / .sizeof(actor); _n => actor number 0..3
	lda actors+actor::sp_y+_a
	clc
	adc #gfx_Sprite_Adjust_Y
	sta VIC_SPR0_Y+_n*4 ; *4 => 2 x 2 sprites vic registers
.if _mx = 0
	sta VIC_SPR1_Y+_n*4
.else
	sta mx_tab+_mx*.sizeof(mx_sprite)+mx_sprite::yp
.endif
	;clc - assume, we never overflow above
	lda actors+actor::sp_x+_a
	adc #gfx_Sprite_Adjust_X
	sta VIC_SPR0_X+_n*4
.if _mx = 0
	sta VIC_SPR1_X+_n*4
.else
	sta mx_tab+_mx*.sizeof(mx_sprite)+mx_sprite::xp
.endif
	ldy actors+actor::shape+_a
	lda shapes+0,y
	sta VRAM_SPRITE_POINTER+0+_n*2
	lda shapes+2,y
	cmp #offs+30            ; eyes up? TODO FIXME performance avoid cmp
	bne :+
.if _mx = 0
	dec VIC_SPR1_X+_n*4     ; adjust 1px left if eyes up on 2nd sprite
:	sta VRAM_SPRITE_POINTER+1+_n*2
.else
	dec mx_tab+_mx*.sizeof(mx_sprite)+mx_sprite::xp     ; adjust 1px left if eyes up on 2nd sprite
:	sta mx_tab+_mx*.sizeof(mx_sprite)+mx_sprite::pp
	lda #VIC_SPR_MCOLOR_MX
	sta mx_tab+_mx*.sizeof(mx_sprite)+mx_sprite::mc
.endif
.endmacro

.macro _gfx_update_pacman
		.local _a, _mx
		_mx=0
		_a = ACTOR_PACMAN
		lda actors+actor::sp_y+_a
		clc
		adc #gfx_Sprite_Adjust_Y
		sta mx_tab+_mx*.sizeof(mx_sprite)+mx_sprite::yp
		;clc - assume, we never overflow above
		lda actors+actor::sp_x+_a
		adc #gfx_Sprite_Adjust_X
		sta mx_tab+_mx*.sizeof(mx_sprite)+mx_sprite::xp
		ldy actors+actor::shape+_a
		lda shapes,y
		sta mx_tab+_mx*.sizeof(mx_sprite)+mx_sprite::pp
		lda #VIC_SPR_MCOLOR_DEFAULT
		sta mx_tab+_mx*.sizeof(mx_sprite)+mx_sprite::mc
.endmacro

gfx_update:
		_gfx_update_ghost ACTOR_BLINKY, 0
		_gfx_update_ghost ACTOR_INKY, 0
		_gfx_update_ghost ACTOR_PINKY, 0
		_gfx_update_ghost ACTOR_CLYDE, 1 ; 1 - mx sprite, eyes of clyde are multiplexed with pacman
		_gfx_update_pacman

		lda #COLOR_YELLOW
		sta VIC_BORDERCOLOR

		jsr _gfx_is_sp_collision	; 9th sprite collision ?
		bcs @set_hline	; C=1 no collision, otherwise X ghost, Y pacman with collision
		;TODO share eyes inky / clyde
		;TODO disable mx
		rts

@set_hline:
		ldx #ACTOR_CLYDE
		lda actors+actor::sp_y,y
      cmp actors+actor::sp_y,x
		ldy #0*.sizeof(mx_sprite)
      bcc :+
		ldy #1*.sizeof(mx_sprite)
:		sty mx_tab_ix
		lda mx_tab+mx_sprite::yp,y
		clc
		adc #SPRITE_SIZE_Y	; hline irq after current sprite - 21 scanline
		cmp #HLine_Border
		bcs gfx_mx				; skip if below border
		sta VIC_HLINE
.export gfx_mx
gfx_mx:
		ldy mx_tab_ix
		lda mx_tab+mx_sprite::yp,y
		sta VIC_SPR7_Y
		lda mx_tab+mx_sprite::xp,y
		sta VIC_SPR7_X
		lda mx_tab+mx_sprite::pp,y
		sta VRAM_SPRITE_POINTER+7
		lda mx_tab+mx_sprite::mc,y
		sta VIC_SPR_MCOLOR

		tya
		eor #.sizeof(mx_sprite)
		sta mx_tab_ix
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
	.byte offs+20,offs+21,offs+28,offs+28 ;r  00
	.byte offs+22,offs+23,offs+29,offs+29 ;l  01
	.byte offs+24,offs+25,offs+30,offs+30 ;u  10
	.byte offs+26,offs+27,offs+31,offs+31 ;d  11

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
mx_tab_ct: .res 1 ; multiplex counter
mx_tab_ix: .res 1
mx_tab:
	.tag mx_sprite
	.tag mx_sprite
