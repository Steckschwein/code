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
.include "vdp.inc"
.include "ym3812.inc"
.include "rtc.inc"
.include "common.inc"
.include "zeropage.inc"
.include "keyboard.inc"
.include "appstart.inc"

.autoimport

.export d00file

appstart $1000

.zeropage
p_script: .res 2
sin_tab_ptr:     .res 2

.bss
rline:      .res 1
frame_cnt:     .res 1
script_state:  .res 1
sound_state:  .res 1
save_isr:    .res 2
sin_tab_offs:    .res 1
rbar_y: .res 1
rbar_colors: .res 16
rbar_colors_ix:  .res 1
rbar_sintab_ix:  .res 1
blend_rbar_offset: .res 1
scroll_x:      .res 1
text_color:  .res 1
text_scroll_buf:  .res 2*32
char_ix:  .res 1
pause_cnt: .res 1

.code
  sei
  jsr krn_textui_disable

  copypointer SYS_VECTOR_IRQ, save_isr
  SetVector isr, SYS_VECTOR_IRQ

  jsr init

  cli

@loop:
  bit sound_state
  bvc :+
  lda sound_state
  and #$3f
  beq :+
  jsr jch_fm_play
  dec sound_state
:
  lda script_state
  bpl @loop
  and #$7f
  sta script_state

  lda text_color  ; text color ram update offload, to avoid flicker
  beq :+
  ldy #(WRITE_ADDRESS | (>(ADDRESS_GFX3_COLOR+$000) & $3f))
  jsr _update_text_color
  ldy #(WRITE_ADDRESS | (>(ADDRESS_GFX3_COLOR+$200) & $3f))
  jsr _update_text_color
  ldy #(WRITE_ADDRESS | (>(ADDRESS_GFX3_COLOR+$400) & $3f))
  jsr _update_text_color
  ldy #(WRITE_ADDRESS | (>(ADDRESS_GFX3_COLOR+$600) & $3f))
  jsr _update_text_color
  stz text_color  ; reset

: jsr fetchkey
  bcc @loop
  cmp #KEY_ESCAPE
  bne @loop

  sei

  jsr init

  copypointer save_isr, SYS_VECTOR_IRQ
  vdp_sreg v_reg25_wait, v_reg25
  vdp_sreg 0, v_reg15
  jsr krn_textui_init
  jsr krn_textui_enable
  cli
  jmp (retvec)


_update_text_color:
  sei
  lda #<ADDRESS_GFX3_COLOR
  vdp_sreg
  lda text_color
  ldx #$2    ;$800 byte color map sufficient
  jsr vdp_fill
  cli
  rts

init:
  ; write rline into the interrupt line register #19
  ; to generate an interrupt each time raster line is being scanned
  lda #176
  sta rbar_y
  sta rline
  ldy #v_reg19
  vdp_sreg

  vdp_vram_w ADDRESS_GFX3_PATTERN
  ldx #8
  lda #<font
  ldy #>font
  jsr vdp_memcpy

  vdp_vram_w ADDRESS_GFX3_SCREEN
  lda #$20
  ldx #4
  jsr vdp_fill

  lda #<vdp_init_bytes
  ldy #>vdp_init_bytes
  ldx #(vdp_init_bytes_end-vdp_init_bytes)-1
  jsr vdp_init_reg

  vdp_sreg 0, v_reg23
  vdp_sreg v_reg25_wait, v_reg25

  lda #.sizeof(rbar_colors)>>1
  sta blend_rbar_offset

  ldx #.sizeof(rbar_colors)-1
  lda #Black
:  sta rbar_colors,x
  dex
  bpl :-

  ldx #.sizeof(text_scroll_buf)
  lda #' '
:  sta text_scroll_buf,x
  dex
  bpl :-

  lda #4
  sta rbar_sintab_ix
  stz scroll_x
  stz char_ix
  stz script_state
  SetVector script, p_script

  bit a_vreg ; ack pending int if any
  vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical, we avoid setup status register at isr entry set to S#1 per default
  vdp_wait_s
  bit a_vreg

  stz frame_cnt
  stz pause_cnt
  stz text_color
  stz sound_state

  jsr opl2_init ; reset

  rts

isr:
  save

  lda a_vreg  ; check bit 0 of S#1
  ror
  bcc @is_vblank

  ldx rbar_colors_ix
  lda rbar_colors,x
  sta a_vreg
  lda #v_reg7
  vdp_wait_s 2
  sta a_vreg
  lda #$40
  trb sound_state
  lda rline
  inc
  inx
  cpx #<.sizeof(rbar_colors)
  bne @set_hline
  lda #$40
  tsb sound_state
  lda #$80
  tsb script_state ; set flag, raster bar end
  ldx #0 ; reset color ix
  lda rbar_y ; init
@set_hline:
  stx rbar_colors_ix
  sta rline
  ldy #v_reg19
  vdp_sreg
  jmp @opl_ack

@is_vblank:
    vdp_sreg 0, v_reg15      ; 0 - set status register selection to S#0
    vdp_wait_s
    bit a_vreg ; Check VDP interrupt. IRQ is acknowledged by reading.
    bpl @is_vblank_end  ; VDP IRQ flag set?

    inc frame_cnt
    jsr script_step

    vdp_vram_w ADDRESS_GFX3_SCREEN+11*32
    ldx #2*32
    lda #<text_scroll_buf
    ldy #>text_scroll_buf
    jsr vdp_memcpys

@is_vblank_end:
    vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical (flicker), so we setup status S#1 already

@opl_ack:
    bit opl_stat
    bpl @exit
  ;  lda #Cyan<<4|Cyan
 ;   jsr vdp_bgcolor
    jsr opl2_delay_data
		ldx #opl2_reg_ctrl
		lda #$80	; ack IRQ
		jsr opl2_reg_write
    inc sound_state

    bit sound_state
    bpl @exit
    jsr sound_fade_off

@exit:
;    lda #Black<<4|Black
;    jsr vdp_bgcolor
    restore
    rti

nexttoken:
    inc16 p_script
    lda (p_script)
    rts

script_step:
  lda pause_cnt ; in pause?
  beq :+
  dec pause_cnt
  rts
:
  lda (p_script)
  cmp #SCRIPT_TEXT
  bne :+
  jsr script_text
  jmp @next
:  cmp #SCRIPT_PAUSE
  bne :+
  jsr nexttoken
  sta pause_cnt
  jmp @next
:
  cmp #SCRIPT_R25
  bne :+
  vdp_sreg v_reg25_msk | v_reg25_wait, v_reg25
  jmp @next
:
  cmp #SCRIPT_RBAR_MOVE
  bne :+
  lda rbar_y
  cmp #TEXT_Y_OFFSET
  bne @rbar_move
  lda #$10
  tsb script_state
  jmp @next
@rbar_move:
  dec rbar_y
  rts
:
  cmp #SCRIPT_RBAR_ON
  bne :+
  lda blend_rbar_offset
  bmi @next
  jsr blend_rbar
  dec blend_rbar_offset
  rts
:
  cmp #SCRIPT_RBAR_OFF
  bne :+
  lda blend_rbar_offset
  cmp #.sizeof(rbar_colors)>>1-1
  beq @next
  inc blend_rbar_offset
  jmp blend_rbar_off
:
  cmp #SCRIPT_RBAR_SINE
  bne :+
  jsr script_rbar_sine
  jmp @next
:
  cmp #SCRIPT_TEXT_COLOR
  bne :+
  jsr nexttoken
  sta text_color
  bra @next
:
  cmp #SCRIPT_SOUND_ON
  bne :+
  jsr sound_init
  bra @next
:
  cmp #SCRIPT_SOUND_FADE_OFF
  bne :+
  lda #$80
  sta sound_state
  bra @next
:
  cmp #SCRIPT_RESET
  bne :+
  jmp init
:  cmp #SCRIPT_SCROLL_SINE
  bne :+
  lda script_state
  eor #$20
  bra @script_state
:  cmp #SCRIPT_SCROLL
  bne @loop
  lda #07
  trb script_state
  jsr nexttoken
  and #$07
  ora script_state
@script_state:
  sta script_state
@next:
  inc16 p_script
@loop:
  lda script_state
  and #$07
  beq @1

  tay ; scroll y times
@0:
  jsr scroll_text ;scroll state times
  dey
  bne @0
@1:
  lda script_state
  and #8 ; rbar sine on ?
  bne :+
  lda script_state
  and #$10
  beq @2
  lda rbar_y ; if sine is toggled off, check if we are at center
  cmp #TEXT_Y_OFFSET
  beq @2
:  jsr sin_tab_value
  clc
  adc #TEXT_Y_OFFSET
  sta rbar_y
@2:
  lda script_state
  and #$20
  beq @exit
  jsr sin_tab_value
  asl
  ldy #v_reg23
  vdp_sreg
@exit:
  rts

sin_tab_value:
  ldy rbar_sintab_ix
  lda sin_tab_short,y
  iny
  cpy #(sin_tab_short_end-sin_tab_short)
  bne :+
  ldy #0
:  sty rbar_sintab_ix
  rts

script_text:
  ldx #0
:  jsr nexttoken
  sta text_scroll_buf+0*32+0,x
  clc
  adc #$40
  sta text_scroll_buf+0*32+1,x
  adc #$40
  sta text_scroll_buf+1*32+0,x
  adc #$40
  sta text_scroll_buf+1*32+1,x
  inx
  inx
  cpx #32
  bne :-
  rts

scroll_text:
  dec scroll_x
  bpl @exit
  lda #7
  sta scroll_x

  ldx #0
:  lda text_scroll_buf+0*32+1,x
  sta text_scroll_buf+0*32+0,x
  lda text_scroll_buf+1*32+1,x
  sta text_scroll_buf+1*32+0,x
  inx
  cpx #31
  bne :-
  lda (p_script)
  clc
  adc char_ix
  sta text_scroll_buf+0*32+31
  adc #$80
  sta text_scroll_buf+1*32+31

  lda char_ix
  eor #$40
  sta char_ix
  bne @exit
  inc16 p_script
@exit:
  lda scroll_x
  sta a_vreg
  vdp_wait_s
  lda #v_reg27
  sta a_vreg
  rts

script_rbar_sine:
  lda script_state
  eor #8
  sta script_state
  rts

blend_rbar_off:
  ldx blend_rbar_offset
  lda #Black
  sta rbar_colors,x
  lda #.sizeof(rbar_colors)>>1-1
  sec
  sbc blend_rbar_offset
  tax
  lda #Black
  sta rbar_colors+7,x
  rts

blend_rbar:
  ldx blend_rbar_offset
  lda raster_bar_colors_init,x
  sta rbar_colors,x
  lda #.sizeof(rbar_colors)>>1-1
  sec
  sbc blend_rbar_offset
  tax
  lda raster_bar_colors_init+7,x
  sta rbar_colors+7,x
  rts

sound_fade_off:
    lda fm_master_volume
    cmp #OPL_VOLUME_MIN
    bne :+
    stz sound_state
    dec
:   inc
    sta fm_master_volume
:   rts

sound_init:
    jsr jch_fm_init
    lda #OPL_VOLUME_MAX
    sta fm_master_volume
		freq=70
		t2cycles=320
		lda #($ff-(1000000 / freq / t2cycles))	; 1s => 1.000.000µs / 70 (Hz) / 320µs = counter value => timer is incremental, irq on overflow so we have to $ff - counter value
  	ldx #opl2_reg_t2	; t2 timer value
    jsr opl2_reg_write
		ldx #opl2_reg_ctrl ;reset
		lda #$80
		jsr opl2_reg_write
		lda #$42 ; t1 disable, t2 enable and start
		jmp opl2_reg_write

.data
font:
  .include "2x2_font.inc"

d00file:
  .incbin "PJO_INS8.D00"

.repeat 32, n
  .charmap $40+n, n
.endrep

SCRIPT_RESET = $80
SCRIPT_PAUSE = $81
SCRIPT_TEXT = $82
SCRIPT_SCROLL = $83
SCRIPT_SCROLL_SINE = $84
SCRIPT_R25 = $85
SCRIPT_RBAR_ON = $86
SCRIPT_RBAR_OFF = $87
SCRIPT_RBAR_MOVE = $88
SCRIPT_RBAR_SINE = $89
SCRIPT_TEXT_COLOR = $8a
SCRIPT_SOUND_ON = $8b
SCRIPT_SOUND_FADE_OFF = $8c

TEXT_Y_OFFSET=87

fps=50
_1s = 1*fps
_2s = 2*fps
_3s = 3*fps
_4s = 4*fps
_5s = 5*fps

script:
.ifdef DEBUG
  ;.byte SCRIPT_RBAR_ON, SCRIPT_RBAR_MOVE, SCRIPT_SCROLL, 4
  ;.byte SCRIPT_TEXT_COLOR, Transparent<<4|Black, SCRIPT_SCROLL_SINE
  .byte SCRIPT_SOUND_ON
  .byte SCRIPT_TEXT_COLOR, Gray<<4|Transparent, SCRIPT_RBAR_ON, SCRIPT_RBAR_MOVE, SCRIPT_SCROLL, 2, SCRIPT_PAUSE, 1
.endif
.ifndef DEBUG
  .byte SCRIPT_TEXT_COLOR, Gray<<4|Transparent
  .byte SCRIPT_TEXT, "  STECKSCHWEIN  ", SCRIPT_PAUSE, _3s
  .byte SCRIPT_SOUND_ON
  .byte SCRIPT_TEXT, "... OH, NICE    ", SCRIPT_PAUSE, _2s
  .byte SCRIPT_TEXT, "A 2X2 CHAR FONT ", SCRIPT_PAUSE, _2s
  .byte SCRIPT_TEXT, "BORING...       ", SCRIPT_PAUSE, _2s
  .byte SCRIPT_TEXT, "LET'S SCROLL IT!", SCRIPT_PAUSE, _1s, SCRIPT_SCROLL, 1, " "
  .byte "        NICE... BUT YOU MAY RECOGNIZE A LITTLE FLICKER AT THE LEFT BORDER. LOOKS A LITTLE ODD! "
  .byte "SORRY, BUT THIS IS THE DEFAULT SOFT SCROLL BEHAVIOR OF THE V9938 CHIP. "
  .byte "BUT HEY, WE HAVE A V9958 HERE, SO LET'S SET THE MSK BIT IN THE VDP R#25"
  .byte SCRIPT_R25, "        ...MUCH BETTER NOW!           "
  .byte "LET'S GO FASTER ...", SCRIPT_SCROLL, 2
  .byte "YEAH, 2PX/FRAME ...", SCRIPT_SCROLL, 4
  .byte "AND NOW 4PX/FRAME ... ", SCRIPT_SCROLL, 4
  .byte "SIMPLE THING WITH THE R#27 REGISTER OF THE V9958         "
  .byte SCRIPT_SCROLL, 2, "OK, 2PX IS FAST ENOUGH.                ", SCRIPT_PAUSE, _3s
  .byte SCRIPT_RBAR_ON
  .byte "OHO... GOOD OLD RASTER BAR ;)  ", SCRIPT_PAUSE, _5s
  .byte "WE USE THE VDP R#19 HLINE INTERRUPT REGISTER HERE...             "
  .byte "I THINK WE SHOULD MOVE THEM A LITTLE HIGHER.           "
  .byte "SAME HEIGHT AS THE TEXT ", SCRIPT_SCROLL, 2, "WOULD BE NICE!                 ", SCRIPT_RBAR_MOVE, SCRIPT_TEXT_COLOR, Black<<4|Transparent, SCRIPT_SCROLL, 4
  .byte "THX!       ", SCRIPT_PAUSE, _3s, SCRIPT_SCROLL, 2
  .byte "WE JUST CHANGED THE VDP COLOR RAM TO BLACK FOR BETTER READABILITY.                ", SCRIPT_SCROLL, 2
.endif
  .byte "HEY, LET'S TRY TO INVERT THE COLORS. WE CAN SET THE CHAR COLOR TO TRANSPARENT."
  .byte SCRIPT_TEXT_COLOR, Transparent<<4|Black, "   ", SCRIPT_PAUSE, _1s
  .byte "NOW WE CAN SEE THE BACKGROUND COLORS SET BY THE RASTER BAR AS CHAR COLOR :)  ", SCRIPT_PAUSE, _3s
  .byte SCRIPT_SCROLL, 1, "      ", SCRIPT_SCROLL, 2, "          "
  .byte "WE SHOULD ADD A SINE TABLE AND MODIFY THE RASTER BAR'S Y OFFSET ON EACH FRAME.                 "
  .byte SCRIPT_RBAR_SINE, "OK, COOL, LOOKS VERY NICE... LIKE AN INTRO BACK FROM THE 80'S                "
  .byte "OK, LET'S STOP HERE...        ", SCRIPT_RBAR_SINE
  .byte "MAYBE WE CAN SCROLL THE ENTIRE SCREEN BY USING THE VERTICAL OFFSET REGISTER R#23, "
  .byte "AVAILABLE IN THE V9938 ALREADY.                "
  .byte "        ", SCRIPT_SCROLL_SINE
  .byte "SEEMS TO WORK...", SCRIPT_SCROLL, 1, "        ", SCRIPT_SCROLL, 2, "        "
  .byte "SO FAR.                 ", SCRIPT_SCROLL_SINE, SCRIPT_SCROLL, 1, "+!+BYE+!+"
  .byte SCRIPT_SCROLL, 2, "  ", SCRIPT_SCROLL, 4, "                ", SCRIPT_SCROLL, 1, "TO BE CONTINUED...                "
  .byte $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
  .byte SCRIPT_PAUSE, _3s, SCRIPT_RBAR_OFF
  .byte SCRIPT_SOUND_FADE_OFF
  .byte SCRIPT_PAUSE, _5s, SCRIPT_PAUSE, _5s, SCRIPT_PAUSE, _5s, SCRIPT_PAUSE, _5s, SCRIPT_PAUSE, _5s, SCRIPT_PAUSE, _5s, SCRIPT_RESET

vdp_init_bytes:  ; vdp init table - MODE G3
      .byte v_reg0_m4 | v_reg0_IE1
      .byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
      .byte >(ADDRESS_GFX3_SCREEN>>2)       ; name table (screen)
      .byte >(ADDRESS_GFX3_COLOR<<2)  | $1f  ; $1f - color table with $800 values, each pattern with 8 colors (per line)
      .byte  >(ADDRESS_GFX3_PATTERN>>3)    ; pattern table
      .byte  >(ADDRESS_GFX3_SPRITE<<1) | $07 ; sprite attribute table => $07 -> see V9938_MSX-Video_Technical_Data_Book_Aug85.pdf S.93
      .byte  >(ADDRESS_GFX3_SPRITE_PATTERN>>3)
      .byte  Black
      .byte v_reg8_VR | v_reg8_SPD  ; VR - 64k VRAM TODO set per define
vdp_init_bytes_end:

raster_bar_colors_init:
  .byte Magenta
  .byte Dark_Red
  .byte  Medium_Red
  .byte  Light_Red
  .byte  Dark_Yellow
  .byte  Light_Yellow
  .byte  White
  .byte  White
  .byte  White
  .byte  Light_Yellow
  .byte  Dark_Yellow
  .byte  Light_Red
  .byte  Medium_Red
  .byte Dark_Red
  .byte Magenta
  .byte Black
raster_bar_colors_init_end:

sin_tab_short:
.byte 244
.byte 246
.byte 248
.byte 250
.byte 252
.byte 254
.byte 0
.byte 2
.byte 3
.byte 5
.byte 6
.byte 8
.byte 9
.byte 10
.byte 11
.byte 11
.byte 12
.byte 12
.byte 12
.byte 12
.byte 12
.byte 11
.byte 11
.byte 10
.byte 9
.byte 8
.byte 6
.byte 5
.byte 3
.byte 2
.byte 0
.byte 254
.byte 252
.byte 250
.byte 248
.byte 246
.byte 244
.byte 244
sin_tab_short_end: