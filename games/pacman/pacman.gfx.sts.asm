		.include "pacman.sts.inc"

		.export gfx_init
		.export gfx_mode_on
		.export gfx_mode_off
		.export gfx_blank_screen
		.export gfx_bgcolor
		.export gfx_bordercolor
		.export gfx_sprites_off
		.export gfx_vblank
		.export gfx_isr
		.export gfx_charout
		.export gfx_hires_on
		.export gfx_hires_off
		.export gfx_update
		.export gfx_display_maze
		.export gfx_pause

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

		;vdp
		.import vdp_bgcolor
		.import vdp_fill,vdp_fills
		.import vdp_memcpy,vdp_memcpys
		.import vdp_init_reg

		.import game_state
		.import game_maze

.struct SpriteTab
  ypos    .byte
  xpos    .byte
  shape   .byte
  color   .byte
.endstruct

.code
gfx_vblank:
		lda a_vreg
		sta vdp_sreg_0
		rts

gfx_mode_off:
		vdp_sreg 0, v_reg9	;
		vdp_sreg 0, v_reg23  ;
		rts

gfx_mode_on:
		lda #<vdp_init_bytes
		ldy #>vdp_init_bytes
		ldx #(vdp_init_bytes_end-vdp_init_bytes)-1
		jsr vdp_init_reg

		;vdp_sreg $0, v_reg18  ;x/y screen adjust
		;vdp_sreg <-2, v_reg23  ;y offset

		rts

gfx_pacman_colors_offset:
.byte VDP_Color_Blue<<1, VDP_Color_Light_Blue<<1, VDP_Color_Gray<<1, VDP_Color_Light_Blue<<1

.export gfx_rotate_pal
gfx_rotate_pal:
		vdp_sreg VDP_Color_Blue, v_reg16 ; rotate blue
		ldx gfx_pacman_colors_offset,y
gfx_write_pal:
		vdp_wait_s
		lda pacman_colors+0, x
		sta a_vregpal
		vdp_wait_s
		lda pacman_colors+1, x
		sta a_vregpal
		rts

gfx_isr:
    bit a_vreg ; vdp irq ?
    rts

gfx_init:
gfx_init_pal:
		vdp_sreg 0, v_reg16
		ldx #0
:	  	jsr gfx_write_pal
		inx
		inx
		cpx #2*16
		bne :-

gfx_init_chars:
		vdp_vram_w VRAM_PATTERN
		lda #<tiles
		ldy #>tiles
		ldx #08
		jsr vdp_memcpy

		vdp_vram_w VRAM_COLOR
		lda #<tiles_colors
		ldy #>tiles_colors
		ldx #$08
		jsr vdp_memcpy

		lda #SPRITE_OFF+$08
		sta sprite_tab_attr_end

gfx_init_sprites:
		vdp_vram_w VRAM_SPRITE_PATTERN
		lda #<sprite_patterns
		ldy #>sprite_patterns
		ldx #4
		jsr vdp_memcpy

		vdp_vram_w VRAM_SPRITE_COLOR	; load sprite color address

		lda #VDP_Color_Blinky
		jsr _fills
		lda #(VDP_Color_Blue | $20 | $40)  ; CC | IC | 2nd color
		jsr _fills

		lda #VDP_Color_Inky
		jsr _fills
		lda #(VDP_Color_Blue | $20 | $40)  ; CC | IC | 2nd color
		jsr _fills

		lda #VDP_Color_Pinky
		jsr _fills
		lda #(VDP_Color_Blue | $20 | $40)  ; CC | IC | 2nd color
		jsr _fills

		lda #VDP_Color_Clyde
		jsr _fills
		lda #(VDP_Color_Blue | $20 | $40)  ; CC | IC | 2nd color
		jsr _fills

		lda #VDP_Color_Yellow
		jsr _fills

gfx_blank_screen:
		vdp_vram_w VRAM_SCREEN
		lda #Char_Blank
		ldx #4
		jsr vdp_fill

gfx_sprites_off:
		vdp_vram_w VRAM_SPRITE_ATTR; sprites off
		ldx #1
		lda #gfx_Sprite_Off
		jmp vdp_fill

        rts

_fills:
		ldx #16	  ;16 color lines per sprite
		jmp vdp_fills

_gfx_is_multiplex:
		phx
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
@exit:plx
		rts

; X ghost y test with pacman y
_gfx_test_sp_y:	;
		lda actors+actor::sp_y,x
		ldx #ACTOR_PACMAN
		sec
		sbc actors+actor::sp_y,x
		bpl :+
		eor #$ff ; absolute |y1 - y2|
:		cmp #$10 ; 16px ?
		rts

gfx_update:
		ldy #0
		ldx #ACTOR_BLINKY
		jsr _gfx_update_sprite_tab_2x
		ldx #ACTOR_INKY
		jsr _gfx_update_sprite_tab_2x
		ldx #ACTOR_PINKY
		jsr _gfx_update_sprite_tab_2x
		ldx #ACTOR_CLYDE
		jsr _gfx_update_sprite_tab_2x
		ldx #ACTOR_PACMAN
		jsr _gfx_update_sprite_tab

		jsr _gfx_is_multiplex
		bcs @update_sprites
		ldx #7*4	;y sprite_tab offset clyde eyes
		lda game_state+GameState::frames
		and #$01
		beq :+
		ldx #5*4	;y sprite_tab offset pinky eyes
:		lda #gfx_Sprite_Off-1			; c=0 - must multiplex, sprites scanline conflict +/-16px
		sta sprite_tab_attr,x
@update_sprites:
		vdp_vram_w VRAM_SPRITE_ATTR
		lda #<sprite_tab_attr
		ldy #>sprite_tab_attr
		ldx #9*4+1
		jsr vdp_memcpys

		lda vdp_sreg_0
		rts

_gfx_update_sprite_tab_2x:
		lda #$02
		jsr :+
_gfx_update_sprite_tab:
		lda #$00
:		sta game_tmp
		lda actors+actor::sp_y,x
		sec
		sbc #gfx_Sprite_Adjust_Y
		sta sprite_tab_attr,y
		iny
		lda actors+actor::sp_x,x
		sec
		sbc #gfx_Sprite_Adjust_X
		sta sprite_tab_attr,y
		iny
		phy
		lda actors+actor::shape,x
		ora game_tmp
		tay
		lda shapes,y
		ply
		sta sprite_tab_attr,y
		iny
		lda #0
		sta sprite_tab_attr,y	; byte 4 - reserved/unused
		iny
		rts


_gfx_update_sprite_vram_2x:
		lda #$02
		jsr :+
_gfx_update_sprite_vram:
		lda #$00
:		ldy actors+actor::sp_y,x
		sty a_vram
		vdp_wait_l 4
		ldy actors+actor::sp_x,x
		sty a_vram
		ora actors+actor::shape,x
		tay
		lda shapes,y
		vdp_wait_l 10
		sta a_vram
		vdp_wait_l 2
		stz a_vram	; byte 4 - reserved/unused
		rts

gfx_display_maze:
		vdp_vram_w (VRAM_SCREEN)
		lda #<game_maze
		ldy #>game_maze
		ldx #4
		jsr vdp_memcpy
		vdp_vram_w (VRAM_SCREEN+$400-32)
		ldx #32
		lda #Char_Blank
		jmp vdp_fills

gfx_pause:
		lda game_state
		and #STATE_PAUSE
		lsr
		lsr
		ldy #v_reg8
		;vdp_sreg	; v_reg8_VR | v_reg8_BW | v_reg8_SPD, v_reg8
		rts

gfx_bordercolor=vdp_bgcolor
gfx_bgcolor=vdp_bgcolor

; set the vdp vram address
;	in:
;	  sys_crs_x - x 0..31
;	  sys_crs_y - y 0..26
gfx_vram_ay:
		sta sys_crs_x
		sty sys_crs_y
gfx_vram_xy:
		lda sys_crs_y ;.Y * 32
		asl
		asl
		asl
		asl
		asl
		ora sys_crs_x
		sta a_vreg
		lda sys_crs_y ; .Y * 32
		lsr ; div 8 -> page offset 0-2
		lsr
		lsr
		ora #(WRITE_ADDRESS + >VRAM_SCREEN)
		vdp_wait_s 5
		sta a_vreg
		rts

gfx_charout:
		pha
		jsr gfx_vram_xy
		pla
		vdp_wait_l 8
		sta a_vram
		rts

gfx_hires_on:
		vdp_sreg >(VRAM_COLOR<<2)	| $7f, v_reg3 ; need more colors for colored text
		vdp_sreg >(VRAM_PATTERN>>3) | $03, v_reg4 ; pattern table
		rts

gfx_hires_off:
		vdp_sreg >(VRAM_COLOR<<2)	| $1f, v_reg3 ;
		vdp_sreg >(VRAM_PATTERN>>3) | $00, v_reg4 ;
		rts

.data
vdp_init_bytes:	; vdp init table - MODE G3
			.byte v_reg0_m4
			.byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
			.byte >(VRAM_SCREEN>>2)		 	; name table (screen)
			.byte >(VRAM_COLOR<<2)  | $1f	; $1f - color table with $800 values, each pattern with 8 colors (per line)
			.byte >(VRAM_PATTERN>>3)		; pattern table
			.byte >(VRAM_SPRITE_ATTR<<1) | $07 ; sprite attribute table => $07 -> see V9938_MSX-Video_Technical_Data_Book_Aug85.pdf S.93
;			.byte	(ADDRESS_GFX2_SPRITE / $80)	; sprite attribute table - value * $80 --> offset in VRAM
			.byte >(VRAM_SPRITE_PATTERN>>3)
			.byte VDP_Color_Bg
			.byte v_reg8_VR ; VR - 64k VRAM TODO set per define
			.byte v_reg9_ln ; 212 lines
			.byte <.hiword(VRAM_SPRITE_COLOR<<2) ; color table high, a16-14
			.byte <.hiword(VRAM_SPRITE_ATTR<<1); sprite attribute high
			.byte 0
			.byte 0 ;R#13
vdp_init_bytes_end:

gfx_Sprite_Adjust_X=8
		.byte 8
gfx_Sprite_Adjust_Y=8
		.byte 8
gfx_Sprite_Off=SPRITE_OFF+$08 ; +8, 212 line mode

Color_Bg:			.byte VDP_Color_Bg
Color_Red:			.byte VDP_Color_Red
Color_Pink:		  	.byte VDP_Color_Pink
Color_Cyan:		  	.byte VDP_Color_Cyan
Color_Light_Blue: .byte VDP_Color_Light_Blue
Color_Orange:		.byte VDP_Color_Orange
Color_Yellow:		.byte VDP_Color_Yellow
Color_Dark_Pink:	.byte VDP_Color_Dark_Pink
Color_Dark_Cyan:	.byte VDP_Color_Dark_Cyan
Color_Blue:		  	.byte VDP_Color_Blue
Color_Gray:		  	.byte VDP_Color_Gray

pacman_colors:
  vdp_pal 0,0,0			;0
  vdp_pal $ff,0,0		 	;1 "shadow", "blinky" red
  vdp_pal $de,$97,$51	;2 "food"
  vdp_pal $ff,$b8,$ff	;3 "speedy", "pinky" pink
  vdp_pal 0,0,0			;4
  vdp_pal 0,$ff,$ff	  	;5 "bashful", "inky" cyan
  vdp_pal $47,$b8,$ff	;6 "light blue"
  vdp_pal $ff,$b8,$51	;7 "pokey", "Clyde" "orange"
  vdp_pal 0,0,0			;8
  vdp_pal $ff,$ff,0	  	;9 "yellow", "pacman"
  vdp_pal 0,0,0			;a
  vdp_pal $ff,$b8,$ae	;b dark pink "food"
  vdp_pal 0,$ff,0		 	;c green
  vdp_pal $47,$b8,$ae	;d dark cyan
  vdp_pal $21,$21,$ff	;e blue => ghosts "scared", ghost pupil
  vdp_pal $de,$de,$ff	;f gray => ghosts "scared", ghost eyes

tiles:
		.include "pacman.tiles.rot.inc"
tiles_colors:
		.include "pacman.tiles.colors.inc"
sprite_patterns:
		.include "pacman.ghosts.res"
		.include "pacman.pacman.res"

shapes:
; pacman
		.byte $10*4+4,$10*4,$18*4,$10*4 ;r  00
		.byte $12*4+4,$12*4,$18*4,$12*4 ;l  01
		.byte $14*4+4,$14*4,$18*4,$14*4 ;u  10
		.byte $16*4+4,$16*4,$18*4,$16*4 ;d  11
; ghosts
		.byte $08*4,$08*4,$00*4,$00*4+4 ;r  00
		.byte $09*4,$09*4,$02*4,$02*4+4 ;l  01
		.byte $0a*4,$0a*4,$04*4,$04*4+4 ;u  10
		.byte $0b*4,$0b*4,$06*4,$06*4+4 ;d  11


.bss
		vdp_sreg_0:		 		.res 1	; S#0 of the VDP at v-blank time
		sprite_tab_attr:		.res 9*4 ;9 sprites, 4 byte per entry +1 y of sprite 10
		sprite_tab_attr_end:
