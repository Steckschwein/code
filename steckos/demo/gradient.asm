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
.include "common.inc"
.include "zeropage.inc"
.include "keyboard.inc"
.include "appstart.inc"

.autoimport

appstart $1000

.zeropage
p_script: .res 2
sin_tab_ptr: 		.res 2

.bss
rline:			.res 1
frame_cnt: 		.res 1
script_state:	.res 1
save_isr:		.res 2
sin_tab_offs:		.res 1
rbar_y: .res 1
rbar_colors: .res 16
rbar_colors_ix:	.res 1
rbar_sintab_ix:	.res 1
blend_rbar_offset: .res 1
scroll_x:			.res 1
text_scroll_buf:	.res 2*32
char_ix:	.res 1
pause_cnt: .res 1

.code
	sei
	jsr krn_textui_disable

	copypointer $fffe, save_isr
	SetVector isr, $fffe

	jsr init

	cli

:	lda script_state
	bpl :-
	and #$7f
	sta script_state
	jsr fetchkey
	cmp #KEY_ESCAPE
	bne :-

	sei
	copypointer save_isr, $fffe
	cli

	vdp_sreg v_reg25_wait, v_reg25
	jsr krn_textui_init
	jsr krn_textui_enable
	jmp (retvec)


init:
	; write rline into the interrupt line register #19
	; to generate an interrupt each time raster line is being scanned
	lda #176
	sta rbar_y
	sta rline
	ldy #v_reg19
	vdp_sreg

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
:	sta rbar_colors,x
	dex
	bpl :-

	bit a_vreg ; ack pending int if any
	vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical, we avoid setup status register at isr entry set to S#1 per default
	vdp_wait_s
	bit a_vreg

	stz frame_cnt

	rts

isr:
	save

	lda a_vreg	; check bit 0 of S#1
	ror
	bcc @is_vblank

	ldx rbar_colors_ix
	lda rbar_colors,x
	sta a_vreg
	lda #v_reg7
	vdp_wait_s 2
	sta a_vreg
	lda rline
	inc
	inx
	cpx #<.sizeof(rbar_colors)
	bne @set_hline
	lda #$80
	tsb script_state ; set flag, raster bar end
	ldx #0 ; reset color ix
	lda rbar_y ; init
@set_hline:
	stx rbar_colors_ix
	sta rline
	ldy #v_reg19
	vdp_sreg
	bra @exit

@is_vblank:
 	vdp_sreg 0, v_reg15			; 0 - set status register selection to S#0
 	vdp_wait_s
	bit a_vreg ; Check VDP interrupt. IRQ is acknowledged by reading.
 	bpl @is_vblank_end  ; VDP IRQ flag set?

	inc frame_cnt

@is_vblank_end:
	vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical (flicker), so we setup status S#1 already

@exit:
	restore
	rti

.data

fps=50
_1s = 1*fps
_2s = 2*fps
_3s = 3*fps
_4s = 4*fps
_5s = 5*fps

vdp_init_bytes:	; vdp init table - MODE G3
			.byte v_reg0_m4 | v_reg0_IE1
			.byte v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
			.byte >(ADDRESS_GFX3_SCREEN>>2)		 	; name table (screen)
			.byte >(ADDRESS_GFX3_COLOR<<2)  | $1f	; $1f - color table with $800 values, each pattern with 8 colors (per line)
			.byte	>(ADDRESS_GFX3_PATTERN>>3)		; pattern table
			.byte	>(ADDRESS_GFX3_SPRITE<<1) | $07 ; sprite attribute table => $07 -> see V9938_MSX-Video_Technical_Data_Book_Aug85.pdf S.93
			.byte	>(ADDRESS_GFX3_SPRITE_PATTERN>>3)
			.byte	Black
			.byte v_reg8_VR | v_reg8_SPD	; VR - 64k VRAM TODO set per define
vdp_init_bytes_end:

raster_bar_colors_init:
	.byte Magenta
	.byte Dark_Red
	.byte	Medium_Red
	.byte	Light_Red
	.byte	Dark_Yellow
	.byte	Light_Yellow
	.byte	White
	.byte	White
	.byte	White
	.byte	Light_Yellow
	.byte	Dark_Yellow
	.byte	Light_Red
	.byte	Medium_Red
	.byte Dark_Red
	.byte Magenta
	.byte Black
raster_bar_colors_init_end:
