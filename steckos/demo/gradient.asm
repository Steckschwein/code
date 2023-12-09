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

appstart

.zeropage

.bss
rline:			.res 1
frame_cnt: 		.res 1
script_state:	.res 1
save_isr:		.res 2
rbar_y: .res 1
rbar_colors_ix:	.res 1

PAL_COLOR = 0;

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
	jsr krn_getkey
	cmp #KEY_ESCAPE
	bne :-

	sei
	copypointer save_isr, $fffe
	cli

	jsr krn_textui_init
	jmp (retvec)

init:
	; write rline into the interrupt line register #19
	; to generate an interrupt each time raster line is being scanned
	lda #1
	sta rbar_y
	sta rline
	ldy #v_reg19
	jsr vdp_set_sreg

	lda #<vdp_init_bytes
	ldy #>vdp_init_bytes
	ldx #(vdp_init_bytes_end-vdp_init_bytes)-1
	jsr vdp_init_reg

	vdp_sreg PAL_COLOR, v_reg16 ;

	bit a_vreg ; ack pending int if any
	vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical, we avoid setup status register at isr entry set to S#1 per default
	vdp_wait_s
	bit a_vreg

	stz frame_cnt
	stz rbar_colors_ix
	stz script_state

	rts

isr:
	save

	lda a_vreg	; check bit 0 of S#1
	ror
	bcc @is_vblank

	ldx rbar_colors_ix
	lda _gradient+0, x
	sta a_vregpal
	vdp_wait_s
	lda _gradient+1, x
	sta a_vregpal

	lda rline
	inc
	inc
	inx
	inx
	cpx #(_gradient_end-_gradient)
	bne @set_hline
	ldx #0 ; reset color ix
	lda rbar_y ; init
@set_hline:
	stx rbar_colors_ix

	sta rline
	ldy #v_reg19
	jsr vdp_set_sreg

	vdp_sreg PAL_COLOR, v_reg16 ;

	lda #PAL_COLOR
	jsr vdp_bgcolor

	bra @exit

@is_vblank:
 	vdp_sreg 0, v_reg15			; 0 - set status register selection to S#0
 	vdp_wait_s
	bit a_vreg ; Check VDP interrupt. IRQ is acknowledged by reading.
 	bpl @is_vblank_end  ; VDP IRQ flag set?

	inc frame_cnt

	lda #Black
	jsr vdp_bgcolor

@is_vblank_end:
	vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical (flicker), so we setup status S#1 beforehand

	jsr fetchkey
@exit:

	lda #$80
	sta script_state

	restore
	rti

.data

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

_gradient:
vdp_pal_rgb $0000ff
vdp_pal_rgb $0804ff
vdp_pal_rgb $1008ff
vdp_pal_rgb $180cff
vdp_pal_rgb $2010ff
vdp_pal_rgb $2914ff
vdp_pal_rgb $3118fe
vdp_pal_rgb $391cff
vdp_pal_rgb $4121ff
vdp_pal_rgb $4a25ff
vdp_pal_rgb $5229ff
vdp_pal_rgb $5a2dff
vdp_pal_rgb $6231ff
vdp_pal_rgb $6a35ff
vdp_pal_rgb $7339fe
vdp_pal_rgb $7b3dff
vdp_pal_rgb $8342ff
vdp_pal_rgb $8b46ff
vdp_pal_rgb $944aff
vdp_pal_rgb $9c4eff
vdp_pal_rgb $a452ff
vdp_pal_rgb $ac56ff
vdp_pal_rgb $b45aff
vdp_pal_rgb $bd5eff
vdp_pal_rgb $c563ff
vdp_pal_rgb $cd67ff
vdp_pal_rgb $d56bff
vdp_pal_rgb $de6fff
vdp_pal_rgb $e673ff
vdp_pal_rgb $ee77ff
vdp_pal_rgb $f67bff
vdp_pal_rgb $ff80ff
_gradient_end:
