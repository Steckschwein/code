; MIT License
;
; Copyright (c) 2020 Thomas Woinke, Marko Lauke, www.steckschwein.de
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

.include "steckos.inc"
.include "vdp.inc"
.include "via.inc"
;.export char_out=krn_chrout

.import vdp_display_off, vdp_init_reg, vdp_fill, vdp_fills, vdp_memcpy, vdp_memcpys

memctl = $0230
charset = $e000
display_seconds = 2
;rbar_y = 93 ; with text
rbar_y = 191

.zeropage
adrl: .res 2
rline: .res 1

appstart $1000

.macro nops _n
	.repeat _n
		nop
   .endrep
.endmacro

.macro inc16 _w
	inc _w
	bne :+
	inc _w+1
	:
.endmacro

.code
	lda #rbar_y
	sta rline

	sei

	lda memctl
	pha
	stz memctl

	vdp_vram_w $0000
	lda #<charset
	ldy #>charset
	ldx #$08
	jsr vdp_memcpy

	pla
	sta memctl

   ;ADDRESS_GFX1_SPRITE_PATTERN
	vdp_vram_w $0000
	lda #<chars
	ldy #>chars
	ldx #16
	jsr vdp_memcpys
   ;vdp_vram_w ADDRESS_GFX1_COLOR
	vdp_vram_w $2000
	lda	#Transparent<<4|Transparent		;setup screen color gfx1
	ldx	#$20		; $20 possible colors
	jsr	vdp_fills

   ;vdp_fills ADDRESS_GFX1_SCREEN
	vdp_vram_w $1800
	lda	#' '		;clear screen gfx1
	ldx	#$03		; $300 chars
	jsr	vdp_fill

	jsr	init_sprites

	ldx #$20
	lda #$20
:	sta text_scroll_buf, x
	dex
	bpl :-

	copypointer  $fffe, irqsafe
	SetVector	stars_irq,	$fffe

	ldx #starfield_vdp_init_tab_end-starfield_vdp_init_tab
	lda #<starfield_vdp_init_tab
	ldy #>starfield_vdp_init_tab
	jsr vdp_init_reg

	; write rline into the interrupt line register #19
	; to generate an interrupt each time raster line is being scanned
	ldy #v_reg19
	lda rline
	vdp_sreg

	vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical, we avoid setup status register at isr entry set to S#1 per default

	lda #08
	sta crs_x
	lda #12
	sta crs_y

	SetVector line1, adrl

	cli

	lda #display_seconds
	sta seconds
	stz frame_cnt
	stz frame_end
	lda #$0a
	sta text_color_ix
	stz scroll_ctl

	; main loop
@loop:
	lda frame_end
	bne @loop

	sei
	jsr move_stars
	jsr text_scroll
	jsr update_vram
	cli

	lda frame_cnt
	and #$01
	bne :+
	jsr text_color
:
	ldx frame_cnt
	inx
	cpx	#50
	bne	:+
	ldx	#$00
:	stx	frame_cnt

	dec frame_end
	jsr krn_getkey
	cmp #$0d
	beq out
	cmp #$20
	beq out

	jmp @loop
out:
	sei
	copypointer	irqsafe,	$fffe
	vdp_sreg 0, v_reg15 ; reset to S#0
	cli
	jmp (retvec)

stars_irq:
	save
	lda a_vreg	; check bit 0 of S#1
	ror
	bcc @is_vblank

	lda rline
	clc
	adc #(256-rbar_y)
	tax
	lda raster_bar_colors,x
	sta	a_vreg
	lda	#v_reg7
	vdp_wait_s 2
	sta	a_vreg
	lda rline
	inc
	cmp #(rbar_y+(raster_bar_colors_end-raster_bar_colors))
	bne @set
	inc	frame_end ; set flag, raster bar end
	lda #rbar_y
@set:
	sta rline
	ldy #v_reg19
	vdp_sreg
	bra @exit

@is_vblank:
 	vdp_sreg 0, v_reg15			; 0 - set status register selection to S#0
 	vdp_wait_s
	bit a_vreg ; Check VDP interrupt. IRQ is acknowledged by reading.
 	bpl @is_vblank_end  ; VDP IRQ flag set?
	; do nothing beside ack
@is_vblank_end:
	vdp_sreg 1, v_reg15 ; update raster bar color during h blank is timing critical, we avoid setup status register at isr entry and reset to S#1
@exit:
	restore
	rti

update_vram:
	;update sprite tab
	vdp_vram_w $3c00
	lda #<starfield_spritetab
	ldy #>starfield_spritetab
	ldx #$20*4
	jsr vdp_memcpys
;
	;update text
	vdp_vram_w $1980
	lda #<text_scroll_buf
	ldy #>text_scroll_buf
	ldx #$20
	jsr vdp_memcpys

  ;skip first 8 chars
	vdp_vram_w $2001
	ldx text_color_ix
	lda intro_label_color,x
	ldx #$1f
	jmp vdp_fills


text_color:
	dec	text_color_ix
	bne	:+
	lda	#$0a
	sta text_color_ix
:	rts

text_scroll:
	lda	scroll_ctl
	bne @l1
	lda	frame_cnt
	cmp	#49
	bne	text_scroll_e
	lda	seconds
	beq	@l2
	dec seconds
	rts
@l2:
	lda	#display_seconds
	sta	seconds
	inc	scroll_ctl
@l1:
	ldx	#$00
:	lda	text_scroll_buf+1,x
	sta	text_scroll_buf,x
	inx
	cpx	#$1f
	bne	:-

	lda (adrl)
	inc16 adrl

	cmp #0
	bne :+
	; reset vector if null was read
	SetVector line1, adrl
:

	sta text_scroll_buf+$1f
	cmp #$01			;stop marker
	bne	text_scroll_e
	dec scroll_ctl

text_scroll_e:
	rts

move_stars:
	ldx #$00
	ldy #$00
:
	lda starfield_spritetab+1	,y
	;clc
	sec
	sbc starfield_speed_tab		,x
	sta starfield_spritetab+1	,y
	iny
	iny
	iny
	iny
	inx
	cpx	#$20
	bne  :-
	rts

init_sprites:
	lda	#$30
	sta seed
	stz yOffs
	ldx #$00
:	lda yOffs
	sta starfield_spritetab,y	; y pos
	clc
	adc #$06
	sta yOffs
	jsr rnd
	sta starfield_spritetab+1,y		; x offset
	eor #$1e
	lsr
	and	#$07
	ora	#$01
	sta starfield_speed_tab,x		; speed
	; lda	#White
	phx
	tax
 	lda star_colors,x
	plx
	sta starfield_spritetab+3,y
	lda	#$00
	sta starfield_spritetab+2,y		; pattern
	iny
	iny
	iny
	iny
	inx
	cpx	#$20
	bne :-
	rts

starfield_vdp_init_tab:
	.byte v_reg0_IE1
	.byte v_reg1_16k|v_reg1_display_on|v_reg1_int
	.byte ($1800 / $400)	; name table - value * $400
	.byte ($2000 / $40)	; color table
	.byte ($0000 / $800) ; pattern table
	.byte ($3c00 / $80)	; sprite attribute table - value * $80 --> offset in VRAM
	.byte ($0000 / $800)	; sprite pattern table - value * $800  --> offset in VRAM
	.byte Transparent
starfield_vdp_init_tab_end:

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


chars:
; star char, used as sprite
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00001000
.byte %00000000
.byte %00000000
.byte %00000000
; blank char, used as stop marker
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000


.data
intro_label_color:
	.byte Magenta<<4|Transparent
	.byte Dark_Red<<4|Transparent
	.byte	Medium_Red<<4|Transparent
	.byte	Light_Red<<4|Transparent
	.byte	Dark_Yellow<<4|Transparent
	.byte	Light_Yellow<<4|Transparent
	.byte	Dark_Yellow<<4|Transparent
	.byte	Light_Red<<4|Transparent
	.byte	Medium_Red<<4|Transparent
	.byte Dark_Red<<4|Transparent
	.byte Magenta<<4|Transparent
	.byte White
raster_bar_colors:
	.byte Magenta
	.byte Dark_Red
	.byte	Medium_Red
	.byte	Light_Red
	.byte	Dark_Yellow
	.byte	Light_Yellow
	.byte	Dark_Yellow
	.byte	Light_Red
	.byte	Medium_Red
	.byte Dark_Red
	.byte Magenta
	.byte Black
raster_bar_colors_end:
star_colors:
  .byte 0, Gray, Light_Red, Dark_Yellow, Light_Yellow, Cyan, Light_Green, White
star_colors_end:

line1:
	.byte	"Steckschwein                   ",1
	.byte	"8bit Homebrew Computer         ",1
	.byte   "CPU: 65c02 @ 8MHz              ",1
	.byte   "Memory: 64k SRAM / 32k ROM     ",1
	.byte   "Video: Yamaha V9958            ",1
	.byte   "RS232 via 16c550 UART          ",1
	.byte   "Sound: Yamaha YM3812 (OPL2)    ",1
	.byte   "Storage: SD Card via SPI       ",1

	.byte   "                               ",1
	.byte	0


.bss
yOffs: 			.res 1
seed: 			.res 1
frame_cnt: 		.res 1
frame_end: 		.res 1
scroll_ctl: 	.res 1
text_color_ix: 	.res 1
seconds: 		.res 1
irqsafe: 		.res 2
starfield_speed_tab:
	.res 32, 0
starfield_spritetab:;y,x,pattern,attr
	.res 32*4, 0
text_scroll_buf:
	.res 32
