		.include "pacman.sts.inc"

		.export gfx_init
		.export gfx_mode_on
		.export gfx_mode_off
		.export gfx_blank_screen
		.export gfx_bgcolor
		.export gfx_bordercolor
		.export gfx_sprites_off
		.export gfx_vblank

		.export gfx_charout
		.export gfx_hires_on
		.export gfx_hires_off
		.export gfx_update
		.export gfx_display_maze
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

		;vdp
		.import vdp_bgcolor
		.import vdp_fill,vdp_fills
		.import vdp_memcpy,vdp_memcpys
		.import vdp_init_reg

		.import game_state
		.import game_maze
		.import sprite_tab_attr

.code
gfx_vblank:
		bit	a_vreg
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

.export gfx_rotate_pal
gfx_pacman_colors_offset:
.byte VDP_Color_Blue<<1, VDP_Color_Light_Blue<<1, VDP_Color_Gray<<1, VDP_Color_Light_Blue<<1
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

gfx_init_sprites:
		vdp_vram_w VRAM_SPRITE_PATTERN
		lda #<sprite_patterns
		ldy #>sprite_patterns
		ldx #4
		jsr vdp_memcpy

		vdp_vram_w (VRAM_SPRITE_COLOR+0*16)
		lda #VDP_Color_Yellow
		jsr _fills
		lda #VDP_Color_Bg
		jsr _fills

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

		lda gfx_Sprite_Off
		sta sprite_tab_attr+SPRITE_Y

gfx_blank_screen:
		vdp_vram_w VRAM_SCREEN
		lda #Char_Blank
		ldx #4
		jsr vdp_fill

gfx_sprites_off:
		vdp_vram_w VRAM_SPRITE_ATTR; sprites off
		ldx #1
		lda gfx_Sprite_Off
		jmp vdp_fill

_fills:
		ldx #16	  ;16 colors per line
		jmp vdp_fills

gfx_update:
		vdp_vram_w VRAM_SPRITE_ATTR
		lda #<sprite_tab_attr
		ldy #>sprite_tab_attr
		ldx #5*2*4
		jmp vdp_memcpys

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
vdp_init_bytes:
			.byte v_reg0_m4
			.byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
			.byte >(VRAM_SCREEN>>2)		 ; name table (screen)
			.byte >(VRAM_COLOR<<2)  | $1f;| $1f - color table with $800 values, each pattern with 8 colors (per line)
			.byte	>(VRAM_PATTERN>>3)		; pattern table
			.byte	>(VRAM_SPRITE_ATTR<<1) | $07 ; sprite attribute table => $07 -> see V9938_MSX-Video_Technical_Data_Book_Aug85.pdf S.93
			.byte	>(VRAM_SPRITE_PATTERN>>3)
			.byte	0
			.byte v_reg8_VR ; VR - 64k VRAM TODO set per define
			.byte v_reg9_ln ; 212 lines
			.byte <.hiword(VRAM_SPRITE_COLOR<<2) ; color table high, a16-14
			.byte <.hiword(VRAM_SPRITE_ATTR<<1); sprite attribute high
			.byte	0
			.byte	0 ;#R13
vdp_init_bytes_end:

gfx_Sprite_Adjust_X:
		.byte 8
gfx_Sprite_Adjust_Y:
		.byte 8
gfx_Sprite_Off:
		.byte SPRITE_OFF+$08 ; +8, 212 line mode

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
  vdp_pal $ff,0,0		 ;1 "shadow", "blinky" red
  vdp_pal $de,$97,$51	;2 "food"
  vdp_pal $ff,$b8,$ff	;3 "speedy", "pinky" pink
  vdp_pal 0,0,0			;4
  vdp_pal 0,$ff,$ff	  ;5 "bashful", "inky" cyan
  vdp_pal $47,$b8,$ff	;6 "light blue"
  vdp_pal $ff,$b8,$51	;7 "pokey", "Clyde" "orange"
  vdp_pal 0,0,0			;8
  vdp_pal $ff,$ff,0	  ;9 "yellow", "pacman"
  vdp_pal 0,0,0			;a
  vdp_pal $ff,$b8,$ae	;b dark pink "food"
  vdp_pal 0,$ff,0		 ;c green
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
