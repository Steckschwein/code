; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
.setcpu "65c02"
.include "kernel_jumptable.inc"
.include "fcntl.inc"
.include "vdp.inc"
.include "rtc.inc"
.include "common.inc"
.include "zeropage.inc"
.include "joystick.inc"
.include "uart.inc"
.include "snes.inc"
.include "fat32.inc"
.include "keyboard.inc"
.include "appstart.inc"

.autoimport

appstart $1000

JOY_PORT=JOY_PORT1    ;port 1

.export char_out=krn_chrout

.exportzp controller1, controller2

.zeropage
ptr1:         .res 2
level_bg_ptr: .res 2
sin_tab_ptr:  .res 2
controller1:  .res 3
controller2:  .res 3
_i: .res 1
_j: .res 1

CHAR_BLANK=210
CHAR_LAST_FG=198    ; last character of foreground (cacti), range 128-198
CHAR_ASSET=211      ; 211-227

A_GX_SCR=$1800
A_GX_COL=$1c80
A_GX_PAT_1=$0000
A_GX_PAT_2=$0800
A_SP_PAT=$1000
A_SP_ATR=$1c00
GAME_CHAR_OFFS=$0400
Y_OFS_GAME_OVER=10
screen=$2000
dinosaur_color=Dark_Green
dinosaur_color_xmas=Dark_Red
DINOSAUR_X=16
DINOSAUR_Y=125
PD_X=$ef      ;100
PD_Y=PD_Y_OFF ;120
PD_Y_OFF=$bf
PD_SPEED=5
PD_PTR=64
EC_MAX_RIGHT_POS=32
DINOSAUR_HEIGHT=30
DINOSAUR_RUN=1<<0
DINOSAUR_JUMP=1<<1
DINOSAUR_DUCK=1<<2
DINOSAUR_DEAD=1<<3

STATUS_PLAY=1<<0
STATUS_GAME_OVER=1<<1
STATUS_JOY_PRESSED=1<<2
STATUS_EXIT=1<<7

dinosaur_cap=56
sprite_empty=$60

.code
    jsr krn_textui_disable

    lda  #33
    sta  seed

    sei
    jsr init_vram
    jsr load_highscore

    jsr new_game
    lda #STATUS_GAME_OVER
    sta game_state

    copypointer SYS_VECTOR_IRQ, save_isr
    SetVector game_isr, SYS_VECTOR_IRQ

    lda #<vdp_init_gfx
    ldy #>vdp_init_gfx
    ldx #<(vdp_init_gfx_end-vdp_init_gfx)-1
    jsr vdp_init_reg

    cli
:   lda game_state
    bpl :-

    sei
    copypointer save_isr, SYS_VECTOR_IRQ
    cli
    jsr krn_textui_init
    jsr krn_textui_enable
    jmp (retvec)


isXmas: ; only 24.12-26.12. load xmas gfx
    lda rtc_systime_t+4
    cmp #11
    bne :+
    lda rtc_systime_t+3 ; day
    cmp #24
    bcc :++
    cmp #27
    bcs :+
    sec
    rts
:   clc
:   rts

vdp_init_gfx:
    .byte 0
    .byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size|v_reg1_int
    .byte (A_GX_SCR / $400)  ; name table - value * $400          --> characters
    .byte (A_GX_COL /  $40)  ; color table - value * $40 (gfx1), 7f/ff (gfx2)
    .byte (A_GX_PAT_2 / $800) ; pattern table (charset) - value * $800    --> offset in VRAM
    .byte (A_SP_ATR / $80)  ; sprite attribute table - value * $80     --> offset in VRAM
    .byte (A_SP_PAT / $800)  ; sprite pattern table - value * $800      --> offset in VRAM
    .byte Light_Blue
    .byte v_reg8_VR  ; SPD - sprite disabled, VR - 64k VRAM
    .byte v_reg9_nt ;#R9 PAL
vdp_init_gfx_end:

init_screen:        ;draw desert
    ldx  #$00
    ldy  #206
@loop:
    lda  #CHAR_BLANK
    sta  screen,x
    sta  screen+32*1,x
    sta  screen+32*2,x
    tya
    sta  screen+32*3,x
    iny
    cpy  #CHAR_BLANK
    bne  :+
    ldy  #206
:   inx
    cpx  #32
    bne @loop
    rts

scroll_background:
    lda  frame_cnt
    and  #01
    bne  :+
    lda  #00
    ldy  #v_reg4
    vdp_sreg
    rts
:   lda  #(A_GX_PAT_2 / $800)
    ldy  #v_reg4
    vdp_sreg

    ldx  #$00
:   lda  screen+1,x
    sta  screen,x
    lda  screen+32+1,x
    sta  screen+32,x
    lda  screen+32*2+1,x
    sta  screen+32*2,x
    lda  screen+32*3+1,x
    sta  screen+32*3,x
    inx
    cpx  #32
    bne  :-

     ; level generator
    lda  level_bg_cnt    ;
    cmp  (level_bg_ptr)
    beq  @lscript
@lgen:
    asl  ; x4, rows
    asl
    tay
    iny ;+1 into bg table
    lda  (level_bg_ptr),y
    sta  screen+31
    iny
    lda  (level_bg_ptr),y
    sta  screen+31+(32*1)
    iny
    lda  (level_bg_ptr),y
    sta  screen+31+(32*2)
    iny
    lda  (level_bg_ptr),y
    sta  screen+31+(32*3)
    inc  level_bg_cnt
    rts
@lscript:
    ldx  level_script_ix
    lda  level_script, x
    bpl  :+
    stz  level_script_ix
    bra  @lscript
:    tax
    inc level_script_ix
    txa
    beq  @lgen_bg     ;0 - background desert/hills
    bit #1            ;1 - cacti
    bne @lgen_cacti   ;2 - otherwise, pterodactyl

    ;enable pterodactyl
    jsr  enable_pd
    bra @lgen_bg      ;bg desert/hills

@lgen_cacti:
    jsr rnd      ;otherwise choose cacti randomly
    and  #$03
    asl
    tax
    lda  bg_table, x  ;set level background ptr into level table
    sta  level_bg_ptr
    lda  bg_table+1, x
    sta  level_bg_ptr+1
    bra  @lgen_none

@lgen_bg:
    jsr rnd      ;desert/hills randomly
    and  #$10
    beq  @lgen_bg_6
    SetVector level_bg_5, level_bg_ptr
    bra  @lgen_none
@lgen_bg_6:
    SetVector level_bg_6, level_bg_ptr
@lgen_none:
    lda #0
    sta level_bg_cnt
    bra @lgen

bg_table:
    .word level_bg_1
    .word level_bg_2
    .word level_bg_3
    .word level_bg_4

level_script:
     ; 0 - background
     ; 1 - cacti
     ; 2 - pterodactyl with background
;     .byte 0,0,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0,0,1,0,0,1,0,0,0,0,1,$80
    .byte 0,0,0,0,0,0,1,0,0,0,1,0,2,0,0,0,0,1,0,0,0,2,0,0,1,0,0,0,1,0,0,1,0,0,0,1,0,0,1,2,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,2,0,1,0,0,0,0,2,0,1,0,0,1,$80

;  detection algorithm - dinosaur is 32*32px, we check only char positions and sprites as follows - cause this best matches the dinosaur shape
;   ##     -> ##
;   ##       #
;  ##      #
;  ##
detect_collision:
    ldx  #(DINOSAUR_Y-4*8+DINOSAUR_HEIGHT)    ; 4x8px height cacti char
    lda  #CHAR_LAST_FG              ; test cacti chars
    cmp  screen+(DINOSAUR_X/8)+1
    bcs  :+
    ldx  #(DINOSAUR_Y-3*8+DINOSAUR_HEIGHT)    ; 3x8px height cacti char
    cmp  screen+(DINOSAUR_X/8)+2
    bcs  :+
    ldx  #(DINOSAUR_Y-2*8+DINOSAUR_HEIGHT)    ; 2x8px height cacti char
    cmp  screen+(DINOSAUR_X/8)+1+32*1
    bcs  :+
    cmp  screen+(DINOSAUR_X/8)+0+32*2
    bcs  :+
    rts
:
    txa                      ; x was set above
    cmp  sprite_tab+1*4              ; test the y pos of the lower sprites, sufficient for collision - we jump on the cacti
    bcc  :+
    beq  :+
    cmp  sprite_tab+3*4
    bcc  :+
    beq  :+

    ;detect collision - pterodactyl
    lda  #(DINOSAUR_X)
    cmp  sprite_tab_enemy
    rts

:   lda  #DINOSAUR_DEAD
    sta dinosaur_state

  game_over:
    jsr update_highscore

    jsr get_joy_status
    and #JOY_FIRE    ;if fire is pressed set bit
    beq :+
    jsr getkey
    cmp #$20   ; space ?
    bne :++
:   lda #STATUS_JOY_PRESSED | STATUS_GAME_OVER
    bra set_state
:   lda #STATUS_GAME_OVER
set_state:
    sta game_state

    SetVector text_game_over, ptr1
    lda  #<(A_GX_SCR + (Y_OFS_GAME_OVER*32))+11
    ldy  #WRITE_ADDRESS + >(A_GX_SCR+(Y_OFS_GAME_OVER*32))
    jsr vdp_print
    SetVector text_game_reload_1, ptr1
    lda  #<(A_GX_SCR + ((Y_OFS_GAME_OVER+2)*32))+14
    ldy  #WRITE_ADDRESS + >(A_GX_SCR+((Y_OFS_GAME_OVER+2)*32))
    jsr vdp_print
    SetVector text_game_reload_2, ptr1
    lda  #<(A_GX_SCR + ((Y_OFS_GAME_OVER+3)*32))+14
    ldy  #WRITE_ADDRESS + >(A_GX_SCR+((Y_OFS_GAME_OVER+3)*32))

vdp_print:
    vdp_sreg
    ldy  #0
:   lda  (ptr1),y
    beq  :+
    vdp_wait_l
    sta  a_vram
    iny
    bne  :-
:   rts

get_joy_status:
    phx
    phy
    joy_off
    jsr query_controllers
    joy_on
    ply
    plx
    lda controller1+2
    beq snes

    jsr fetchkey
    cmp #KEY_CRSR_UP
    beq up
    cmp #KEY_CRSR_DOWN
    beq down

    lda #JOY_PORT
    jmp joystick_read
snes:
    lda controller1
    ror ; ignore right
    ror ; ignore left
    ror ; down?
    bcc down
    ror ; up?
    bcc up
    ror ; start
    bcc button
    ror ; ignore select
    ror ; button Y
    bcc button
    ror ; button B
    bcc button
    lda controller1+1
    rol ; button A
    bcc button
    rol ; button X
    bcc button
    lda #$ff
    rts
down:
    lda #<(~JOY_DOWN)
    rts
up:
    lda #<(~JOY_UP)
    rts
button:
    lda #<(~JOY_FIRE)
    rts

animate_dinosaur:
    lda dinosaur_state
    bit #DINOSAUR_JUMP
    beq @l_ad_dead
    ldy sin_tab_offs
    lda #DINOSAUR_Y-10  ;cap
    sec
    sbc (sin_tab_ptr), y
    sta sprite_tab+4*4
    lda #DINOSAUR_Y
    sec
    sbc (sin_tab_ptr), y
    sta sprite_tab+0*4
    sta sprite_tab+2*4
    clc
    adc #16        ;+16px y offset for the lower sprites
    sta sprite_tab+1*4
    sta sprite_tab+3*4
    iny
    cmp #(DINOSAUR_Y+16) ;detect end of sin tab, accu must be dino y+16
    bne :+
    lda #DINOSAUR_RUN
    sta dinosaur_state
    ldy #0
:   sty sin_tab_offs
    SetVector dino_jump, ptr1
    bra update_sprite_data
@l_ad_dead:
    bit #DINOSAUR_DEAD
    beq  :+
    SetVector  dino_dead, ptr1
    bra  update_sprite_data
:   lda  frame_cnt
    and  #03
    beq  @l_ad_duck
    rts
@l_ad_duck:
    lda  dinosaur_state
    and  #DINOSAUR_DUCK
    beq  @l_ad_run
    lda  frame_cnt
    and  #$04
    beq  :+
    SetVector  dino_duck_1, ptr1
    bra update_sprite_data
:   SetVector  dino_duck_2, ptr1
    bra update_sprite_data
@l_ad_run:
    lda  frame_cnt
    and  #$04
    beq  :+
    SetVector  dino_run_1, ptr1
    bra update_sprite_data
:   SetVector  dino_run_2, ptr1

update_sprite_data:
    ldy  #0
    lda  (ptr1),y
    sta  sprite_tab+2+0*4
    iny
    lda  (ptr1),y
    sta  sprite_tab+2+1*4

    cmp #36 ;dino head shape ducked
    beq :+
    lda #DINOSAUR_X+10    ;DINOSAUR_Y-10, DINOSAUR_X+10
    sta  sprite_tab+1+4*4  ; cap sprite x
    lda #(255-10)
    bra :++
:   lda #DINOSAUR_X+16;   ;DINOSAUR_Y+4, DINOSAUR_X+16
    sta  sprite_tab+1+4*4  ; cap sprite x
    lda #4
:
    clc
    adc sprite_tab+0+0*4 ; y dino head
    sta sprite_tab+0+4*4 ; y cap sprite

    iny
    lda  (ptr1),y
    sta  sprite_tab+2+2*4
    iny
    lda  (ptr1),y
    sta  sprite_tab+2+3*4
    iny
    lda  (ptr1),y
    sta  sprite_tab+2+4*4
    rts

animate_enemy:
    lda  enemy_state
    bne  :+
    rts
:   ldx #$0
@l_ae_loop:
    lda sprite_tab_enemy+1,x
    sec
    sbc #PD_SPEED
    bcs @l_ae_attr2  ; no underrun, go on
    bit sprite_tab_enemy+3,x ;SPRITE_EC => bit 7
    bmi @l_ae_attr  ; ec set, do not add 32 px
    clc
    adc #EC_MAX_RIGHT_POS ; offset and EC enabled
    bra  @l_ae_attr
    jmp disable_pd

@l_ae_attr:
    tay
    lda sprite_tab_enemy+3,x
    eor #SPRITE_EC
    sta sprite_tab_enemy+3+4*0,x
    sta sprite_tab_enemy+3+4*1,x
    tya
@l_ae_attr2:
    sta  sprite_tab_enemy+1+4*0,x
    sta  sprite_tab_enemy+1+4*1,x
    cpx #$08
    beq :+
    ldx #$08
    bra @l_ae_loop

:   lda  frame_cnt
    and  #08
    beq  :+
    lda  #PD_PTR
    sta  sprite_tab_enemy+2
    lda  #PD_PTR+4
    sta  sprite_tab_enemy+2+1*4
    lda  #PD_PTR+8
    sta  sprite_tab_enemy+2+2*4
    lda  #PD_PTR+12
    sta  sprite_tab_enemy+2+3*4
    rts
:
    lda  #PD_PTR+16
    sta  sprite_tab_enemy+2
    lda  #PD_PTR+20
    sta  sprite_tab_enemy+2+1*4
    lda  #PD_PTR+24
    sta  sprite_tab_enemy+2+2*4
    lda  #PD_PTR+28
    sta  sprite_tab_enemy+2+3*4
    rts

animate_sky:
        stz _i
        stz _j
@l_as_loop:
        ldx _j
        lda sprite_tab_sky_trigger,x
        beq @move
        lda frame_cnt
        and #$01
        bne :+
        dec sprite_tab_sky_trigger,x
 :      lda #8
        jsr @next_x
        bra @next
@move:
        jsr @animate_sky_move
        jsr @animate_sky_move
        jsr @update_sprite_tab_sky_trigger

@next:  inc _j
        lda _j
        cmp #4 ; 4 clouds, 2 sprites each
        bne @l_as_loop
        rts
@animate_sky_move:
        ldx _i
        lda sprite_tab_sky+SPRITE_X,x
        bne :++
        lda sprite_tab_sky+SPRITE_C,x
        eor #SPRITE_EC
        sta sprite_tab_sky+SPRITE_C,x
        bmi :+
        lda #$ff
        bra :+++
:       lda #EC_MAX_RIGHT_POS
:       dec
:       sta sprite_tab_sky+SPRITE_X,x
        lda #4
@next_x:clc
        adc _i
        sta _i
        rts

@update_sprite_tab_sky_trigger:
        lda sprite_tab_sky+SPRITE_X,x
        cmp #16 ; 2nd sprite x behind left border
        bne :+
        lda sprite_tab_sky+SPRITE_C,x ; and EC set?
        bpl :+
        jsr rnd ; rnd trigger value
        ldx _j
        sta sprite_tab_sky_trigger,x
:       rts

game_isr:
    bit  a_vreg
    bpl  game_isr_exit

    save
;    lda  #Dark_Yellow
 ;   jsr  vdp_bgcolor

    lda  game_state
    and  #STATUS_PLAY
    beq  :+

    jsr  scroll_background
    jsr  animate_enemy
    jsr  animate_sky
    jsr  score_board
    jsr  action_handler
    jsr  detect_collision
    jsr  animate_dinosaur
    bra  @l_update_vram

:   jsr fetchkey
    cmp #$20   ; space ?
    beq @l_new_game
    cmp #KEY_ESCAPE
    bne :+
    lda #STATUS_EXIT
    tsb game_state
    bra @l_update_vram
:   jsr get_joy_status
    and #JOY_FIRE
    beq :+
    lda game_state
    and #(!STATUS_JOY_PRESSED)
    sta game_state
    bra @l_update_vram
:   lda  game_state
    and  #STATUS_JOY_PRESSED
    bne  @l_update_vram
@l_new_game:
    jsr new_game

@l_update_vram:
    jsr  update_vram
    inc  frame_cnt

    lda  #Black
    jsr  vdp_bgcolor

    restore
game_isr_exit:
    rti

disable_pd:
    stz  enemy_state
    lda  #PD_Y_OFF
    sta sprite_tab_enemy+4*0,x
    sta sprite_tab_enemy+4*1,x
    sta sprite_tab_enemy+4*2,x
    sta sprite_tab_enemy+4*3,x
    rts

enable_pd:
    inc  enemy_state
    ldx  #sprite_tab_enemy_init_end-sprite_tab_enemy_init-1
:   lda  sprite_tab_enemy_init, x
    sta sprite_tab_enemy,x
    dex
    bpl :-
    rts

new_game:
    jsr init_screen

    ldx #(sprite_tab_init_end-sprite_tab_init-1)
:   lda sprite_tab_init, x
    sta sprite_tab,x
    dex
    bpl :-

    vdp_sreg <(A_GX_SCR + (Y_OFS_GAME_OVER*32)), WRITE_ADDRESS + >(A_GX_SCR+(Y_OFS_GAME_OVER*32))
    lda  #CHAR_BLANK
    ldx #32*4
    jsr vdp_fills

    stz  dinosaur_state  ; run initialy
    stz  enemy_state

    jsr disable_pd

    lda #$05
    sta score_board_cnt
    stz sin_tab_offs
    stz level_script_ix
    stz frame_cnt
    stz level_bg_cnt
    SetVector level_bg_3, level_bg_ptr

    stz score_value
    stz score_value+1
    stz score_value+2

    lda #STATUS_PLAY
    sta game_state
    rts

update_highscore:
    lda score_value      ;set new highscore
    cmp score_value_high
    bcc @exit
    bne :+
    lda score_value+1
    cmp score_value_high+1
    bcc @exit
    bne :+
    lda score_value+2
    cmp score_value_high+2
    bcc @exit
    beq @exit
:
    lda score_value+2
    sta score_value_high+2
    lda score_value+1
    sta score_value_high+1
    lda score_value
    sta score_value_high

@save_highscore:
    lda #<filename
    ldx #>filename
    ldy #O_WRONLY
    jsr krn_fopen
    bcs @exit
    ldy #0
:   lda score_value_high,y
    jsr krn_write_byte
    bcs @exit
    iny
    cpy #3
    bne :-
    jsr krn_close
@exit:
    rts

score_board:
    dec  score_board_cnt  ;every 5 frames update score, which means 10 digits per second
    beq  :+
    rts
:   lda  #$05
    sta  score_board_cnt

    sed            ;add in decimal mode
    lda score_value+2
    clc
    adc  #$01
    sta score_value+2
    bcc :+
    adc score_value+1
    sta score_value+1
    bcc :+
    adc score_value
    sta score_value
:   cld
    rts

action_handler:
    jsr get_joy_status
    and #JOY_UP
    bne @short_jump
@up:
    lda dinosaur_state
    and #DINOSAUR_JUMP  ;only allow jump, if dinosaur is not jumping already
    bne @l_ah_exit
    lda #DINOSAUR_JUMP
    sta dinosaur_state
    SetVector sin_tab, sin_tab_ptr  ;long jump
    rts
@short_jump:
    lda sin_tab_offs  ;no joy/key pressed after 5 frames, switch to short jump
    cmp #5
    bne @l_ah_duck
    SetVector sin_tab_short, sin_tab_ptr
@l_ah_duck:
    lda dinosaur_state
    and #DINOSAUR_JUMP  ;only allow other direction, if dinosaur is not jumping already
    bne @l_ah_exit
    jsr get_joy_status
    and #JOY_DOWN
    bne @l_ah_run
    lda #DINOSAUR_DUCK
    sta dinosaur_state
    rts
@l_ah_run:
    lda #DINOSAUR_RUN
    sta dinosaur_state
@l_ah_exit:
    rts

load_highscore:
    lda #<filename
    ldx #>filename
    ldy #O_RDONLY
    jsr krn_fopen     ; X contains fd
    bcs @notfound    ; not found or other error, dont care...
    ldy #0
:   jsr krn_fread_byte
    bcs @eof
    sta score_value_high,y
    iny
    cpy #3
    bne :-
@eof:
    jmp krn_close
@notfound:
    stz score_value_high
    stz score_value_high+1
    stz score_value_high+2
    rts

init_vram:
    jsr isXmas
    bcc :+
    lda  #Dark_Red
    sta  sprite_tab_init+4*4+3
:
    vdp_sreg <A_GX_COL, WRITE_ADDRESS + >A_GX_COL  ;color vram
    lda #Light_Blue
    ldx #$20
    jsr vdp_fills

    vdp_sreg <A_GX_SCR, WRITE_ADDRESS + >A_GX_SCR
    ldx #$03
    lda #CHAR_BLANK          ;fill vram screen with blank
    jsr vdp_fill

    vdp_sreg <A_GX_PAT_1, WRITE_ADDRESS + >A_GX_PAT_1
    lda #<charset ; init 2 game charset with character set
    ldy #>charset
    ldx #$08
    jsr vdp_memcpy

    vdp_sreg <A_GX_PAT_2, WRITE_ADDRESS + >A_GX_PAT_2
    lda #<charset
    ldy #>charset
    ldx #$08
    jsr vdp_memcpy

    vdp_sreg <(A_GX_PAT_1+GAME_CHAR_OFFS), (WRITE_ADDRESS + >(A_GX_PAT_1+GAME_CHAR_OFFS))
    jsr isXmas
    lda #<game_chars    ; default game charset
    ldy #>game_chars
    bcc :+
    lda #<game_chars_xmas ; xmas game charset
    ldy #>game_chars_xmas
:   ldx #$03
    jsr vdp_memcpy

    vdp_sreg <(A_GX_PAT_2+GAME_CHAR_OFFS), WRITE_ADDRESS + >(A_GX_PAT_2+GAME_CHAR_OFFS)
    jsr isXmas
    lda #<game_chars_4px   ; 2nd default game charset with 4px offset
    ldy #>game_chars_4px
    bcc :+
    lda #<game_chars_4px_xmas
    ldy #>game_chars_4px_xmas
:   ldx #$03
    jsr vdp_memcpy

    vdp_sreg <A_SP_PAT, WRITE_ADDRESS + >A_SP_PAT
    lda #<sprites
    ldy #>sprites
    ldx #3        ; sprite patterns
    jsr vdp_memcpy
    lda #0
    ldx #32       ; empty sprite
    jsr vdp_fills

    SetVector text_game_label, ptr1
    lda #<(A_GX_SCR + (22*32))
    ldy #WRITE_ADDRESS + >(A_GX_SCR+(22*32))
    jmp vdp_print

update_vram:
    ;update sprite tab
    vdp_sreg <A_SP_ATR, WRITE_ADDRESS + >A_SP_ATR
    lda #<sprite_tab
    ldy #>sprite_tab
    ldx #sprite_tab_end-sprite_tab
    jsr vdp_memcpys

    ;score_board
    vdp_sreg <(A_GX_SCR + (1*32))+17, WRITE_ADDRESS + >(A_GX_SCR+(1*32)+17)
    ldx  #0
:   lda  text_score_board,x
    beq  :+
    vdp_wait_l 8
    sta a_vram
    inx
    bne :-
:
    lda  score_value_high
    jsr digit_out
    lda  score_value_high+1
    jsr digits_out
    lda  score_value_high+2
    jsr digits_out

    lda  #' '
    sta a_vram
    lda score_value
    jsr digit_out
    lda score_value+1
    jsr digits_out
    lda score_value+2
    jsr digits_out

    vdp_wait_l
    ;SetVector screen, addr      ;copy screen
    vdp_sreg <(A_GX_SCR + (16*32)), WRITE_ADDRESS + >(A_GX_SCR+(16*32))
    lda #<screen
    ldy #>screen
    ldx #32*4
    jmp vdp_memcpys

digits_out:
    pha
    lsr
    lsr
    lsr
    lsr
    ora  #'0'
    vdp_wait_l 18
    sta a_vram
    pla
digit_out:
    and #$0f
    ora  #'0'
    vdp_wait_l 10
    sta a_vram
    rts

rnd:
    lda seed
    beq doEor
    asl
    beq noEor ;if the input was $80, skip the EOR
    bcc noEor
doEor:
    eor #$1d
noEor:
    sta seed
    rts

.data
sprite_tab_enemy_init:
    .byte  PD_Y     ,PD_X,     PD_PTR+0*4, Dark_Red
    .byte  PD_Y+16  ,PD_X,     PD_PTR+1*4, Dark_Red
    .byte  PD_Y     ,PD_X+16,  PD_PTR+2*4, Dark_Red
    .byte  PD_Y+16  ,PD_X+16,  PD_PTR+3*4, Dark_Red
sprite_tab_enemy_init_end:
sprite_tab_init:
    .byte  DINOSAUR_Y     ,DINOSAUR_X+16  ,0    , dinosaur_color
    .byte  DINOSAUR_Y+16  ,DINOSAUR_X+16  ,4    , dinosaur_color
    .byte  DINOSAUR_Y     ,DINOSAUR_X     ,8    , dinosaur_color
    .byte  DINOSAUR_Y+16  ,DINOSAUR_X     ,28   , dinosaur_color
    .byte  DINOSAUR_Y-10  ,DINOSAUR_X+10  , dinosaur_cap, Transparent
sprite_tab_init_end:

sprite_tab:
    .res 5*4, 0
sprite_tab_enemy:
    .res 4*4, 0
sprite_tab_sky:
    .byte  15,200,48, White
    .byte  15,216,52, White
    .byte  25,100,48, White
    .byte  25,116,52, White
    .byte  41,30,48, White
    .byte  41,46,52, White
    .byte  57,70,48, White
    .byte  57,86,52, White
    .byte  SPRITE_OFF  ; end of sprite table
sprite_tab_end:

sprite_tab_sky_trigger:
    .byte 0,0,0,0

dino_run_1:
    .byte 0,4,8,12,60
dino_run_2:
    .byte 0,4,16,20,dinosaur_cap
dino_duck_1:
    .byte sprite_empty,36,sprite_empty,40,60
dino_duck_2:
    .byte sprite_empty,36,sprite_empty,44,dinosaur_cap
dino_jump:
    .byte 0,4,8,28,60
dino_dead:
    .byte 32,4,8,28,dinosaur_cap

text_game_label:
    .asciiz " Verbindung zum Internet konnte  nicht hergestellt werden."
text_game_over:
    .asciiz "GAME OVER"
text_game_reload_1:
    .byte 211,213,215,0
text_game_reload_2:
    .byte 212,214,216,0

text_score_board:
    .asciiz "HI "

level_bg_1:; cactus
    .byte 3
    .byte 128, 129, 130, 131
    .byte 132, 133, 134, 135
    .byte 136, 137, 138, 139
level_bg_2: ;3 cacti
    .byte 5
    .byte 210, 140, 141, 142
    .byte 210, 143, 144, 145
    .byte 210, 146, 147, 148
    .byte 210, 149, 150, 151
    .byte 210, 152, 153, 154
level_bg_3: ;4 cacti
    .byte 7
    .byte 128, 129, 130, 131
    .byte 155, 156, 157, 158
    .byte 159, 160, 161, 162
    .byte 163, 164, 165, 166
    .byte 167, 168, 169, 170
    .byte 171, 172, 173, 174
    .byte 175, 176, 177, 178
level_bg_4: ;2 cacti
    .byte 5
    .byte 179, 180, 181, 182
    .byte 183, 184, 185, 186
    .byte 187, 188, 189, 190
    .byte 191, 192, 193, 194
    .byte 195, 196, 197, 198
level_bg_5: ;hills
    .byte 5
    .byte 210, 210, 199, 200
    .byte 210, 210, 201, 202
    .byte 210, 210, 210, 203
    .byte 210, 210, 210, 204
    .byte 210, 210, 210, 205
level_bg_6: ;desert
    .byte 4
    .byte 210, 210, 210, 206
    .byte 210, 210, 210, 207
    .byte 210, 210, 210, 208
    .byte 210, 210, 210, 209

sin_tab:
    .byte  5
    .byte  10
    .byte  14
    .byte  19
    .byte  24
    .byte  28
    .byte  32
    .byte  36
    .byte  40
    .byte  43
    .byte  46
    .byte  48
    .byte  51
    .byte  53
    .byte  54
    .byte  55
    .byte  56
    .byte  56
    .byte  56
    .byte  55
    .byte  54
    .byte  53
    .byte  51
    .byte  48
    .byte  46
    .byte  43
    .byte  40
    .byte  36
    .byte  32
    .byte  28
    .byte  24
    .byte  19
    .byte  14
    .byte  10
    .byte  5
    .byte  0
    ;PI = 3.14159265358979323846
    ;  .byte sin(float(.i) * 5 * PI/180)*56 + 0.5
sin_tab_short:
    .byte  6
    .byte  12
    .byte  18
    .byte  24
    .byte  29
    .byte  34
    .byte  38
    .byte  42
    .byte  44
    .byte  46
    .byte  48
    .byte  48
    .byte  48
    .byte  46
    .byte  44
    .byte  42
    .byte  38
    .byte  34
    .byte  29
    .byte  24
    .byte  18
    .byte  12
    .byte  6
    .byte  0

sprites:
.include "dinosaur.sprites.res"
.include "dinosaur.sprites.pterodactyl.res"

game_chars:
.include "dinosaur.chars.1.res"
.include "dinosaur.chars.2.res"
.include "dinosaur.chars.3.res"
.include "dinosaur.chars.4.res"
.include "dinosaur.chars.5.res"
.include "dinosaur.chars.6.res"
.include "dinosaur.chars.reload.res"

game_chars_4px:
.include "dinosaur.chars.1.4px.res"
.include "dinosaur.chars.2.4px.res"
.include "dinosaur.chars.3.4px.res"
.include "dinosaur.chars.4.4px.res"
.include "dinosaur.chars.5.4px.res"
.include "dinosaur.chars.6.4px.res"
.include "dinosaur.chars.reload.res"

game_chars_xmas:
.include "dinosaur.chars.1.xmas.res"
.include "dinosaur.chars.2.xmas.res"
.include "dinosaur.chars.3.xmas.res"
.include "dinosaur.chars.4.xmas.res"
.include "dinosaur.chars.5.res"
.include "dinosaur.chars.6.res"
.include "dinosaur.chars.reload.res"

game_chars_4px_xmas:
.include "dinosaur.chars.1.4px.xmas.res"
.include "dinosaur.chars.2.4px.xmas.res"
.include "dinosaur.chars.3.4px.xmas.res"
.include "dinosaur.chars.4.4px.xmas.res"
.include "dinosaur.chars.5.4px.res"
.include "dinosaur.chars.6.4px.res"
.include "dinosaur.chars.reload.res"

filename:  .asciiz "DINOSAUR.HI"

charset:
.include "ati_8x8.h.asm"

.bss
enemy_state:      .res 1
seed:             .res 1
game_state:       .res 1
dinosaur_state:   .res 1
score_board_cnt:  .res 1
sin_tab_offs:     .res 1
level_bg_cnt:     .res 1
level_script_ix:  .res 1
score_value_high:       .res 3
score_value:            .res 3
frame_cnt:              .res 1
save_isr:               .res 2
