      .include "pacman.sts.inc"
      
      .export gfx_init
      .export gfx_mode_on
      .export gfx_mode_off
      .export gfx_vram_xy
      .export gfx_vram_ay
      .export gfx_blank_screen
      .export gfx_bgcolor
      .export gfx_sprites_off
      .export gfx_vblank

      .export gfx_digits,gfx_digit
      .export gfx_hex_digits
      
      .export gfx_text
      .export gfx_charout
      .export gfx_hires_on
      .export gfx_hires_off
      .export gfx_update
      .export gfx_display_maze
      .export gfx_pause
      .export gfx_Sprite_Adjust_X,gfx_Sprite_Adjust_Y
      .export gfx_Sprite_Off

      ;vdp
      .import vdp_bgcolor
      .import vdp_fill,vdp_fills
      .import vdp_memcpy,vdp_memcpys
      .import vdp_init_reg
      
      .import game_state
      .import game_maze
      .import sprite_tab_attr

sprite_pattern=ADDRESS_GFX3_SPRITE_PATTERN
sprite_color  =ADDRESS_GFX3_SPRITE_COLOR

VRAM_SPRITE_PATTERN =ADDRESS_GFX3_SPRITE_PATTERN
VRAM_SPRITE_COLOR   =ADDRESS_GFX3_SPRITE_COLOR
VRAM_SPRITE_ATTR    =ADDRESS_GFX3_SPRITE

.code
gfx_vblank:
      bit	a_vreg
      rts

gfx_mode_off:
      vdp_sreg 0, v_reg9   ;
      vdp_sreg 0, v_reg23  ;
      rts
      
gfx_mode_on:
      lda #<vdp_init_bytes
      ldy #>vdp_init_bytes
      ldx #(vdp_init_bytes_end-vdp_init_bytes)-1
      jsr vdp_init_reg
      
      vdp_sreg $0, v_reg18  ;x/y screen adjust
      vdp_sreg <-2, v_reg23  ;y offset
      
      rts

.export gfx_rotate_pal
gfx_pacman_colors_offset:
.byte Color_Blue<<1, Color_Light_Blue<<1, Color_Gray<<1, Color_Light_Blue<<1
gfx_rotate_pal:
      vdp_sreg Color_Blue, v_reg16 ; rotate blue 
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
:     jsr gfx_write_pal
      inx
      inx
      cpx #2*16
      bne :-

gfx_init_chars:
      vdp_vram_w ADDRESS_GFX3_PATTERN
      lda #<tiles
      ldy #>tiles
      ldx #08
      jsr vdp_memcpy

      vdp_vram_w ADDRESS_GFX3_COLOR
      lda #<tiles_colors
      ldy #>tiles_colors
      ldx #$08
      jsr vdp_memcpy

gfx_init_sprites:
      vdp_vram_w sprite_pattern
      lda #<sprite_patterns
      ldy #>sprite_patterns
      ldx #4
      jsr vdp_memcpy
      
      vdp_vram_w (sprite_color+0*16)
      lda #Color_Yellow
      jsr _fills
      lda #Color_Bg
      jsr _fills
      
      lda #Color_Blinky
      jsr _fills
      lda #(Color_Blue | $20 | $40)  ; CC | IC | 2nd color
      jsr _fills
      
      lda #Color_Inky
      jsr _fills
      lda #(Color_Blue | $20 | $40)  ; CC | IC | 2nd color
      jsr _fills

      lda #Color_Pinky
      jsr _fills
      lda #(Color_Blue | $20 | $40)  ; CC | IC | 2nd color
      jsr _fills

      lda #Color_Clyde
      jsr _fills
      lda #(Color_Blue | $20 | $40)  ; CC | IC | 2nd color
      jsr _fills
      
      lda gfx_Sprite_Off
      sta sprite_tab_attr+SPRITE_Y

gfx_blank_screen:
      vdp_vram_w ADDRESS_GFX3_SCREEN
      lda #0
      ldx #4
      jsr vdp_fill

gfx_sprites_off:
      vdp_vram_w VRAM_SPRITE_ATTR; sprites off
      ldx #1
      lda gfx_Sprite_Off
      jmp vdp_fill

_fills:
      ldx #16     ;16 colors per line
      jmp vdp_fills

gfx_update:
      vdp_vram_w VRAM_SPRITE_ATTR
      lda #<sprite_tab_attr
      ldy #>sprite_tab_attr
      ldx #5*2*4
      jmp vdp_memcpys

gfx_display_maze:
      vdp_vram_w (ADDRESS_GFX3_SCREEN)
      lda #<game_maze
      ldy #>game_maze
      ldx #4
      jmp vdp_memcpy
      
gfx_pause:
      lsr
      lsr
      lsr
      ora #v_reg8_VR
      ldy #v_reg8
      vdp_sreg
      rts
      

gfx_bgcolor=vdp_bgcolor
      
; set the vdp vram address
;   in:
;     crs_x - x 0..31
;     crs_y - y 0..26
gfx_vram_ay:
      sta crs_x
      sty crs_y
gfx_vram_xy:
      lda crs_y ;.Y * 32
      asl
      asl
      asl
      asl
      asl
      ora crs_x
      sta a_vreg
      lda crs_y ; .Y * 32
      lsr ; div 8 -> page offset 0-2
      lsr
      lsr
      ora #(WRITE_ADDRESS + >ADDRESS_GFX3_SCREEN)
      vdp_wait_s 5
      sta a_vreg
      rts

gfx_hex_digits:
      pha
      phx

      tax
      lsr
      lsr
      lsr
      lsr
      jsr hexdigit
      txa
      jsr hexdigit
      plx
      pla
      rts
hexdigit:
      and #$0f      ;mask lsb for hex print
      ora #'0'			;add "0"
      cmp #'9'+1		;is it a decimal digit?
      bcc @out
      adc #6			  ;add offset for letter a-f
@out: vdp_wait_l 16
      sta a_vram
      rts
      
gfx_digits:
      pha
      lsr
      lsr
      lsr
      lsr
      jsr gfx_digit
      pla
gfx_digit:
      pha
      jsr gfx_vram_xy
      pla
      and #$0f
      ora #'0'
      vdp_wait_l 12
      sta a_vram
      dec crs_y
      rts

gfx_charout:
      pha
      jsr gfx_vram_xy
      pla
      vdp_wait_l 8
      sta a_vram
      rts
      
gfx_text:
      ldy #0
      lda (p_video),y
      sta crs_x
      iny
      lda (p_video),y
      sta crs_y
      iny
@l1:
      jsr gfx_vram_xy
      vdp_wait_l (6+6+2)
      lda (p_video),y
      beq @rts
      cmp #WAIT
      beq @wait
      cmp #WAIT2
      bne @out
      jsr wait
@wait:
      jsr wait
      
      bra @next
@out:      
      sta a_vram
      dec crs_y
@next:
      iny
      bne @l1
@rts:
      rts

wait:
      lda game_state+GameState::frames
      and #FRAMES_DELAY
      bne wait
      inc game_state+GameState::frames
      rts
      
gfx_hires_on:
      
      vdp_sreg >(ADDRESS_GFX3_COLOR<<2)   | $7f, v_reg3 ; need more colors for colored text
      vdp_sreg >(ADDRESS_GFX3_PATTERN>>3) | $03, v_reg4 ; pattern table
      rts
      
gfx_hires_off:
      vdp_sreg >(ADDRESS_GFX3_COLOR<<2)   | $1f, v_reg3 ; 
      vdp_sreg >(ADDRESS_GFX3_PATTERN>>3) | $00, v_reg4 ; 
      rts
      
.data
vdp_init_bytes:
			.byte v_reg0_m4
			.byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
			.byte >(ADDRESS_GFX3_SCREEN>>2)       ; name table (screen)
			.byte >(ADDRESS_GFX3_COLOR<<2)  | $1f;| $1f - color table with $800 values, each pattern with 8 colors (per line)
			.byte	>(ADDRESS_GFX3_PATTERN>>3)      ; pattern table
			.byte	>(ADDRESS_GFX3_SPRITE<<1) | $07 ; sprite attribute table => $07 -> see V9938_MSX-Video_Technical_Data_Book_Aug85.pdf S.93
			.byte	>(ADDRESS_GFX3_SPRITE_PATTERN>>3)
			.byte	0
			.byte v_reg8_VR	; VR - 64k VRAM TODO set per define
			.byte v_reg9_ln ; 212 lines
			.byte <.hiword(ADDRESS_GFX3_COLOR<<2) ; color table high, a16-14
      .byte <.hiword(ADDRESS_GFX3_SPRITE<<1); sprite attribute high
      .byte	0
			.byte	0 ;#R13
vdp_init_bytes_end:

.data
gfx_Sprite_Adjust_X:
gfx_Sprite_Adjust_Y:
      .byte 8
gfx_Sprite_Off:
      .byte SPRITE_OFF+$08 ; +8, 212 line mode
      
pacman_colors:
  vdp_pal 0,0,0         ;0
  vdp_pal $ff,0,0       ;1 "shadow", "blinky" red
  vdp_pal $de,$97,$51   ;2 "food"
  vdp_pal $ff,$b8,$ff   ;3 "speedy", "pinky" pink
  vdp_pal 0,0,0         ;4
  vdp_pal 0,$ff,$ff     ;5 "bashful", "inky" cyan     
  vdp_pal $47,$b8,$ff   ;6 "light blue"
  vdp_pal $ff,$b8,$51   ;7 "pokey", "Clyde" "orange"
  vdp_pal 0,0,0         ;8
  vdp_pal $ff,$ff,0     ;9 "yellow", "pacman"
  vdp_pal 0,0,0         ;a
  vdp_pal $ff,$b8,$ae   ;b light orange "food"
  vdp_pal 0,$ff,0       ;c green
  vdp_pal $47,$b8,$ae   ;d dark cyan
  vdp_pal $21,$21,$ff   ;e blue => ghosts "scared", ghost pupil
  vdp_pal $de,$de,$ff   ;f gray => ghosts "scared", ghost eyes

tiles:
      .include "pacman.tiles.rot.inc"
tiles_colors:
      .include "pacman.tiles.colors.inc"
      
sprite_patterns:
      .include "pacman.ghosts.res"
      .include "pacman.pacman.res"
