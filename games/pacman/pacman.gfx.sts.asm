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
  r5: .res 1
  r6: .res 1

  scanline: .res 1

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
              ; remove border https://www.msx.org/forum/msx-talk/development/removing-border-bitmap-modes?page=0
              ; https://www.msx.org/forum/development/msx-development/here-you-can-see-all-msx2-vram-your-screen
              lda scanline
              and #(212-line)
              beq :+
              lda #v_reg9_ln
:             ora vdp_reg9_init
              sta a_vreg
              lda scanline
              eor #(212-line)  ; 212/192
              sta scanline
              ldy #v_reg9
              sty a_vreg
.ifdef __DEBUG
              lda #Color_Orange
              jsr vdp_bgcolor
              lda #Color_Bg
              jsr vdp_bgcolor
.endif
              ldx #$40
              lda scanline
              ldy #v_reg19
              jsr vdp_set_reg
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

@gfx_init_sprites:
              vdp_vram_w VRAM_SPRITE_PATTERN
              lda #<sprite_patterns
              ldy #>sprite_patterns
              ldx #8
              jsr vdp_memcpy

              vdp_vram_w VRAM_SPRITE_COLOR  ; load sprite color address

              lda #Color_Blinky
              jsr _fills
              lda #(VDP_Color_Blue | SPRITE_CC | SPRITE_IC)  ; CC | IC | 2nd color
              jsr _fills

              lda #Color_Inky
              jsr _fills
              lda #(VDP_Color_Blue | SPRITE_CC | SPRITE_IC)  ; CC | IC | 2nd color
              jsr _fills

              lda #Color_Pinky
              jsr _fills
              lda #(VDP_Color_Blue | SPRITE_CC | SPRITE_IC)  ; CC | IC | 2nd color
              jsr _fills

              lda #Color_Clyde
              jsr _fills
              lda #(VDP_Color_Blue | SPRITE_CC | SPRITE_IC)  ; CC | IC | 2nd color
              jsr _fills

              lda #VDP_Color_Yellow
              jsr _fills

              lda #gfx_Sprite_Off
              sta sprite_tab_attr_end

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
:   sta r1
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
    ora r1
    tay
    lda shapes,y
    ply
    sta sprite_tab_attr,y
    iny
    lda #0
    sta sprite_tab_attr,y  ; byte 4 - reserved/unused
    iny
    rts

gfx_display_maze:
        ldx #3
        ldy #0
        sty sys_crs_x
        sty sys_crs_y
        setPtr game_maze, p_gfx
;        setPtr maze, p_maze
@loop:  jsr @put_char
@next:  iny
        bne @loop
        inc p_gfx+1
 ;       inc p_maze+1
        dex
        bne @loop
:       jsr @put_char
        iny
;        cpy #$c0
        bne :-
        rts

@put_char:
        lda (p_gfx),y
;        cmp (p_maze),y
 ;       bne :+
  ;      rts
:       pha
        cmp #Char_Dot
        beq @food
        cmp #Char_Energizer
        bne @text
@food:  lda #Color_Food
        bne @color
@text:  cmp #Char_Base
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
        ora #Char_Maze_Mask
        jsr gfx_charout
        inc sys_crs_x
        lda sys_crs_x
        and #$1f
        bne @exit
        sta sys_crs_x
        inc sys_crs_y
@exit:  rts

gfx_bordercolor=vdp_bgcolor
gfx_bgcolor:
              phy
              jsr vdp_bgcolor
              ply
              rts

; set the vdp vram address upon X/Y pixel position
;  in:
;    X - 0..128 - multiple of 2
;    Y - 0..240 (overscan)
gfx_vram_xy:
              tya
              lsr                   ; Y Bit 0 to carry
              txa
              ror                   ; X/2 OR with Y Bit 0 (carry)
              sta p_vram            ; A7-A0 vram address low byte

              tya
              lsr
              bra gfx_vram_h        ; A13-A8 vram address high byte

; set the vdp vram address upon crs x/y
;  in:
;    sys_crs_x - x 0..31
;    sys_crs_y - y 0..31 (overscan)
gfx_vram_crs:
              lda sys_crs_x
              assertA_le 31
              asl               ; X*4 (2px per byte)
              asl
              sta p_vram        ; A7-A0 vram address low byte

              lda sys_crs_y     ; Y*8*128 => $0000, $0400, $0800
              assertA_le 31     ; effectively high byte Y*4
              asl
              asl

gfx_vram_h:   sta p_vram+1
              asl
              rol               ; Bit 15 - rol over carry
              rol               ; Bit 14
              and #$03
              ora #<.HIWORD(VRAM_SCREEN<<2)
              sta a_vreg
              sta p_vram+2      ; A16-A14 bank select via reg#14
              lda #v_reg14
              vdp_wait_s 6
              sta a_vreg

              lda p_vram
              vdp_wait_s 4
              bra gfx_vram_addr

gfx_vram_inc_y:
              lda p_vram ; vram addr Y +1 row (scanline)
              eor #$80
              sta p_vram
              bmi gfx_vram_addr
              inc p_vram+1

gfx_vram_addr:
              sta a_vreg
              lda p_vram+1
              and #$3f
              sta p_vram+1      ; A13-A8 vram address highbyte
              ora #(WRITE_ADDRESS | (>.LOWORD(VRAM_SCREEN) & $3f))
              vdp_wait_s 10
              sta a_vreg
              rts


.export gfx_lives
; in: Y - lives
gfx_lives:
              sty r3
              lda #31
              sta sys_crs_y
              ldx #MAX_LIVES
@l0:          ldy #Color_Pacman
              cpx r3
              bcc :+
              beq :+
              ldy #Color_Bg
:             sty text_color
              txa
              asl   ; crs x pos live *2 FTW
              sta sys_crs_x
              lda #$b0
              jsr gfx_charout
              dec sys_crs_y
              lda #$b1
              jsr gfx_charout

              inc sys_crs_x
              lda #$b3
              jsr gfx_charout
              inc sys_crs_y
              lda #$b2
              jsr gfx_charout

              dex
              bne @l0
              rts

.export gfx_bonus_stack
; in
;   A - level
gfx_bonus_stack:
              sta r2    ; save current level
              lda #17*8
              sta r3
              lda #7    ; max 7 bonus items visible on stack, we build top down
              sta r4
@next:        ldy #Bonus_Clear
              lda r2
              cmp r4
              bcc @bonus
              dec r2    ; level - 1
              jsr bonus_for_level
@bonus:       tya
              ldx r3
              ldy #31*8-5
              jsr gfx_4bpp_xy
              lda r3    ; inc x position
              clc
              adc #16
              sta r3
              dec r4
              bne @next
              rts

.export gfx_bonus
gfx_bonus:    ; bonus below ghost house
              ldx #$11*8+6
              ldy #$0d*8+2
gfx_4bpp_xy:
              stz r5  ; color mask
              stz r6

              pha
              jsr gfx_vram_xy
              pla

              bgcolor Color_Blue

              cmp #0
              bne @bonus_4bpp

              ldy #$0c  ; height
@erase:       ldx #$07  ; width 7x2px
@erase_cols:  vdp_wait_l 7
              stz a_vram
              dex
              bne @erase_cols
              jsr gfx_vram_inc_y
              dey
              bne @erase
              bgcolor Color_Bg
              rts

@bonus_4bpp:  dea ; adjust for table lookup
              tay
              lda #$0c  ; 12px height
; in:
;   A - height
;   Y - index 4bpp table
gfx_4bpp_y:
              sta r1
              lda table_4bpp_l,y
              sta p_gfx
              lda table_4bpp_h,y
              sta p_gfx+1

              ldy #0
@rows:        ldx #7    ; 7x2 14px width
@cols:        lda (p_gfx),y
              bit #$f0
              beq :+    ; background?
              ora r5    ; otherwise mask nybble
:             bit #$0f
              beq :+    ; same...
              ora r6
:             vdp_wait_l 22
              sta a_vram
              iny
              dex
              bne @cols

              dec r1
              beq @exit
              jsr gfx_vram_inc_y
              bra @rows

@exit:        bgcolor Color_Bg
              rts

.export gfx_ghost_icon
gfx_ghost_icon:
              lda sys_crs_x
              asl               ; X*4 (2px per byte)
              asl
              clc
              adc #2            ; adjust 2x2px
              sta p_vram        ; A7-A0 vram address low byte

              lda sys_crs_y     ; Y*8*128 => $0000, $0400, $0800
              asl
              asl
              jsr gfx_vram_h

              lda text_color    ; setup color mask
              and #$0e
              sta r6
              asl
              asl
              asl
              asl
              sta r5
              lda #$0e  ; height - see ghost.4bpp.xpm
              ldy #Index_4bpp_ghost
              jmp gfx_4bpp_y

gfx_charout:
              php
              sei
              phx
              phy
              pha

;              assertA_eq Char_Superfood

              bgcolor Color_Gray

              jsr gfx_vram_crs

              pla               ; pointer to charset
              stz p_tiles+1
              asl ; char * 8
              rol p_tiles+1
              asl
              rol p_tiles+1
              asl
              rol p_tiles+1
              ;clc
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
@cols:        vdp_wait_l 32
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
    .byte >(VRAM_SPRITE_ATTR<<1) | $07    ; R#5 - sprite attribute table
    .byte >(VRAM_SPRITE_PATTERN>>3)       ; R#6 - sprite pattern table
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
gfx_Sprite_Adjust_Y=8
gfx_Sprite_Off=SPRITE_OFF+$08 ; +8, 212 line mode

pacman_palette:
  vdp_pal 0,0,0         ;0
  vdp_pal $ff,0,0       ;1 "shadow", "blinky" red
  vdp_pal $de,$97,$51   ;2 orange top, cherry stem "food"
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

sprite_patterns:
    .include "pacman.ghosts.res"  ; 16 sprites
    .include "pacman.pacman.res"  ;  8 sprites
    .include "pacman.dying.res"   ; 11 sprites
    .include "bonus.res"


shapes:
; pacman
    .byte $14*4+4,$14*4,$1c*4,$14*4 ;r  00
    .byte $16*4+4,$16*4,$1c*4,$16*4 ;l  01
    .byte $18*4+4,$18*4,$1c*4,$18*4 ;u  10
    .byte $1a*4+4,$1a*4,$1c*4,$1a*4 ;d  11
; ghosts  $10
    .byte $08*4,$08*4,$00*4,$00*4+4 ;r  00
    .byte $09*4,$09*4,$02*4,$02*4+4 ;l  01
    .byte $0a*4,$0a*4,$04*4,$04*4+4 ;u  10
    .byte $0b*4,$0b*4,$06*4,$06*4+4 ;d  11
; ghost eyes only (catched) $20
    .byte $08*4,$08*4,$10*4,$10*4 ;r  00
    .byte $09*4,$09*4,$11*4,$11*4 ;l  01
    .byte $0a*4,$0a*4,$12*4,$12*4 ;u  10
    .byte $0b*4,$0b*4,$13*4,$13*4 ;d  11
; ghosts scared $30
    .byte $0e*4,$0e*4,$0c*4,$0c*4+4 ;r,l,u,d
; pacman dying
    .byte $28*4,$27*4,$26*4,$25*4
    .byte $24*4,$23*4,$22*4,$21*4
    .byte $20*4,$1f*4,$1e*4,$1d*4 ; empty sprite

table_4bpp_l:
  .byte <bonus_4bpp_cherry
  .byte <bonus_4bpp_strawberry
  .byte <bonus_4bpp_orange
  .byte <bonus_4bpp_apple
  .byte <bonus_4bpp_grapes
  .byte <bonus_4bpp_galaxian
  .byte <bonus_4bpp_bell
  .byte <bonus_4bpp_key
Index_4bpp_ghost=(*-table_4bpp_l)
  .byte <ghost_4bpp
table_4bpp_h:
  .byte >bonus_4bpp_cherry
  .byte >bonus_4bpp_strawberry
  .byte >bonus_4bpp_orange
  .byte >bonus_4bpp_apple
  .byte >bonus_4bpp_grapes
  .byte >bonus_4bpp_galaxian
  .byte >bonus_4bpp_bell
  .byte >bonus_4bpp_key
  .byte >ghost_4bpp

bonus_4bpp_cherry:
  .include "bonus.cherry.4bpp.res"
bonus_4bpp_strawberry:
  .include "bonus.strawberry.4bpp.res"
bonus_4bpp_apple:
  .include "bonus.apple.4bpp.res"
bonus_4bpp_bell:
  .include "bonus.bell.4bpp.res"
bonus_4bpp_galaxian:
  .include "bonus.galaxian.4bpp.res"
bonus_4bpp_key:
  .include "bonus.key.4bpp.res"
bonus_4bpp_grapes:
  .include "bonus.grapes.4bpp.res"
bonus_4bpp_orange:
  .include "bonus.orange.4bpp.res"
ghost_4bpp:
  .include "ghost.4bpp.res"

.bss
    sprite_tab_attr:      .res 9*4 ; 9 sprites, 4 byte per entry +1 y of sprite 10
    sprite_tab_attr_end:  .res 1   ; Y sprite 10, set to "off"
