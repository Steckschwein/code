    .setcpu "6502"
    .export gfx_init
    .export gfx_mode_on
    .export gfx_mode_off
    .export gfx_blank_screen
    .export gfx_sprites_on
    .export gfx_sprites_off
    .export gfx_bgcolor
    .export gfx_bordercolor

    .export gfx_charout
    .export gfx_rotate_pal
    .export gfx_update
    .export gfx_display_maze
    .export gfx_hires_off
    .export gfx_pause
    .export gfx_Sprite_Off
    .export gfx_colors

    .autoimport

    .importzp sys_crs_x,sys_crs_y

    .include "pacman.c64.inc"


    ;sprite y = 50, 250 off
    ;sprite x = 24

VIC_SPR_MCOLOR_DEFAULT = %00101010 ; 3 ghost eyes as multic color, sprite 7 is multiplexed either ghost eyes or pacman
VIC_SPR_MCOLOR_MX = %10101010 ; 4 ghost exes if multiplexed

SPRITE_SIZE_Y=21
SPRITE_SIZE_X=24

gfx_Sprite_Adjust_X=12  ; px x offset from char map
gfx_Sprite_Adjust_Y=39  ; px y offset from char map
gfx_Sprite_Off=250

.struct mx_sprite
  xp  .byte
  yp  .byte
  pp  .byte  ; pattern
  mc  .byte ; multi color  bitmask
.endstruct

.zeropage
  r1: .res 1
  r2: .res 1
  r3: .res 1

.code
gfx_mode_off:

gfx_mode_on:
    lda #(VRAM_SCREEN>>6 | VRAM_PATTERN>>10)
    sta VIC_VIDEO_ADR  ; $d018

    lda #$ff
    sta VIC_SPR_ENA
    lda #VIC_SPR_MCOLOR_DEFAULT
    sta VIC_SPR_MCOLOR
    ldx #Color_Gray
    lda gfx_colors,x
    sta VIC_SPR_MCOLOR0
    ldx #Color_Blue
    lda gfx_colors,x
    sta VIC_SPR_MCOLOR1

gfx_rotate_pal:
    rts

gfx_init:
    lda #$61    ; pattern open border
    sta $3fff  ; last byte bank 0 - we open the border
    lda #Color_Bg
    sta VIC_BORDERCOLOR
    sta VIC_BG_COLOR0
    ldx #$0f
    lda #0
:   sta VIC_SPR0_X,x
    dex
    bpl :-
    ldx #Color_Blinky
    lda gfx_colors,x
    sta VIC_SPR0_COLOR
    ldx #Color_Pinky
    lda gfx_colors,x
    sta VIC_SPR2_COLOR
    ldx #Color_Inky
    lda gfx_colors,x
    sta VIC_SPR4_COLOR
    ldx #Color_Clyde
    lda gfx_colors,x
    sta VIC_SPR6_COLOR
    ldx #Color_Pacman
    lda gfx_colors,x
    sta VIC_SPR7_COLOR

;gfx_init_pal:
gfx_init_chars:
    ldx #8
    setPtr tiles,  p_tmp
    setPtr VRAM_PATTERN, p_video
    jsr gfx_memcpy
    setPtr sprite_patterns, p_tmp
    setPtr VRAM_SPRITE_PATTERN, p_video
    ldx #9
    jsr gfx_memcpy

gfx_blank_screen:
    setPtr VRAM_SCREEN, p_video
    ldx #4
    ldy #0
    lda #0
:     sta (p_video),y
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
@gfx_test_sp_y:  ;
    sec
    lda actors+actor::sp_y,x
    sbc actors+actor::sp_y,y
    bpl :+
    eor #$ff ; absolute |y1 - y2|
:   cmp #SPRITE_SIZE_Y ; C=1 if >=21px size distance
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
:  sta VRAM_SPRITE_POINTER+1+_n*2
.else
  dec mx_tab+_mx*.sizeof(mx_sprite)+mx_sprite::xp     ; adjust 1px left if eyes up on 2nd sprite
:  sta mx_tab+_mx*.sizeof(mx_sprite)+mx_sprite::pp
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

    jsr _gfx_is_sp_collision  ; 9th sprite collision ?
; sp9 collision:
;   frame & 0x1 == 1: g0/e1 g2/e3 g4/   g5/e6 p7
;   frame & 0x1 == 0: g0/e1 g2/e3 g4/e5 g6/   p7

    bcs @set_hline  ; C=1 no collision, otherwise X ghost, Y pacman with collision
; sonst:
;
;


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
:   sty mx_tab_ix
    lda mx_tab+mx_sprite::yp,y
    clc
    adc #SPRITE_SIZE_Y  ; hline irq after current sprite - 21 scanline
    cmp #HLine_Border-4
    bcs gfx_mx        ; skip if below border
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

gfx_sprites_on:
    lda #$ff
    sta VIC_SPR_ENA
    rts
gfx_sprites_off:
    lda #0
    sta VIC_SPR_ENA
    rts

gfx_display_maze:
    ldx #4
    ldy #0
    sty sys_crs_x
    sty sys_crs_y
    setPtr game_maze, p_maze
@loop:
    lda (p_maze),y
    sta r1
    cmp #Char_Dot
    bne @s_food
    lda #Color_Food
    bne @color
@s_food:
    cmp #Char_Energizer
    bne @text
    lda #Color_Food
    bne @color
@text:
    cmp #Char_Bg
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
    lda r1
    jsr gfx_charout
    inc sys_crs_x
    lda sys_crs_x
    and #$1f
    bne @next
    sta sys_crs_x
    inc sys_crs_y
@next:
    iny
    bne @loop
    inc p_maze+1
    dex
    bne @loop
    rts


.export gfx_lives
.export gfx_bonus_stack
.export gfx_bonus
gfx_lives:
gfx_bonus_stack:
gfx_bonus:
    rts

.export gfx_ghost_icon
gfx_ghost_icon:
    rts

gfx_memcpy:
    ldy #0
:   lda (p_tmp),y
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
    stx r1
    sty r2

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
    ldx text_color
    lda gfx_colors,x
    sta (p_tmp),y
    ldy r2
    ldx r1
    rts

gfx_hires_off:  ;?!?
    rts
gfx_bordercolor:
    tax
    lda gfx_colors,x
    sta VIC_BORDERCOLOR
    rts
gfx_bgcolor:
    tax
    lda gfx_colors,x
    sta VIC_BG_COLOR0
    rts

gfx_pause:
    rts


.data
shapes:
offs=VRAM_SPRITE_PATTERN / $40
; pacman      [    <     O     <
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

gfx_colors:  ; mapping between pacman original color number 0..f and c64 color
.byte COLOR_BLACK
.byte COLOR_RED       ;1 "shadow", "blinky" red
.byte COLOR_BROWN     ;2 Orange top, cherry stem
.byte COLOR_VIOLET    ;3 "speedy", "pinky" pink
.byte COLOR_BLACK
.byte COLOR_CYAN      ;5 "bashful", "inky" cyan
.byte COLOR_LIGHTBLUE
.byte COLOR_ORANGE    ;7 "pokey", "Clyde" "orange"
.byte COLOR_BLACK
.byte COLOR_YELLOW    ;9 "yellow", "pacman"
.byte COLOR_BLACK
.byte COLOR_LIGHTRED  ;b dark pink "food"
.byte COLOR_GREEN
.byte COLOR_CYAN      ;
.byte COLOR_BLUE      ; e blue => ghosts "scared", ghost pupil
.byte COLOR_GRAY3     ; f gray => ghosts "scared", ghost eyes


.bss
mx_tab_ct: .res 1 ; multiplex counter
mx_tab_ix: .res 1
mx_tab:
  .tag mx_sprite
  .tag mx_sprite
