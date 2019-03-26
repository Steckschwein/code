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
      sei
      jsr init_video
      cli
      rts

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
      
      vdp_vram_w ADDRESS_GFX3_SCREEN
      ldy #27
:     
      phy
      tya
      and #$07
      clc
      adc #'0'
      ldx #32
      jsr vdp_fills
      ply
      dey
      bne :-
      
      vdp_vram_w ADDRESS_GFX6_SCREEN
      ldx #0
      ldy #212
      lda #Light_Blue<<4|Transparent
:     vdp_wait_l
      sta a_vram
      inx 
      bne :-
      dey
      bne :-
;      jsr krn_getkey
 ;     cmp #ESC
  ;    beq @ex
      vdp_wait_l
      vdp_sreg $0, v_reg18
@ex:

sprite_pattern=ADDRESS_GFX3_SPRITE_PATTERN
sprite_color  =ADDRESS_GFX3_SPRITE_COLOR
sprite_attr   =ADDRESS_GFX3_SPRITE

      vdp_vram_w sprite_pattern
      lda #$b7
      ldx #32
      jsr vdp_fills

      vdp_vram_w sprite_color
      ldx #1
      lda #0
      jsr vdp_fill

      vdp_vram_w sprite_attr
      ldx #1
      lda #$d6
      jsr vdp_fill

      vdp_vram_w sprite_color
      ldx #$0f     ;16 colors per line
:     vdp_wait_l
      lda #White
      sta a_vram
      dex
      bpl :-

      vdp_vram_w sprite_attr
      ldx #0
:     vdp_wait_l
      lda sprite0,x
      sta a_vram
      inx
      cpx #4
      bne :-
      
      vdp_vram_w ADDRESS_GFX3_COLOR
      ldx #$18
      lda #0
      jsr vdp_fill
      
      vdp_vram_w ADDRESS_GFX3_COLOR
      ldy #$f0
      lda #3
:     vdp_wait_l
      sta a_vram
      iny
      bne :-
      
      rts
    
sprite0:
      .byte 50,100,0,0
      
vdp_init_bytes:
			.byte v_reg0_m4
			.byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
			.byte >(ADDRESS_GFX3_SCREEN>>2)       ; name table (screen)
			.byte >(ADDRESS_GFX3_COLOR<<2)        ; color table
			.byte	>(ADDRESS_GFX3_PATTERN>>3)      ; pattern table
			.byte	>(ADDRESS_GFX3_SPRITE<<1) | $04 ; sprite attribute table - value * $80 --> offset in VRAM
			.byte	>(ADDRESS_GFX3_SPRITE_PATTERN>>3)
			.byte	Black
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
  vdp_pal 0,0,0          ;a
  vdp_pal $21,$21,$ff   ;b blue => ghosts "scared", ghost pupil
  vdp_pal 0,$ff,0       ;c green
  vdp_pal $47,$b8,$ae   ;d dark cyan
  vdp_pal $ff,$b8,$ae   ;e light orange "food"
  vdp_pal $de,$de,$ff   ;f gray => ghosts "scared", ghost eyes
  
.data
tiles:
      .include "pacman.tiles.inc"

;         0001 
;         0011
;         0101
;         0111
;         
;     00001110
;     00001000
         
