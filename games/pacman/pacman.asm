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
      lda #<vdp_init_bytes
      ldy #>vdp_init_bytes
      ldx #(vdp_init_bytes_end-vdp_init_bytes)-1
      jsr vdp_init_reg

      vdp_sreg <.hiword(ADDRESS_GFX3_PATTERN<<2), v_reg14
      vdp_sreg <ADDRESS_GFX3_PATTERN, WRITE_ADDRESS | >ADDRESS_GFX3_PATTERN
      lda #<tiles
      ldy #>tiles
      ldx #08
      jsr vdp_memcpy
      
      vdp_sreg <.hiword(ADDRESS_GFX3_SCREEN<<2), v_reg14
      vdp_sreg <ADDRESS_GFX3_SCREEN, WRITE_ADDRESS | >ADDRESS_GFX3_SCREEN
      ldx #4
      lda #' '
      jsr vdp_fill

      vdp_sreg <.hiword(ADDRESS_GFX3_SCREEN<<2), v_reg14
      vdp_sreg <ADDRESS_GFX3_SCREEN, WRITE_ADDRESS | >ADDRESS_GFX3_SCREEN
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
      
      vdp_sreg <.hiword(ADDRESS_GFX3_COLOR<<2), v_reg14
      vdp_sreg <ADDRESS_GFX3_COLOR, WRITE_ADDRESS | >ADDRESS_GFX3_COLOR
      ldx #$18
      lda #Gray<<4
      jsr vdp_fill
      
      vdp_sreg <.hiword(ADDRESS_GFX6_SCREEN<<2), v_reg14
      vdp_sreg <ADDRESS_GFX6_SCREEN, WRITE_ADDRESS | >ADDRESS_GFX6_SCREEN
      ldx #0
      ldy #212
      lda #Gray<<4|Transparent
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
; sprite_pattern=ADDRESS_GFX6_SPRITE_PATTERN
; sprite_color  =ADDRESS_GFX6_SPRITE_COLOR
; sprite_attr   =ADDRESS_GFX6_SPRITE

      vdp_sreg <.hiword(sprite_pattern<<2), v_reg14
      vdp_sreg <sprite_pattern, WRITE_ADDRESS | (>sprite_pattern & $3f) ; !!! bit 7 MUST BE 0
      lda #$b7
      ldx #32
      jsr vdp_fills

      vdp_sreg <.hiword(sprite_color<<2), v_reg14
      vdp_sreg <sprite_color, WRITE_ADDRESS | (>sprite_color & $3f)
      ldx #1
      lda #0
      jsr vdp_fill

      vdp_sreg <.hiword(sprite_attr<<2), v_reg14
      vdp_sreg <sprite_attr, WRITE_ADDRESS | (>sprite_attr & $3f)
      ldx #1
      lda #$d6
      jsr vdp_fill

      vdp_sreg <.hiword(sprite_color<<2), v_reg14
      vdp_sreg <sprite_color, WRITE_ADDRESS | (>sprite_color & $3f)
      ldx #$0f     ;16 colors per line
:     vdp_wait_l
      lda #White
      sta a_vram
      dex
      bpl :-
      
      vdp_sreg <.hiword(sprite_attr<<2), v_reg14
      vdp_sreg <sprite_attr, WRITE_ADDRESS | (>sprite_attr & $3f)
      ldx #0
:     vdp_wait_l
      lda sprite0,x
      sta a_vram
      inx
      cpx #4
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

      nop
      nop
      nop
;vdp_init_bytes:;mode 6
			.byte v_reg0_m5|v_reg0_m3												; reg0 mode bits
			.byte v_reg1_display_on|v_reg1_spr_size |v_reg1_int 			; TODO FIXME verify v_reg1_16k t9929 specific, therefore 0
			.byte >(ADDRESS_GFX6_SCREEN>>2) | $3f	; => 00<A16>1 1111 - entw. bank 0 oder 1 (64k)
			.byte	$0
			.byte $0
      .byte	>(ADDRESS_GFX6_SPRITE<<1) | $04
			.byte	>(ADDRESS_GFX6_SPRITE_PATTERN>>3);  
			.byte	Black
			.byte v_reg8_VR	; VR - 64k VRAM TODO set per define
			.byte v_reg9_nt | v_reg9_ln
      .byte 0
      .byte <.hiword(ADDRESS_GFX6_SPRITE<<1)
;vdp_init_bytes_end:

.data
tiles:
      .include "pacman.tiles.inc"