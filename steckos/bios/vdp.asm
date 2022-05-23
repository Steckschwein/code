      .export vdp_init, _vdp_chrout, vdp_scroll_up

      .include "bios.inc"
      .include "vdp.inc"

      .import primm
      .import vdp_text_on
      .import vdp_gfx1_on
      .import vdp_text_blank
      .import vdp_gfx1_blank
      .import vdp_bgcolor
      .import vdp_set_sreg
      .import vdp_text_init_bytes
      .import vdp_memcpy
      .import vdp_fills
      .import vdp_chrout
.zeropage
ptr3: .res 2
ptr4: .res 2
tmp1: .res 1
tmp2: .res 1
.code
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
.else
  COLS=32
  .import charset_8x8
.endif

.code
;----------------------------------------------------------------------------------------------
; init tms99xx with gfx1 mode
;----------------------------------------------------------------------------------------------
vdp_init:
.ifdef COLS80
			lda #VIDEO_MODE_80_COLS
         tsb video_mode
.else
			lda #VIDEO_MODE_80_COLS
			trb video_mode
.endif
         lda #BIOS_COLOR
.ifdef CHAR6x8
			jsr vdp_text_on
.else
			jsr vdp_gfx1_on
.endif
         lda vdp_text_init_bytes+1 ; disable vdp irq
         and #<~(v_reg1_int)
         ldy #v_reg1
         jsr vdp_set_sreg

.ifndef V9958
			vdp_vram_w ADDRESS_GFX_SPRITE
			vdp_wait_l
			lda #SPRITE_OFF					;sprites off, at least y=$d0 will disable the sprite subsystem
			sta a_vram
.endif
			stz crs_x
			stz crs_y

.ifdef CHAR6x8
			jsr vdp_text_blank

			vdp_vram_w ADDRESS_TEXT_PATTERN
			lda #<charset_6x8
			ldy #>charset_6x8
.else 	; 8x8 and 32 cols, also setup colors in color ram
			; in 8x8 and 32 cols we must setup colors in color vram
			vdp_vram_w ADDRESS_GFX1_COLOR
			lda #Gray<<4|Black          ;enable gfx 1 with gray on black background
			ldx #$20
			jsr vdp_fills
			jsr vdp_gfx1_blank

			vdp_vram_w ADDRESS_GFX1_PATTERN
			lda #<charset_8x8
			ldy #>charset_8x8
.endif
			ldx #$08                    ;load charset
			jmp vdp_memcpy

.export vdp_detect
vdp_detect:
			lda #1          ; select sreg #1
			ldy #v_reg15
			vdp_sreg
			vdp_wait_l
			lda a_vreg
			lsr             ; shift right
			and #$1f        ; and mask chip ID#
			cmp #3
			bcc _l_chip
			jsr primm
			.byte "Unknown Video",CODE_LF,0
			rts
_l_chip:
			clc
			adc #'3'        ; add ascii '3' to ID# value, V9938 ID# = "0", V9958 ID# = "2"
			pha
			jsr primm
			.byte "V99",0
			pla
			jsr vdp_chrout
			jsr primm
			.byte "8 VRAM: ",0
			lda #0          ; select sreg #0
			ldy #v_reg15
			vdp_sreg

			; VRAM detection
			ldx #8  ;max 8 16k banks = 128k
			jsr _vdp_detect_ram

			; Ext RAM detection
_vdp_detect_ext_ram:
			jsr primm
			.byte " ExtRAM: ",0
			vdp_sreg v_reg45_mxc, v_reg45 ; enable ext ram
			ldx #4  ;max 4 16k banks = 64k Ext. RAM possible
			jsr _vdp_detect_ram

			lda #CODE_LF
			jmp vdp_chrout

_vdp_detect_ram:
			lda #$ff
			sta tmp1  ; the bank, start at $0, first inc below
@l_detect:
			inc tmp1
			dex
			bmi @l_end    ; we have to break after given amount of banks, otherwise overflow vram address starts from beginning

            lda tmp1      ; select bank
			ldy #v_reg14
			jsr vdp_set_sreg

            jsr _vdp_bank_available
			beq @l_detect
@l_end:
			vdp_sreg 0, v_reg14 ;switch back to bank 0 and vram
			vdp_sreg 0, v_reg45 ;disable Ext.Ram

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
:			lda _ram,y
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

PATTERN=$a9

_vdp_bank_available:
			phx
			jsr _vdp_r_vram
			ldx a_vram  ;save to x

			jsr _vdp_w_vram
			lda #PATTERN
			sta a_vram
			pha
			vdp_wait_l
			jsr _vdp_r_vram ; ... read back again
			pla
			lda a_vram
         cmp #PATTERN
			bne @invalid
			jsr _vdp_w_vram
			stx a_vram      ;restore
			plx
			lda #0
			rts
@invalid:
			plx
			lda #$ff
			rts

bank_end = $3ffe ; read the even address, to be also compatible in 80 col mode
_vdp_w_vram:
			ldy #(WRITE_ADDRESS | >bank_end)
			bra _vdp_vram0
_vdp_r_vram:
			ldy #>bank_end
_vdp_vram0:
			lda #<bank_end
         vdp_wait_l
			jsr vdp_set_sreg
			vdp_wait_l
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
			vdp_wait_l		; wait 2µs, 8Mhz = 16cl => 8 nop
			ldx	a_vram	;
			vdp_wait_l

			lda	ptr4+0	; 3cl
			sta	a_vreg
			vdp_wait_l
			lda	ptr4+1	; 3cl
			sta a_vreg
			vdp_wait_l
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
			vdp_wait_l
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

_vdp_chrout:
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
			vdp_wait_l 8
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
.endif

.ifdef CHAR6x8
v_l=tmp1
v_h=tmp2
vdp_set_addr:			; set the vdp vram adress, write A to vram
		stz v_h
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

		asl
		rol v_h		   ; save carry if overflow
		asl				;
		rol v_h			; save carry if overflow
		adc v_l

		bcc @l1
		inc v_h			; overflow inc page count
		clc				;
@l1:
		adc crs_x		; add x to address
		sta a_vreg
		lda #(WRITE_ADDRESS + >ADDRESS_TEXT_SCREEN)
		adc v_h			; add carry and page to address high byte
		vdp_wait_s 4
		sta a_vreg
		rts
.endif
