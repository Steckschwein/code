.include "steckos.inc"
.include "common.inc"
.include "vdp.inc"
.include "via.inc"
appstart $1000
.export char_out=krn_chrout

.importzp ptr1
.import vdp_display_off, vdp_init_reg, vdp_fill, vdp_fills, vdp_memcpy, vdp_memcpys
.zeropage
adrl:  .res 1
adrh:  .res 1


.code

    jmp	main

yOffs: .byte 0
seed: .byte 0
frame_cnt: .byte 0
frame_end: .byte 0
scrollpos: .byte 0
scroll_ctl: .byte 0
text_color_ix: .byte 0
seconds: .byte 0

memctl = $0230
charset = $e000

line1:
.byte	"       -+-  VCFe 18.0 -+-       ",1
.byte	"      -+- Steckschwein -+-      ",1
.byte	" -+- 8bit Homebrew Computer -+- ",1
.byte	"    -+- CPU 65c02 / 8 MHz -+-   ",1
.byte	"     -+- Video TMS9929 -+-      ",1
.byte	"  -+- www.steckschwein.de -+-   ",1
;!fill	255, $20
.byte	0


main:
	sei

	; jsr getkey

	jsr	vdp_display_off

	lda memctl
    pha
	stz memctl

	SetVector charset, adrl
	lda #$00
	ldy #$00+$40
	ldx	#$08
	jsr	vdp_memcpy

	pla
	sta memctl

	SetVector	chars, adrl
	lda	#$00		;setup pattern
	ldy	#$00+$40
	ldx	#$10		;
	jsr	vdp_memcpys

	lda	#Cyan<<4|Black		;setup screen color gfx1
	sta	adrl
	lda	#$00
	ldy	#$20+$40
	ldx	#$20		; $20 possible colors
	jsr	vdp_fills

	lda	#$20		;clear screen gfx1
	sta	adrl
	lda	#$00
	ldy	#$18+$40
	ldx	#$03		; $300 chars
	jsr	vdp_fill

	jsr	init_via

	jsr	init_sprites

	;SetVector	stars_irq,	irqvec


	SetVector	starfield_tab, adrl
	jsr	vdp_init_reg

	lda	#v_reg1_16k|v_reg1_display_on|v_reg1_int
	ldy	#v_reg1
	vdp_sreg

	lda		#08
	sta		crs_x
	lda		#12
	sta		crs_y
	SetVector	line1, adrl

	cli

	lda		#$03
	sta		seconds
	stz		frame_cnt
	stz		frame_end
	stz		scrollpos
	lda		#$0a
	sta		text_color_ix
	stz		scroll_ctl

	; main loop

:	lda		frame_end
	bne		:-

	jsr 	move_stars
	jsr		text_scroll
	lda		frame_cnt
	and		#$01
	bne		:+
	jsr		text_color
:
	;jsr		joystick

	dec		frame_end


	; jsr getkey
	; cmp #$0d
	; beq .out
	; cmp #$20
	; beq .out

	jmp	:-
;.out
	jmp $c800


; stars_irq:
	; bit via1ifr		; Interrupt from VIA?
	; beq +
	; bit via1t1cl	; acknowledge VIA timer 1 interrupt
; +
	; +save
;
	; bit	a_vreg ; Check VDP interrupt. IRQ is acknowledged by reading.
	; bmi +	   ; VDP IRQ flag set?
	; rti
; +
	; +nops	89
	; ldx		#$00
; -	lda		raster_bar_colors,x
	; jsr		vdp_bgcolor
	; +nops	$6d
	; inx
	; cpx		#$0b
	; bne		-
	; lda		#Black
	; jsr		vdp_bgcolor
;
;
	; ;update sprite tab
	; SetVector	starfield_spritetab, adrl
	; lda	#$00
	; ldy	#$3c+$40
	; ldx	#$20*4
	; jsr vdp_memcpys
;
	; ;update text
	; SetVector	text_scroll_buf, adrl
	; lda	#$80
	; ldy	#$19+$40
	; ldx	#$20
	; jsr vdp_memcpys
;
	; ldx	text_color_ix
	; lda	intro_label_color,x
	; sta	adrl
	; lda	#$01	;skip first 8 chars
	; ldy #$20+$40
	; ldx	#$1f
	; jsr	vdp_fills
;
	; ldx frame_cnt
	; inx
	; cpx	#50
	; bne	+
	; ldx	#$00
; +	stx	frame_cnt
;
	; inc	frame_end
;
	; +restore
	; rti
;
; joystick:
	; rts

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
    lda	#$03
	sta	seconds
	inc	scroll_ctl
@l1:
	ldx	#$00
:	lda	text_scroll_buf+1	,x
	sta	text_scroll_buf		,x
	inx
	cpx	#$1f
	bne	:-
	ldx	scrollpos
	lda line1,x
	sta text_scroll_buf+$1f
	inc scrollpos
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
	clc
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
	and	#$07
	ora	#$01
	sta starfield_speed_tab,x		; speed
	and	#$0f
	lda	#White
	;and	#$07
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

starfield_tab:
	.byte	0
	.byte v_reg1_16k
	.byte ($1800 / $400)	; name table - value * $400
	.byte	($2000 / $40)	; color table
	.byte	($0000 / $800) ; pattern table
	.byte	($3c00 / $80)	; sprite attribute table - value * $80 --> offset in VRAM
	.byte	($0000 / $800)	; sprite pattern table - value * $800  --> offset in VRAM
	.byte	Black

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

init_via:
	;via port a
	lda #$00
	sta via1ier             ; disable VIA1 T1, T2 interrupts
	lda #%00000000 			; set latch
	sta via1acr
	lda #%11001100 			; set level
	sta via1pcr
	lda #%11111000 			; set PA1-3 to input
	sta via1ddra
	rts

chars:
;+SpriteLine	%........
;+SpriteLine	%........
;+SpriteLine	%........
;+SpriteLine	%...#....
;+SpriteLine	%........
;+SpriteLine	%........
;+SpriteLine	%........
;+SpriteLine	%........
blank:
;+SpriteLine	%........
;+SpriteLine	%........
;+SpriteLine	%........
;+SpriteLine	%........
;+SpriteLine	%........
;+SpriteLine	%........
;+SpriteLine	%........
;+SpriteLine	%........

starfield_speed_tab:
;	!fill 32, 0
starfield_spritetab:;y,x,pattern,attr
;	!fill 32*4, 0
text_scroll_buf:
;	!fill 32, $20

intro_label_color:
	.byte Magenta<<4|Black
	.byte Dark_Red<<4|Black
	.byte	Medium_Red<<4|Black
	.byte	Light_Red<<4|Black
	.byte	Dark_Yellow<<4|Black
	.byte	Light_Yellow<<4|Black
	.byte	Dark_Yellow<<4|Black
	.byte	Light_Red<<4|Black
	.byte	Medium_Red<<4|Black
	.byte Dark_Red<<4|Black
	.byte Magenta<<4|Black
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

