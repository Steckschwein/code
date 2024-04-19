.include "pacman.sts.inc"

.export gfx_init
.export gfx_mode_on
.export gfx_mode_off
.export gfx_blank_screen
.export gfx_bgcolor
.export gfx_bordercolor
.export gfx_sprites_on
.export gfx_sprites_off
.export gfx_isr
.export gfx_charout
.export gfx_update
.export gfx_display_maze
.export gfx_pause

.autoimport

.importzp sys_crs_x, sys_crs_y

.struct SpriteTab
  ypos    .byte
  xpos    .byte
  shape   .byte
  color   .byte
.endstruct

.zeropage
  p_vram:   .res 3  ; 24Bit
  p_gfx:    .res 2
  p_tiles:  .res 2
  r1: .res 1
  r2: .res 1
  r3: .res 1
  r4: .res 1

.code

gfx_mode_off:
    sei
    vdp_sreg 0, v_reg15
    cli
    vdp_wait_s
    lda a_vreg
    rts

gfx_mode_on:
    sei
    lda #<vdp_init_bytes
    ldy #>vdp_init_bytes
    ldx #(vdp_init_bytes_end-vdp_init_bytes-1)
    jsr vdp_init_reg
    ;vdp_sreg $0, v_reg18  ;x/y screen adjust
    vdp_sreg 253, v_reg23  ;y offset

    vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical (flicker), so we setup status S#1 beforehand
line=192
    lda #line
    sta scanline
    ldy #v_reg19
    jsr vdp_set_reg
    cli
    rts

gfx_pacman_colors_offset:
.byte VDP_Color_Blue<<1, VDP_Color_Light_Blue<<1, VDP_Color_Gray<<1, VDP_Color_Light_Blue<<1

.export gfx_rotate_pal
gfx_rotate_pal:
              sei
              vdp_sreg VDP_Color_Blue, v_reg16 ; rotate blue
              ldx gfx_pacman_colors_offset,y
gfx_write_pal:
              vdp_wait_s
              lda pacman_palette+0, x
              sta a_vregpal
              vdp_wait_s
              lda pacman_palette+1, x
              sta a_vregpal
              cli
              rts

gfx_isr:
              lda a_vreg ; vdp h blank irq ?
              ror
              bcc @is_vblank

              lda scanline
              and #(212-line)
              beq :+
              lda #v_reg9_ln
:             ora vdp_reg9_init
              sta a_vreg
              lda scanline
              eor #(212-line)  ; 212/192
              sta scanline
              lda #v_reg9
              sta a_vreg

              ldy #v_reg19
              lda scanline
              jsr vdp_set_reg
.ifdef __DEBUG
              lda #Color_Orange
              jsr vdp_bgcolor
              lda #Color_Bg
              jsr vdp_bgcolor
.endif
              ldx #$40
              lda scanline
              and #(212-line)
              bne :+
              ldx #$80
:
              txa
              rts

@is_vblank:
              ldx #0
              vdp_sreg 0, v_reg15			; 0 - set status register selection to S#0
              vdp_wait_s
              bit a_vreg ; Check VDP interrupt. IRQ is acknowledged by reading.
             	bpl @is_vblank_end  ; VDP IRQ flag set?
              lda #Color_Bg
              jsr vdp_bgcolor
              ldx #$80
@is_vblank_end:
            	vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical (flicker), so we setup status S#1 beforehand
              txa
              rts

gfx_init:
              sei
              vdp_sreg 0, v_reg16
              ldx #0
:             jsr gfx_write_pal
              inx
              inx
              cpx #2*16
              bne :-

@gfx_init_chars:
          ;    vdp_vram_w VRAM_PATTERN
              lda #<tiles
              ldy #>tiles
              ldx #08
          ;    jsr vdp_memcpy

          ;    vdp_vram_w VRAM_COLOR
;              lda #<tiles_colors
 ;             ldy #>tiles_colors
  ;            ldx #$08
          ;    jsr vdp_memcpy

              lda #SPRITE_OFF+$08
              sta sprite_tab_attr_end

@gfx_init_sprites:
              vdp_vram_w VRAM_SPRITE_PATTERN
              lda #<sprite_patterns
              ldy #>sprite_patterns
              ldx #4
              jsr vdp_memcpy

              vdp_vram_w VRAM_SPRITE_COLOR  ; load sprite color address

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
              php
              sei
              ldy #Color_Bg
              jsr vdp_mode4_blank
              vdp_wait_l
              plp
              bra gfx_sprites_off
gfx_sprites_on:
              lda #0
gfx_pause:
              beq :+
gfx_sprites_off:
              lda #v_reg8_SPD
:             ora #v_reg8_VR
              php
              sei
              ldy #v_reg8
              jsr vdp_set_reg
              plp
              rts

_fills:
              ldx #16    ;16 color lines per sprite
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
_gfx_test_sp_y:  ;
    lda actors+actor::sp_y,x
    ldx #ACTOR_PACMAN
    sec
    sbc actors+actor::sp_y,x
    bpl :+
    eor #$ff ; absolute |y1 - y2|
:    cmp #$10 ; 16px ?
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
              ldx #7*4  ;y sprite_tab offset clyde eyes
              lda game_state+GameState::frames
              and #$01
              beq :+
              ldx #5*4  ;y sprite_tab offset pinky eyes
:             lda #gfx_Sprite_Off-1      ; c=0 - must multiplex, sprites scanline conflict +/-16px
              sta sprite_tab_attr,x
@update_sprites:
              vdp_vram_w VRAM_SPRITE_ATTR
              lda #<sprite_tab_attr
              ldy #>sprite_tab_attr
              ldx #9*4+1
              jmp vdp_memcpys

_gfx_update_sprite_tab_2x:
    lda #$02
    jsr :+
_gfx_update_sprite_tab:
    lda #$00
:   sta game_tmp
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
    sta sprite_tab_attr,y  ; byte 4 - reserved/unused
    iny
    rts


_gfx_update_sprite_vram_2x:
    lda #$02
    jsr :+
_gfx_update_sprite_vram:
    lda #$00
:    ldy actors+actor::sp_y,x
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
    stz a_vram  ; byte 4 - reserved/unused
    rts

gfx_display_maze:
        ldx #3
        ldy #0
        sty sys_crs_x
        sty sys_crs_y
        setPtr game_maze, p_gfx
@loop:  jsr @put_char
@next:  iny
        bne @loop
        inc p_gfx+1
        dex
        bne @loop
:       jsr @put_char
        iny
;        cpy #$c0
        bne :-
        rts

@put_char:
        lda (p_gfx),y
        pha
        cmp #Char_Food
        beq @food
        cmp #Char_Superfood
        bne @text
@food:  lda #Color_Food
        bne @color
@text:  cmp #Char_Bg
        bne @color_border
        lda #Color_Pink
        bne @color
@color_border:
        bcs @color_bg
        lda #Color_Text
        bne @color
@color_bg:
        lda #Color_Border
@color:
        sta text_color
        pla
        jsr gfx_charout
        inc sys_crs_x
        lda sys_crs_x
        and #$1f
        bne @exit
        sta sys_crs_x
        inc sys_crs_y
@exit:  rts

gfx_bordercolor=vdp_bgcolor
gfx_bgcolor=vdp_bgcolor

; set the vdp vram address
;  in:
;    sys_crs_x - x 0..31
;    sys_crs_y - y 0..26
gfx_vram_xy:
              lda #<.HIWORD(VRAM_SCREEN<<2)
              sta p_vram+2      ; A16-A14 bank select via reg#14
              lda sys_crs_x
              assertA_le 31
              asl               ; X*4
              asl
              sta p_vram        ; A7-A0 vram address low byte

              lda sys_crs_y     ; Y*8*128 => $0000, $0400, $0800
              assertA_le 31     ; effectively high byte Y*4
              asl
              asl
              sta p_vram+1

              asl
              rol               ; Bit 15 - rol over carry
              rol               ; Bit 14
              and #$03
              ora p_vram+2
              sta a_vreg
              sta p_vram+2
              lda #v_reg14
              vdp_wait_s 6
              sta a_vreg
              vdp_wait_s 4
gfx_vram_addr:
              lda p_vram
              sta a_vreg
              lda p_vram+1
              and #$3f
              sta p_vram+1      ; A13-A8 vram address highbyte
              ora #(WRITE_ADDRESS | (>.LOWORD(VRAM_SCREEN) & $3f))
              vdp_wait_s 10
              sta a_vreg
              rts

.export gfx_ghost_icon
gfx_ghost_icon:
              php
              sei

              lda text_color
              sta @palette_r+1
              asl
              asl
              asl
              asl
              sta @palette_l+1

              jsr gfx_vram_xy

              setPtr ghost_2bpp, p_gfx
              ldy #0
              lda (p_gfx),y
              iny
              asl
              sta r1
              lda (p_gfx),y
              asl
              asl
              asl
              sta r2
              setPtr (ghost_2bpp+2), p_gfx

@rows:        lda r1
              sta r4

@cols:        lda (p_gfx)

              ldy #2      ; 2bpp - 4px per byte
@nybble:      asl
              rol
              pha
              rol
              and #$03
              tax
              lda @palette_l,x
              sta r3

              pla
              asl
              rol
              pha
              rol
              and #$03
              tax
              lda @palette_r,x
              ora r3

              sta a_vram
              pla
              dey
              bne @nybble

              inc p_gfx
              bne :+
              inc p_gfx+1
:             dec r4
              bne @cols

              dec r2
              beq @exit

              lda p_vram ; vram addr Y +1 scanline
              eor #$80
              sta p_vram
              bmi :+
              inc p_vram+1
:             jsr gfx_vram_addr
              bra @rows

@exit:        plp
              rts

@palette_l: ; 4 color palette
  .byte 0,0,$f0,$e0
@palette_r:
  .byte 0,0,$0f,$0e


gfx_charout:
              php
              sei
              phx
              phy
              pha

              bgcolor Color_Gray

              jsr gfx_vram_xy

              pla               ; pointer to charset
              stz p_tiles+1
              asl ; char * 8
              rol p_tiles+1
              asl
              rol p_tiles+1
              asl
              rol p_tiles+1
              clc
              adc #<tiles
              sta p_tiles
              lda #>tiles
              adc p_tiles+1
              sta p_tiles+1

              lda text_color
              asl
              asl
              asl
              asl
              ora text_color
              sta r1            ; prepare "pen"

              lda #8
              sta r2
@rows:        lda (p_tiles)
              ldy #3
@cols:        vdp_wait_l 20
              asl
              rol
              pha
              rol
              and #$03
              tax
              lda r1
              and @px_mask,x
              sta a_vram
              pla
              dey
              bpl @cols

              dec r2
              beq @exit

              inc p_tiles
              bne :+
              inc p_tiles+1
:             lda p_vram ; vram addr Y +1 row (scanline)
              eor #$80
              sta p_vram
              bmi :+
              inc p_vram+1
:             jsr gfx_vram_addr
              bra @rows
@exit:
              bgcolor Color_Bg

              ply
              plx
              plp
              rts
@px_mask:
    .byte $00, $0f, $f0, $ff

.data
vdp_init_bytes:  ; vdp init table - MODE G4
    .byte v_reg0_m4|v_reg0_m3|v_reg0_IE1
vdp_reg1_init:
    .byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size|v_reg1_int
    .byte >(VRAM_SCREEN>>2) | $1f
    .byte 0 ; n.a.
    .byte 0 ; n.a.
    .byte >(VRAM_SPRITE_ATTR<<1) | $07    ; R#5 - sprite attribute table - value * $80 --> offset in VRAM
    .byte >(VRAM_SPRITE_PATTERN>>3)  ; R#6 - sprite pattern table - value * $800  --> offset in VRAM
    .byte Color_Bg
    .byte v_reg8_VR | v_reg8_SPD ; R#8 - VR - 64k VRAM TODO set per define
vdp_reg9_init:
    .byte 0 ; v_reg9_ln ; R#9 - 212lines
    .byte 0 ; n.a.
    .byte <.hiword(VRAM_SPRITE_ATTR<<1); R#11 sprite attribute high
    .byte 0;  #R12
    .byte 0;  #R13
    .byte <.hiword(VRAM_SCREEN<<2) ; #R14
vdp_init_bytes_end:

gfx_Sprite_Adjust_X=8
    .byte 8
gfx_Sprite_Adjust_Y=8
    .byte 8
gfx_Sprite_Off=SPRITE_OFF+$08 ; +8, 212 line mode

pacman_palette:
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
  vdp_pal $ff,$b8,$ae   ;b dark pink "food"
  vdp_pal 0,$ff,0       ;c green
  vdp_pal $47,$b8,$ae   ;d dark cyan
  vdp_pal $21,$21,$ff   ;e blue => maze walls, ghosts "scared", ghost pupil
  vdp_pal $de,$de,$ff   ;f gray => ghosts "scared", ghost eyes, text

tiles:
    .include "pacman.tiles.rot.inc"
;tiles_colors:
;    .include "pacman.tiles.colors.inc"
sprite_patterns:
    .include "pacman.ghosts.res"
    .include "pacman.pacman.res"
    .include "pacman.dead.res"
    .include "bonus.res"


Sprite_Pattern_Pacman = $18*4     ; pacman shape filled circle (game init)

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

ghost_2bpp:
  .include "ghost.2bpp.res"

.bss
    sprite_tab_attr:    .res 9*4 ;9 sprites, 4 byte per entry +1 y of sprite 10
    sprite_tab_attr_end:
    scanline: .res 1
