      .setcpu "65c02"
      .include "zeropage.inc"
      .include "common.inc"
      .include "kernel_jumptable.inc"
      .include "vdp.inc"
      .include "appstart.inc"

      .import vdp_init_reg
      .import vdp_memcpy, vdp_memcpys
      .import vdp_fill, vdp_fills
      .import vdp_bgcolor

appstart

main:
      jsr krn_textui_disable

      jsr intro

      jsr game
      
      keyin

      sei
      copypointer save_isr, $fffe
      cli

      jmp (retvec)

intro:
      rts

game:
      sei
      copypointer $fffe, save_isr
      SetVector	game_isr, $fffe
      jsr init_video
      cli
      rts

game_isr:
      save
      bit	a_vreg
      bpl	game_isr_exit
      lda #$0f
      jsr vdp_bgcolor
      
      vdp_vram_w sprite_attr
      lda #<sprite_tab_attr
      ldy #>sprite_tab_attr
      ldx #4*2*4
      jsr vdp_memcpys
      
      inc sprite_tab_attr+SPRITE_X+0*4
      inc sprite_tab_attr+SPRITE_X+1*4
      
      inc sprite_tab_attr+SPRITE_X+2*4
      inc sprite_tab_attr+SPRITE_X+3*4
      inc sprite_tab_attr+SPRITE_X+2*4
      inc sprite_tab_attr+SPRITE_X+3*4

      dec sprite_tab_attr+SPRITE_X+4*4
      dec sprite_tab_attr+SPRITE_X+5*4

      dec sprite_tab_attr+SPRITE_X+6*4
      dec sprite_tab_attr+SPRITE_X+7*4
      dec sprite_tab_attr+SPRITE_X+6*4
      dec sprite_tab_attr+SPRITE_X+7*4

      dec frame_counter
      
      lda frame_counter
      and #07
      bne :+
      jsr animate_ghosts
:     
game_isr_exit:
      lda	#0
      jsr	vdp_bgcolor

      restore
      rti
      

animate_ghosts:
      lda sprite_tab_attr+SPRITE_N+0*4
      eor #04
      sta sprite_tab_attr+SPRITE_N+0*4
      lda sprite_tab_attr+SPRITE_N+2*4
      eor #04
      sta sprite_tab_attr+SPRITE_N+2*4
      lda sprite_tab_attr+SPRITE_N+4*4
      eor #04
      sta sprite_tab_attr+SPRITE_N+4*4
      lda sprite_tab_attr+SPRITE_N+6*4
      eor #04
      sta sprite_tab_attr+SPRITE_N+6*4
      rts
      
      
.macro ghost _nr, _x, _y, _color
      .local _nr,_x,_y,_color
      vdp_wait_l
      vdp_vram_w (sprite_attr+(_nr*8))
      ldx #_x
      ldy #_y
      jsr sprite_tab_attrs
      ;color tab
      vdp_wait_l
      vdp_vram_w (sprite_color+(_nr*32))
      lda #_color
      jsr sprite_tab_color
      vdp_wait_l
      lda #$4e  ; CC | 2nd color
      jsr sprite_tab_color
.endmacro
      
init_video:
      vdp_sreg 0, v_reg16
      ldx #0
:     vdp_wait_s
      lda pacman_colors, x
      sta a_vregpal
      inx
      cpx #2*16
      bne :-
      
      lda #<vdp_init_bytes
      ldy #>vdp_init_bytes
      ldx #(vdp_init_bytes_end-vdp_init_bytes)-1
      jsr vdp_init_reg

      vdp_vram_w ADDRESS_GFX3_PATTERN
      lda #<tiles
      ldy #>tiles
      ldx #08
      jsr vdp_memcpy

      vdp_vram_w ADDRESS_GFX3_COLOR
      ldx #$18
      lda #$e0
      jsr vdp_fill      
      
      vdp_vram_w ADDRESS_GFX3_SCREEN
      ldx #4
      lda #' '
      jsr vdp_fill
      
      vdp_vram_w ADDRESS_GFX3_SCREEN
      ldy #1
:     
      ldx #32
      lda #'0'
      jsr vdp_fills
      dey
      bne :-
      
      vdp_wait_l
      vdp_sreg $0, v_reg18
@ex:

sprite_pattern=ADDRESS_GFX3_SPRITE_PATTERN
sprite_color  =ADDRESS_GFX3_SPRITE_COLOR
sprite_attr   =ADDRESS_GFX3_SPRITE

      vdp_vram_w sprite_pattern
      lda #<sprite_patterns
      ldy #>sprite_patterns
      ldx #2
      jsr vdp_memcpy

      vdp_vram_w sprite_attr
      ldx #1
      lda #$d6
      jsr vdp_fill
      
      vdp_wait_l
      ghost 1, 130, 80, 3  ;pinky
      vdp_wait_l
      ghost 2, 150, 110, 5  ;inky
      vdp_wait_l
      ghost 3, 170, 140, 7  ;clyde
      vdp_wait_l
      ghost 0, 100, 50, 1  ;blinky
      
      
      rts

sprite_tab_attr:
      .byte 100, 100, 2*4, 0
      .byte 100, 100, 9*4, 0
      .byte 100, 100, 0*4, 0
      .byte 100, 100, 8*4, 0
      .byte 100, 100, 4*4, 0
      .byte 100, 100, $a*4, 0
      .byte 100, 100, 6*4, 0
      .byte 100, 100, $b*4, 0
      

_sprite_tab_attr:
      vdp_wait_l
      sty a_vram
      vdp_wait_l
      stx a_vram
      vdp_wait_l
      sta a_vram
      vdp_wait_l
      stz a_vram
      vdp_wait_l
      rts
      
sprite_tab_attrs:
      lda #0
      jsr _sprite_tab_attr
      lda #8*4
      jmp _sprite_tab_attr
      
sprite_tab_color:
      ldx #$0f     ;16 colors per line
@l1:  vdp_wait_l
      sta a_vram
      dex
      bpl @l1
      vdp_wait_l
      rts

vdp_init_bytes:
			.byte v_reg0_m4
			.byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
			.byte >(ADDRESS_GFX3_SCREEN>>2)       ; name table (screen)
			.byte >(ADDRESS_GFX3_COLOR<<2)  | $01 ; color table
			.byte	>(ADDRESS_GFX3_PATTERN>>3)      ; pattern table
			.byte	>(ADDRESS_GFX3_SPRITE<<1) | $04 ; sprite attribute table - value * $80 --> offset in VRAM
			.byte	>(ADDRESS_GFX3_SPRITE_PATTERN>>3)
			.byte	0
			.byte v_reg8_VR	; VR - 64k VRAM TODO set per define
			.byte v_reg9_nt | v_reg9_ln
			.byte <.hiword(ADDRESS_GFX3_COLOR<<2) ; color table high, a16-14
      .byte <.hiword(ADDRESS_GFX3_SPRITE<<1); sprite attribute high
vdp_init_bytes_end:

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
  vdp_pal $ff,$ff,0     ;9 "yellow"
  vdp_pal 0,0,0         ;a
  vdp_pal $ff,$b8,$ae   ;b light orange "food"
  vdp_pal 0,$ff,0       ;c green
  vdp_pal $47,$b8,$ae   ;d dark cyan
  vdp_pal $21,$21,$ff   ;e blue => ghosts "scared", ghost pupil
  vdp_pal $de,$de,$ff   ;f gray => ghosts "scared", ghost eyes
  
save_isr:       .res 2
frame_counter:  .res 0
  
.data
tiles:
      .include "pacman.tiles.inc"
sprite_patterns:
      .include "pacman.ghosts.inc"

;         0001 
;         0011
;         0101
;         0111
;         
;     00001110 $0e
;     00001111 $0f
         

