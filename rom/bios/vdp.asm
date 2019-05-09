      .export vdp_init, vdp_chrout, vdp_scroll_up

      .include "bios.inc"
      .include "vdp.inc"

      .import primm
      .import vdp_text_on
      .import vdp_text_blank
      .import vdp_bgcolor
      ;.importzp ptr1,ptr2

ROWS=23
.ifdef CHAR6x8
  .import charset_6x8
  .ifdef COLS80
    .ifndef V9958
      .assert 0, error, "80 COLUMNS ARE SUPPORTED ON V9958 ONLY! MAKE SURE -DV9958 IS ENABLED"
    .endif 
    COLS=80
  .else
    COLS=40
  .endif 
.endif
.ifndef CHAR6x8
  COLS=32
  .import charset_8x8
.endif

.code
;----------------------------------------------------------------------------------------------
; init tms99xx with gfx1 mode
;----------------------------------------------------------------------------------------------
vdp_init:
      lda a_vreg
      lda #v_reg1_16k	;enable 16K/64k ram, disable screen
      ldy #v_reg1
      vdp_sreg

.ifdef V9958
			; enable V9958 wait state generator
			lda #v_reg25_wait
			ldy #v_reg25
			vdp_sreg

.endif
      jsr vdp_text_blank
      
			lda	#<ADDRESS_GFX_SPRITE
			ldy	#(WRITE_ADDRESS + >ADDRESS_GFX_SPRITE)
			vdp_sreg
			lda	#$d0					;sprites off, at least y=$d0 will disable the sprite subsystem
			vnops
			sta a_vram

			stz crs_x
			stz crs_y

			lda #<ADDRESS_TEXT_PATTERN
			ldy #(WRITE_ADDRESS + >ADDRESS_TEXT_PATTERN)
			vdp_sreg
			ldx #$08                    ;load charset
			ldy   #$00
			.ifdef CHAR6x8
			SetVector    charset_6x8, addr
			.endif
			.ifndef CHAR6x8		; 8x8 and 32 cols, also setup colors in color ram
			SetVector    charset_8x8, addr
			.endif
@l2:
			lda   (addr),y ;5
			iny            ;2
			vnops         ;8
			sta   a_vram   ;1 opcode fetch
			bne   @l2        ;3
			inc   adrh
			dex
			bne   @l2

			; in 8x8 and 32 cols we must setup colors in color vram
			lda	#<ADDRESS_GFX1_COLOR
			ldy	#WRITE_ADDRESS + >ADDRESS_GFX1_COLOR
			vdp_sreg
			lda #Gray<<4|Black          ;enable gfx 1 with gray on black background
			ldx	#$20
@l3:		vnops
			dex
			sta a_vram
			bne @l3

.ifdef COLS80
      lda #80-1 ; TODO constant
.else
      lda #40-1 ; TODO constant
.endif
      sta max_cols
      
.ifdef CHAR6x8
      jsr vdp_text_on
      lda #BIOS_COLOR
      jmp vdp_bgcolor
.endif

.ifndef CHAR6x8
			lda vdp_init_bytes_gfx1,x
			vdp_sreg
			iny
			inx
			cpx	#09
			bne @l4
			rts
.endif

.export vdp_detect
vdp_detect:
			jsr primm
			.byte "V99",0
      lda #1          ; select sreg #1
      ldy #v_reg15
      vdp_sreg
      vnops
      lda a_vreg
      lsr             ; shift right
      and #$1f        ; and mask chip ID#
      clc
      adc #'3'        ; add ascii '3' to ID# value, V9938 ID# = "0", V9958 ID# = "2"
      jsr vdp_chrout
      jsr primm
			.byte "8 VRAM: ",0      
      lda #0          ; select sreg #0
      ldy #v_reg15
      vdp_sreg
      
      ; VRAM detection
      jsr _vdp_detect_vram
      
      ; Ext RAM detection
_vdp_detect_ext_ram:
      jsr primm
      .asciiz " ExtRAM: "
      lda #v_reg45_mxc
      ldy #v_reg45
      vdp_sreg
      ldx #4  ;max 4 16k banks = 64k
      jsr _vdp_detect_ram
      lda #KEY_LF
			jmp vdp_chrout
      
_vdp_detect_vram:
      ldx #8  ;max 8 16k banks = 128k
_vdp_detect_ram:
      lda #$ff
      sta tmp1  ; the bank, start at $0, first inc below
@l_detect:
      inc tmp1
      dex 
      bmi @l_end    ; we have to break after given amount of banks, otherwise overflow vram address starts from beginning
      lda tmp1
      ldy #v_reg14
      vdp_sreg
      jsr _vdp_bank_available
      beq @l_detect
@l_end:
      lda #0        ;switch back to bank 0 and vram
      ldy #v_reg14
      vdp_sreg
      lda #0
      ldy #v_reg45
      vdp_sreg
      
      ldx #$ff
      lda tmp1
      beq @l_nc
@l_shift:
      inx
      lsr tmp1
      bne @l_shift
      txa
      sta tmp1
      asl tmp1
      adc tmp1
      tay
      ldx #3
:     lda _ram,y
      jsr vdp_chrout
      iny
      dex
      bne :-
      jsr primm
			.byte "KBytes",0
      rts
@l_nc:
      lda #'-'
      jmp vdp_chrout
_ram:
      .byte " 16 32 64128"
      
_vdp_bank_available:
      phx
      jsr _vdp_r_vram
      ldx a_vram

      jsr _vdp_w_vram
      lda tmp1
      sta a_vram
      pha
      vnops
      jsr _vdp_r_vram ; ... read back again
      pla
      lda tmp1
      cmp a_vram
      bne @invalid
      jsr _vdp_w_vram
      txa
      sta a_vram
      plx
      lda #0
      rts
@invalid:
      plx
      lda #$ff
      rts
      
bank_end = $3fff
_vdp_w_vram:
      ldy #(WRITE_ADDRESS | >bank_end)
      bra _vdp_vram0
_vdp_r_vram:
      ldy #>bank_end
_vdp_vram0:
      lda #<bank_end
      vdp_sreg
      vnops
      rts
      
vdp_scroll_up:
			SetVector	(ADDRESS_TEXT_SCREEN+COLS), ptr3		        ; +COLS - offset second row
			SetVector	(ADDRESS_TEXT_SCREEN+(WRITE_ADDRESS<<8)), ptr4	; offset first row as "write adress"
@l1:
@l2:
			lda	ptr3+0	; 3cl
			sta	a_vreg
			nop
			lda	ptr3+1	; 3cl
			sta	a_vreg
			vnops		; wait 2µs, 8Mhz = 16cl => 8 nop
			ldx	a_vram	;
			vnops

			lda	ptr4+0	; 3cl
			sta	a_vreg
			vnops
			lda	ptr4+1	; 3cl
			sta a_vreg
			vnops
			stx	a_vram
			inc	ptr3+0	; 5cl
			bne	@l3		; 3cl
			inc	ptr3+1
			lda	ptr3+1
			cmp	#>(ADDRESS_TEXT_SCREEN+(COLS * 24 + (COLS * 24 .MOD 256)))	;screen ram $1800 - $1b00
			beq	@l4
@l3:
			inc	ptr4+0  ; 5cl
			bne	@l2		; 3cl
			inc	ptr4+1
			bra	@l1
@l4:
			ldx	#COLS	; write address is already setup from loop
			lda	#' '
@l5:
			sta	a_vram
			vnops
			dex
			bne	@l5
			rts

inc_cursor_y:
			lda crs_y
			cmp	#ROWS		;last line ?
			bne	@l1
			bra	vdp_scroll_up	; scroll up, dont inc y, exit
@l1:
			inc crs_y
			rts

vdp_chrout:
			cmp	#KEY_CR			;cariage return ?
			bne	@l1
			stz	crs_x
			rts
@l1:
			cmp	#KEY_LF			;line feed
			bne	@l2
			stz	crs_x
			bra	inc_cursor_y
@l2:
			cmp	#KEY_BACKSPACE
			bne	@l3
			lda	crs_x
			beq	@l4
			dec	crs_x
			bra @l5
@l4:
			lda	crs_y			; cursor y=0, no dec
			beq	@l6
			dec	crs_y
			lda	#(COLS-1)		; set x to end of line above
			sta	crs_x
@l5:
			lda #' '
			bra	vdp_putchar

@l3:
			jsr	vdp_putchar
			lda	crs_x
			cmp	#(COLS-1)
			beq @l7
			inc	crs_x
@l6:
			rts
@l7:
			stz	crs_x
			bra	inc_cursor_y

vdp_putchar:
		pha
		jsr vdp_set_addr
		pla
		vnops
		sta a_vram
		rts

.ifndef CHAR6x8
vdp_set_addr:				; set the vdp vram adress, write A to vram
		lda	crs_y   		; * 32
		asl
		asl
		asl
		asl
		asl
		ora crs_x
		sta a_vreg

		lda crs_y   		; * 32
		lsr					; div 8 -> page offset 0-2
		lsr
		lsr
		ora #(WRITE_ADDRESS + >ADDRESS_TEXT_SCREEN)
		nop
		nop
		sta a_vreg
		rts

vdp_init_bytes_gfx1:
    .byte 0
    .byte	v_reg1_16k|v_reg1_display_on|v_reg1_spr_size
    .byte (ADDRESS_TEXT_SCREEN / $400)	; name table - value * $400					--> characters
    .byte (ADDRESS_GFX1_COLOR /  $40)	; color table - value * $40 (gfx1), 7f/ff (gfx2)
    .byte (ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM
    .byte	(ADDRESS_GFX1_SPRITE / $80)	; sprite attribute table - value * $80 		--> offset in VRAM
    .byte (ADDRESS_GFX1_SPRITE_PATTERN / $800)  ; sprite pattern table - value * $800  		--> offset in VRAM
    .byte	Black ;#R07
    .byte v_reg8_VR	; VR - 64k VRAM TODO FIXME aware of max vram (bios) - #R08
.endif

.ifdef CHAR6x8
v_l=tmp1
v_h=tmp2
vdp_set_addr:			; set the vdp vram adress, write A to vram
		stz	v_h
		lda crs_y
		asl
		asl
		asl				; crs_y*8

.ifdef COLS80
		; crs_y*64 + crs_y*16 (crs_ptr) => y*80
		asl				; y*16
		sta v_l
		rol v_h		   	; save carry if overflow
.else
		; crs_y*32 + crs_y*8  (crs_ptr) => y*40
		sta v_l			; save
.endif

		asl		   		;
		rol v_h		   	; save carry if overflow
		asl				;
		rol v_h			; save carry if overflow
		adc v_l

		bcc @l1
		inc	v_h			; overflow inc page count
		clc				;
@l1:
    adc crs_x		; add x to address
		sta a_vreg
		lda #(WRITE_ADDRESS + >ADDRESS_TEXT_SCREEN)
		adc v_h			; add carry and page to address high byte
		vnops
		sta a_vreg
		rts
.endif
