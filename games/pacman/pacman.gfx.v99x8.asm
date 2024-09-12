.include "pacman.v99x8.inc"

.export gfx_init
.export gfx_mode_on
.export gfx_mode_off
.export gfx_bonus_stack
.export gfx_blank_screen
.export gfx_bgcolor
.export gfx_bordercolor
.export gfx_sprites_on
.export gfx_sprites_off
.export gfx_isr
.export gfx_charout
.export gfx_update
.export gfx_prepare_update
.export gfx_display_maze
.export gfx_pause

.autoimport

.importzp sys_crs_x, sys_crs_y

.zeropage
  p_vram:   .res 3  ; 24Bit
  p_gfx:    .res 2
  p_tiles:  .res 2
  r1:       .res 1
  r2:       .res 1
  r3:       .res 1
  r4:       .res 1
  r5:       .res 1
  r6:       .res 1
  r7:       .res 1


  scanline: .res 1

.code

gfx_mode_off:
              php
              sei
              vdp_sreg 0, v_reg15
              vdp_wait_s
              lda io_port_vdp_reg
              plp
              rts

scln_top=254
scln_bottom=221
line=192
gfx_mode_on:
              sei
              lda #<vdp_init_bytes
              ldy #>vdp_init_bytes
              ldx #(vdp_init_bytes_end-vdp_init_bytes-1)
              jsr vdp_init_reg
              ;vdp_sreg $0, v_reg18  ;x/y screen adjust
              vdp_sreg 253, v_reg23  ;y offset

              vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical (flicker), so we setup status S#1 beforehand
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
              vdp_sreg VDP_Color_Blue, v_reg16 ; rotate blue
              ldx gfx_pacman_colors_offset,y
gfx_write_pal:
              vdp_wait_s
              lda pacman_palette+0, x
              sta io_port_vdp_pal
              vdp_wait_s
              lda pacman_palette+1, x
              sta io_port_vdp_pal
              rts

gfx_isr:      lda io_port_vdp_reg ; vdp h blank irq ?
              ror
              bcc @is_vblank
              ; remove border https://www.msx.org/forum/msx-talk/development/removing-border-bitmap-modes?page=0
              ; https://www.msx.org/forum/development/msx-development/here-you-can-see-all-msx2-vram-your-screen
              lda scanline
              and #(212-line) ; line 212 ?
              beq :+
              lda scanline
              cmp #scln_top
              beq @border_top
              cmp #scln_bottom
              beq @border_bottom
              lda #v_reg9_ln
:             ora vdp_reg9_init ; reset mode to init value (192 lines)
              sta io_port_vdp_reg
              lda scanline
              cmp #212
              bne :+
              lda #scln_bottom
              bne @set_reg
:
.ifdef __DEVMODE
              bit game_state+GameState::debug
              bvc :+
              lda #212
:
.endif
              eor #(212-line)  ; 212/192 $d4/$c0
@set_reg:     ldy #v_reg9
              sty io_port_vdp_reg

@set_scln:    sta scanline

.ifdef __DEVMODE
              bit game_state+GameState::debug
              bpl :+
              lda #Color_Cyan
              jsr vdp_bgcolor
              nop
              nop
              nop
              nop
              lda #Color_Bg
              jsr vdp_bgcolor
:
.endif
              ldx #$40
              lda scanline
              ldy #v_reg19
              jsr vdp_set_reg
              cmp #line ; vblank after scanline setup to line (192)
              bne :+
              ldx #$80  ; signal vblank (bit 7)
:
              txa
              rts

@border_bottom:
              lda #v_reg8_VR | v_reg8_SPD ; disable sprites
              ldy #v_reg8
              jsr vdp_set_reg
              lda #scln_top
              bne @set_scln

@border_top:  lda vdp_reg8  ; enable sprites
              ldy #v_reg8
              jsr vdp_set_reg
              lda #line
              bne @set_scln

@is_vblank:   ldx #0
              vdp_sreg 0, v_reg15			; 0 - set status register selection to S#0
              vdp_wait_s
              bit io_port_vdp_reg ; Check VDP interrupt. IRQ is acknowledged by reading.
             	bpl @is_vblank_end  ; VDP IRQ flag set?
              bgcolor Color_Yellow
              ldx #$40
@is_vblank_end:
            	vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical (flicker), so we setup status S#1 beforehand
              txa
              rts

gfx_init:
              sei
              jsr @init
              cli
              rts

@init:        vdp_sreg 0, v_reg16
              ldx #0
:             jsr gfx_write_pal
              inx
              inx
              cpx #2*16
              bne :-

@gfx_init_sprites:
              vdp_vram_w VRAM_SPRITE_PATTERN
              lda #<sprite_patterns
              ldy #>sprite_patterns
              ldx #1+((sprite_patterns_end-sprite_patterns)>>8)
              jsr vdp_memcpy

              vdp_vram_w (VRAM_SPRITE_COLOR+16*4*2)  ; load sprite color address pacman
              lda #Color_Pacman
              ldx #16
              jsr vdp_fills

              lda #gfx_Sprite_Off
              sta sprite_tab_attr_end

gfx_blank_screen:
              php
              sei
              ldy #Color_Bg
              jsr vdp_mode4_blank
              plp
              jmp gfx_sprites_off
gfx_sprites_on:
              lda #0
              beq :+
gfx_pause:    rts ;and #STATE_PAUSE
              beq :+
gfx_sprites_off:
              lda #v_reg8_SPD
:             ora #v_reg8_VR
              php
              sei
              sta vdp_reg8
              ldy #v_reg8
              jsr vdp_set_reg
              plp
              rts

; timing critical update, change video regs
gfx_update:   bgcolor Color_Cyan

              vdp_vram_w VRAM_SPRITE_ATTR
              lda #<sprite_tab_attr
              ldy #>sprite_tab_attr
              ldx #1+(sprite_tab_attr_end-sprite_tab_attr)
              jsr vdp_memcpys

              vdp_vram_w VRAM_SPRITE_COLOR  ; load sprite color address
              ldy #ACTOR_BLINKY             ; color all ghost sprites (4 x 2) - each sprite line
:             lda sprite_color_1,y
              ldx #16
              jsr vdp_fills
              lda sprite_color_2,y
              ldx #16
              jsr vdp_fills
              iny
              cpy #ACTOR_PACMAN
              bne :-

              bgcolor Color_Bg

              rts

; prepare timing critical gfx update
gfx_prepare_update:
              bgcolor Color_Blue

              lda game_state+GameState::frghtd_timer+1
              bne @update
              lda game_state+GameState::frghtd_timer+0
              beq @update
              bmi @update
              and #$10
              beq :+
              lda #6
:             sta r2    ; frightened color mask

@update:      ldy #0
              ldx #ACTOR_BLINKY
:             jsr _gfx_update_sprite_tab_2x
              inx
              cpx #ACTOR_PACMAN
              bne :-
              jsr _gfx_update_sprite_tab_1x

              jsr @is_multiplex
              bcs @exit
              ldx #7*4  ;y sprite_tab offset clyde eyes
              lda game_state+GameState::frames
              and #$01
              beq :+
              ldx #5*4  ;y sprite_tab offset inky eyes
:             lda #gfx_Sprite_Off-1      ; c=0 - must multiplex, sprites scanline conflict +/-16px
              sta sprite_tab_attr,x

@exit:        bgcolor Color_Bg
              rts

@is_multiplex:
              ldx #ACTOR_BLINKY
              jsr @test_sp_y
              bcs @exit ; no further check
              ldx #ACTOR_INKY
              jsr @test_sp_y
              bcs @exit ; no further check
              ldx #ACTOR_PINKY
              jsr @test_sp_y
              bcs @exit ; no further check
              ldx #ACTOR_CLYDE
; X ghost y test with pacman y
@test_sp_y:  ;
              lda actor_sp_y,x
              ldx #ACTOR_PACMAN
              sec
              sbc actor_sp_y,x
              bpl :+
              eor #$ff ; absolute |y1 - y2|
:             cmp #$10 ; 16px ?
              rts

_gfx_update_sprite_tab_2x:
              lda #$02
              jsr _gfx_update_sprite_tab

              lda actor_mode,x
              cmp #ACTOR_MODE_FRIGHT
              bne :+
              eor r2  ; end of frightened phase alternate colors
:             sty r3
              tay
              lda ghost_color,x
              bcc :+  ; < ACTOR_MODE_FRIGHT ?
              lda sprite_colors_1st,y
:             sta sprite_color_1,x
              lda sprite_colors_2nd,y
              sta sprite_color_2,x
              ldy r3

_gfx_update_sprite_tab_1x:
              lda #$00
_gfx_update_sprite_tab:
              sta r1
              lda actor_sp_y,x
              sec
              sbc #gfx_Sprite_Adjust_Y
              cmp #gfx_Sprite_Off
              adc #0 ;skip if >= gfx_Sprite_Off
              sta sprite_tab_attr,y
              iny
              lda actor_sp_x,x
              sec
              sbc #gfx_Sprite_Adjust_X
              sta sprite_tab_attr,y
              iny
              sty r3
              lda actor_shape,x
              cmp #$40
              bcs :+  ; bit 6 - shape offset $40
              ora r1
:             tay
              lda shapes,y
              ldy r3
              sta sprite_tab_attr,y
              iny
              lda #0
              sta sprite_tab_attr,y  ; byte 4 - reserved/unused
              iny
              rts

gfx_display_maze:
              sei
              ldx #4
              ldy #0
              sty sys_crs_x
              sty sys_crs_y
              setPtr game_maze, p_gfx
@loop:        jsr @put_char
@next:        iny
              bne @loop
              inc p_gfx+1
              dex
              bne @loop
              cli
              rts

@put_char:    lda (p_gfx),y
              pha
              cmp #Char_Dot
              beq @food
              cmp #Char_Energizer
              bne @text
@food:        lda #Color_Food
              bne @color
@text:        cmp #Char_Base
              bne @color_border
              lda #Color_Pink
              bne @color
@color_border:
              bcs @color_bg
              lda #Color_Text
              bne @color
@color_bg:
              lda #Color_Maze
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
@exit:        rts

gfx_bordercolor:
gfx_bgcolor:
              php
              sei
              sty r1
              jsr vdp_bgcolor
              ldy r1
              plp
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
              jmp gfx_vram_h        ; A13-A8 vram address high byte

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
              sta io_port_vdp_reg
              sta p_vram+2      ; A16-A14 bank select via reg#14
              lda #v_reg14
              vdp_wait_s 6
              sta io_port_vdp_reg

              lda p_vram
              vdp_wait_s 4
              jmp gfx_vram_addr

gfx_vram_inc_y:
              lda p_vram ; vram addr Y +1 row (scanline)
              eor #$80
              sta p_vram
              bmi gfx_vram_addr
              inc p_vram+1

gfx_vram_addr:
              sta io_port_vdp_reg
              lda p_vram+1
              and #$3f
              sta p_vram+1      ; A13-A8 vram address highbyte
              ora #(WRITE_ADDRESS | (>.LOWORD(VRAM_SCREEN) & $3f))
              vdp_wait_s 10
              sta io_port_vdp_reg
              rts


.export gfx_lives
; in: Y - lives
gfx_lives:    sei
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
              cli
              rts

; in
;   A - level
gfx_bonus_stack:
              sta r2    ; save current level
              lda #17*8
              sta r3
              lda #7    ; max 7 bonus items visible on stack, we build top down
              sta r4
@next:        ldy #Bonus_Clear  ; start with "no bonus"
              lda r2
              cmp r4    ; draw bonus, or still clear?
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

gfx_4bpp_xy:  sei

              pha
              jsr gfx_vram_xy
              lda #Color_Bg
              sta r5  ; reset color mask
              sta r6
              pla

              cmp #Bonus_Clear  ; clear?
              bne @bonus_4bpp

              ldy #$0c  ; height
@erase:       ldx #$07  ; width 7x2px
@erase_cols:  vdp_wait_l 9
              lda #Color_Bg
              sta io_port_vdp_ram
              dex
              bne @erase_cols
              jsr gfx_vram_inc_y
              dey
              bne @erase
              cli
              rts

@bonus_4bpp:  tay
              dey ; adjust for table lookup
              lda #$0c  ; 12px height
; in:
;   A - height
;   Y - index 4bpp table
gfx_4bpp_y:
              sta r1
              lda table_4bpp_l,y
              sta p_gfx+0
              lda table_4bpp_h,y
              sta p_gfx+1

              ldy #0
@rows:        ldx #7      ; 7x2 14px width
@cols:        lda (p_gfx),y
              and #$f0
              beq :+    ; background?
              ora r5    ; otherwise mask nybble
:             sta r7
              lda (p_gfx),y
              and #$0f
              beq :+    ; same...
              ora r6
:             ora r7
              vdp_wait_l 22
              sta io_port_vdp_ram
              iny
              dex
              bne @cols

              dec r1
              beq @exit
              jsr gfx_vram_inc_y
              jmp @rows

@exit:        bgcolor Color_Bg
              cli
              rts

.export gfx_ghost_icon
gfx_ghost_icon:
              sei
              lda sys_crs_x
              asl               ; X*4 (4bpp, 2px per byte)
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

; A: char to output
gfx_charout:
              sei
              sta r1
              pha
              txa
              pha
              tya
              pha

              bgcolor Color_Gray

              jsr gfx_vram_crs

              lda #0
              sta p_tiles+1
              lda r1            ; pointer to charset
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
              and #$0f
              asl
              asl
              asl
              asl
              ora text_color
              sta r1            ; prepare "pen"

              lda #8
              sta r2
@rows:        ldy #0
              lda (p_tiles),y
              ldy #3
@cols:        asl
              rol
              pha
              rol
              and #$03
              tax
              lda r1
              and mask_4bpp,x
              sta io_port_vdp_ram
;              vdp_wait_l 32
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
              jmp @rows
@exit:
              bgcolor Color_Bg

              pla
              tay
              pla
              tax
              pla
              cli
              rts

.data

mask_4bpp:
    .byte $00, $0f, $f0, $ff

sprite_colors_1st: ; color 1st ghost sprite for various ghost modes. normal, frightened, catched,...
    .byte Color_Bg
    .byte Color_Bg
    .byte Color_Blue
    .byte Color_Cyan
    .byte Color_Gray

sprite_colors_2nd:  ; color 2nd ghost sprite
    .byte Color_Blue | SPRITE_CC | SPRITE_IC
    .byte Color_Blue | SPRITE_CC | SPRITE_IC
    .byte Color_Pink
    .byte Color_Bg
    .byte Color_Red


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
    .byte v_reg8_VR | v_reg8_SPD ; R#8 - VR - 64k VRAM
.export vdp_reg9_init
vdp_reg9_init:
    .byte 0 ; v_reg9_ln ; R#9 - 212lines
    .byte 0 ; n.a.
    .byte <.hiword(VRAM_SPRITE_ATTR<<1); R#11 sprite attribute high
    .byte 0;  #R12
    .byte 0;  #R13
    .byte <.hiword(VRAM_SCREEN<<2) ; #R14
vdp_init_bytes_end:

gfx_Sprite_Adjust_X=8
gfx_Sprite_Adjust_Y=9
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
    .include "pacman.ghosts.res"        ; 20 sprites
    .include "pacman.pacman.res"        ; 10 sprites
    .include "pacman.dying.res"         ; 11 sprites
    .include "pacman.bonus.res"         ;  4 sprites
    .include "pacman.intermission.res"  ; 12 sprites
sprite_patterns_end:

shapes:
; pacman  $00
    .byte $14*4,$14*4+4,$1c*4,$14*4 ;r  00
    .byte $1a*4+4,$1a*4,$1c*4,$1a*4 ;d  01
    .byte $16*4+4,$16*4,$1c*4,$16*4 ;l  10
    .byte $18*4,$18*4+4,$1c*4,$18*4 ;u  11
; ghosts  $10
    .byte $08*4,$08*4,$00*4,$00*4+4 ;r  00
    .byte $0b*4,$0b*4,$06*4,$06*4+4 ;d  01
    .byte $09*4,$09*4,$02*4,$02*4+4 ;l  10
    .byte $0a*4,$0a*4,$04*4,$04*4+4 ;u  11
; ghost eyes only (catched) $20
    .byte $08*4,$08*4,$10*4,$10*4 ;r  00
    .byte $0b*4,$0b*4,$13*4,$13*4 ;d  01
    .byte $09*4,$09*4,$11*4,$11*4 ;l  10
    .byte $0a*4,$0a*4,$12*4,$12*4 ;u  11
; ghosts frighened $30
    .byte $0e*4,$0e*4,$0c*4,$0c*4+4 ;r,d,l,u
; pacman dying
    .byte $28*4,$27*4,$26*4,$25*4
    .byte $24*4,$23*4,$22*4,$21*4
    .byte $20*4,$1f*4,$1e*4,$1d*4 ; empty sprite ($3f)
; ghosts bonus pts $40
    .byte $29*4,$2a*4,$2b*4,$2c*4
; pacman interlude $44
    .byte $2d*4,$2e*4,$2f*4,$30*4
    .byte $2d*4,$2e*4,$2f*4,$30*4
    .byte $2d*4,$2e*4,$2f*4,$30*4
    .byte $2d*4,$2e*4,$2f*4,$30*4

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
    sprite_tab_attr:      .res 9*4  ; 9 sprites, 4 byte per entry +1 y of sprite 10
    sprite_tab_attr_end:  .res 1    ; Y sprite 10, set to "off"
    sprite_color_1:       .res 4
    sprite_color_2:       .res 4
    vdp_reg8:             .res 1    ; mirror vdp reg 8
