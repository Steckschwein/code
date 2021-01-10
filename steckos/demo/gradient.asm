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
	jsr fetchkey
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
vdp_pal_rgb $081cbd
vdp_pal_rgb $0f20be
vdp_pal_rgb $1624c0
vdp_pal_rgb $1e28c2
vdp_pal_rgb $252cc3
vdp_pal_rgb $2d30c5
vdp_pal_rgb $3434c7
vdp_pal_rgb $3c39c9
vdp_pal_rgb $433dca
vdp_pal_rgb $4b41cc
vdp_pal_rgb $5245ce
vdp_pal_rgb $5949d0
vdp_pal_rgb $614dd1
vdp_pal_rgb $6852d3
vdp_pal_rgb $7056d5
vdp_pal_rgb $775ad7
vdp_pal_rgb $7f5ed8
vdp_pal_rgb $8662da
vdp_pal_rgb $8e66dc
vdp_pal_rgb $956bde
vdp_pal_rgb $9d6fdf
vdp_pal_rgb $a473e1
vdp_pal_rgb $ab77e3
vdp_pal_rgb $b37be5
vdp_pal_rgb $ba7fe6
vdp_pal_rgb $c284e8
vdp_pal_rgb $c988ea
vdp_pal_rgb $d18cec
vdp_pal_rgb $d890ed
vdp_pal_rgb $e094ef
vdp_pal_rgb $e798f1
vdp_pal_rgb $ef9df3
_gradient_end:

vdp_pal_rgb $081cbd
vdp_pal_rgb $0a1dbd
vdp_pal_rgb $0c1ebe
vdp_pal_rgb $0f1fbe
vdp_pal_rgb $1121bf
vdp_pal_rgb $1322bf
vdp_pal_rgb $1623c0
vdp_pal_rgb $1825c0
vdp_pal_rgb $1a26c1
vdp_pal_rgb $1d27c1
vdp_pal_rgb $1f29c2
vdp_pal_rgb $212ac3
vdp_pal_rgb $242bc3
vdp_pal_rgb $262cc4
vdp_pal_rgb $282ec4
vdp_pal_rgb $2b2fc5
vdp_pal_rgb $2d30c5
vdp_pal_rgb $2f32c6
vdp_pal_rgb $3233c6
vdp_pal_rgb $3434c7
vdp_pal_rgb $3636c7
vdp_pal_rgb $3937c8
vdp_pal_rgb $3b38c9
vdp_pal_rgb $3d39c9
vdp_pal_rgb $403bca
vdp_pal_rgb $423cca
vdp_pal_rgb $443dcb
vdp_pal_rgb $473fcb
vdp_pal_rgb $4940cc
vdp_pal_rgb $4b41cc
vdp_pal_rgb $4e43cd
vdp_pal_rgb $5044cd
vdp_pal_rgb $5245ce
vdp_pal_rgb $5547cf
vdp_pal_rgb $5748cf
vdp_pal_rgb $5949d0
vdp_pal_rgb $5c4ad0
vdp_pal_rgb $5e4cd1
vdp_pal_rgb $604dd1
vdp_pal_rgb $634ed2
vdp_pal_rgb $6550d2
vdp_pal_rgb $6751d3
vdp_pal_rgb $6a52d3
vdp_pal_rgb $6c54d4
vdp_pal_rgb $6e55d5
vdp_pal_rgb $7156d5
vdp_pal_rgb $7357d6
vdp_pal_rgb $7559d6
vdp_pal_rgb $785ad7
vdp_pal_rgb $7a5bd7
vdp_pal_rgb $7c5dd8
vdp_pal_rgb $7f5ed8
vdp_pal_rgb $815fd9
vdp_pal_rgb $8361d9
vdp_pal_rgb $8662da
vdp_pal_rgb $8863db
vdp_pal_rgb $8a64db
vdp_pal_rgb $8d66dc
vdp_pal_rgb $8f67dc
vdp_pal_rgb $9168dd
vdp_pal_rgb $946add
vdp_pal_rgb $966bde
vdp_pal_rgb $986cde
vdp_pal_rgb $9b6edf
vdp_pal_rgb $9d6fdf
vdp_pal_rgb $9f70e0
vdp_pal_rgb $a272e1
vdp_pal_rgb $a473e1
vdp_pal_rgb $a674e2
vdp_pal_rgb $a975e2
vdp_pal_rgb $ab77e3
vdp_pal_rgb $ad78e3
vdp_pal_rgb $b079e4
vdp_pal_rgb $b27be4
vdp_pal_rgb $b47ce5
vdp_pal_rgb $b77de5
vdp_pal_rgb $b97fe6
vdp_pal_rgb $bb80e7
vdp_pal_rgb $be81e7
vdp_pal_rgb $c082e8
vdp_pal_rgb $c284e8
vdp_pal_rgb $c585e9
vdp_pal_rgb $c786e9
vdp_pal_rgb $c988ea
vdp_pal_rgb $cc89ea
vdp_pal_rgb $ce8aeb
vdp_pal_rgb $d08ceb
vdp_pal_rgb $d38dec
vdp_pal_rgb $d58eed
vdp_pal_rgb $d78fed
vdp_pal_rgb $da91ee
vdp_pal_rgb $dc92ee
vdp_pal_rgb $de93ef
vdp_pal_rgb $e195ef
vdp_pal_rgb $e396f0
vdp_pal_rgb $e597f0
vdp_pal_rgb $e899f1
vdp_pal_rgb $ea9af1
vdp_pal_rgb $ec9bf2
vdp_pal_rgb $ef9df3
;_gradient_end:
