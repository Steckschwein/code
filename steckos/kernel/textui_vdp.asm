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

;| VDP VRAM				  	 |
;|---------------------- |

.include "common.inc"
.include "kernel.inc"
.include "keyboard.inc"
.include "vdp.inc"

ROWS=24
CURSOR_BLANK=' '
CURSOR_CHAR=$db ; invert blank char - @see charset_6x8.asm

STATE_CURSOR_OFF	 =1<<1
STATE_CURSOR_BLINK  =1<<2
STATE_TEXTUI_ENABLED=1<<3

.code
.export textui_init0, textui_init, textui_update_screen, textui_chrout, textui_put

.ifdef TEXTUI_STROUT
.export textui_strout
.endif

.ifdef TEXTUI_PRIMM
.export textui_primm
.endif

.export textui_enable, textui_disable, textui_blank, textui_update_crs_ptr, textui_crsxy, textui_cursor_onoff, textui_setmode

.import vdp_bgcolor
.import vdp_memcpy
.import vdp_fill
.import vdp_text_on

textui_update_crs_ptr:		; updates the 16 bit pointer crs_p upon crs_x, crs_y values
		pha

		lda saved_char			;restore saved char
		jsr vram_crs_ptr_write		;		sta (crs_ptr)
		lda #STATE_CURSOR_BLINK
		trb screen_status		 ;reset cursor state

		;use the crs_ptr as tmp variable
		stz crs_ptr+1
		lda crs_y
		asl							; y*2
		asl							; y*4
		asl							; y*8

		bit max_cols
		bvc @l40
										; crs_y*64 + crs_y*16 (crs_ptr) => y*80
		asl							; y*16
		sta crs_ptr
		php							; save carry
		rol crs_ptr+1				; save carry if overflow
		bra @lae
@l40:
		; crs_y*32 + crs_y*8  (crs_ptr) => y*40
		sta crs_ptr					; save
		php							; save carry
@lae:
		asl
		rol crs_ptr+1			  	; save carry if overflow
		asl
		rol crs_ptr+1				; save carry if overflow

		plp							; restore carry from overflow above
		bcc @l0
		inc crs_ptr+1
		clc

@l0:	adc crs_ptr			;
		bcc @l1
		inc crs_ptr+1		; overflow inc page count
		clc					;
@l1:	adc crs_x
		sta a_vreg
		sta crs_ptr

	  	lda #>ADDRESS_TEXT_SCREEN
	  	adc crs_ptr+1		  ; add carry and page to address high byte
		sta a_vreg
		sta crs_ptr+1
		vdp_wait_l 3
		lda a_vram
  		sta saved_char		  ;save char at new position

	  	pla
  		rts

vram_crs_ptr_write:
		pha
		lda crs_ptr
		sta a_vreg
		vdp_wait_s 5
		lda crs_ptr+1
		ora #WRITE_ADDRESS
		sta a_vreg
		pla
		vdp_wait_l 3
		sta a_vram
		rts

textui_init0:
	vdp_sreg v_reg25_wait | v_reg25_cmd, v_reg25			; enable CMD in V9958

.ifdef COLS80
		  lda #TEXT_MODE_80
.else
		  lda #TEXT_MODE_40
.endif
textui_setmode:
		  cmp #TEXT_MODE_80
		  beq @setmode
		  lda #TEXT_MODE_40
@setmode:
		  sta max_cols
;		  jsr textui_blank

textui_init:
		  stz screen_write_lock					;reset write lock
		  jsr textui_enable

		  lda #KEY_LF
		  jsr textui_dispatch_char

.ifndef DISABLE_VDPINIT
		  jmp vdp_text_on
.endif
		  rts

textui_blank:
		  ldx #0
		  vdp_vram_w ADDRESS_TEXT_SCREEN
		  lda #CURSOR_BLANK
		  sta saved_char
		  ldx #4
		  jsr vdp_fill

		  ldx #0
		  ldy #0
		  jmp textui_crsxy

textui_cursor:
		  lda screen_write_lock
		  bne @l_exit
		  lda screen_frames
		  and #$0f
		  bne @l_exit

		  lda screen_status
		  and #STATE_CURSOR_OFF
		  bne @l_exit

		  lda #STATE_CURSOR_BLINK
		  tsb screen_status
		  beq @l1
		  trb screen_status
		  lda #CURSOR_CHAR
		  bra @l2
@l1:	  lda saved_char
@l2:
		  jmp vram_crs_ptr_write	;			sta (crs_ptr)
@l_exit:
		  rts

textui_update_screen:
	lda screen_status
	and #STATE_TEXTUI_ENABLED
	beq :+
	inc screen_frames
	jsr textui_cursor
:  rts

_screen_end:
	lda a_r+1	;4cl
	cmp #>(ADDRESS_TEXT_SCREEN+(COLS * 24)) ;2cl
	bne :+ ;3cl
	lda a_r+0 ;4cl
	cmp #<(ADDRESS_TEXT_SCREEN+(COLS * 24)) ;2cl
:	rts

COLS=40
textui_scroll_up:
	SetVector	(ADDRESS_TEXT_SCREEN+COLS), a_r		        ; +COLS - offset second row
	SetVector	(ADDRESS_TEXT_SCREEN+(WRITE_ADDRESS<<8)), a_w	; offset first row as "write address"

	phx
	php
	sei

BUFFER = $c100 ; TODO FIXME stack
	tsx
	dex ;vdp_wait_x needs 2 byte stack for jsr/rts
	dex
	stx vdp_ptr
	cpx #100
	bcs @l1
	stp
@l1:
	lda a_r+0	; 4cl
	sta a_vreg
	ldx vdp_ptr
	lda a_r+1
	sta a_vreg
	vdp_wait_l
@vram_read:
	vdp_wait_l 34
	lda a_vram
	sta BUFFER,x	; 4cl
	inc a_r+0	; 6cl
	bne :+		; 3cl
	inc a_r+1
:	jsr _screen_end ; 12cl+9cl
	beq @write		 ; 2/3
	dex				 ; 2cl
	bne @vram_read
@write:
	stx vdp_ptr+1
	ldx vdp_ptr
	lda a_w+0	; 3cl
	sta a_vreg
	lda a_w+1	; 3cl
	vdp_wait_s 4
	sta a_vreg
	vdp_wait_l
@vram_write:
	vdp_wait_l 20
	lda BUFFER,x
	sta a_vram
	inc a_w+0  ; 6cl
	bne :+	  ; 3cl
	inc a_w+1
:	dex		  ; 2cl
	cpx vdp_ptr+1 ;2cl
	bne @vram_write ;3cl
	jsr _screen_end
	bne @l1

	ldx #COLS	; write address is already setup from loop
	lda #' '
@l5:
	sta a_vram
	vdp_wait_l 4
	dex
	bne @l5

	plp
	plx
	rts

textui_inc_cursor_y:
		  lda crs_y
		  cmp	 #ROWS-1					; last line
		  bne	 @l1

		  lda saved_char			 	; restore saved char
		  jsr vram_crs_ptr_write	; sta (crs_ptr)
		  lda #CURSOR_BLANK
		  sta saved_char			 	; reset saved_char to blank, cause we scrolled up
		  lda #STATE_CURSOR_BLINK
		  trb screen_status		 	; reset cursor state
		  jsr textui_scroll_up	 	; scroll and exit
		  jmp textui_update_crs_ptr
@l1:	  inc crs_y
		  jmp textui_update_crs_ptr

textui_enable:
		  lda #STATE_TEXTUI_ENABLED
		  sta screen_status		 ;set enable
		  rts
textui_disable:
		  stz screen_status
		  lda saved_char			 ;restore char
		  jsr vram_crs_ptr_write	;sta (crs_ptr)
		  rts

textui_cursor_onoff:
		  lda screen_status
		  eor #STATE_CURSOR_OFF
		  sta screen_status
		  rts

.ifdef TEXTUI_STROUT
;----------------------------------------------------------------------------------------------
; Output string on screen
; in:
;	A - lowbyte  of string address
;	X - highbyte of string address
;----------------------------------------------------------------------------------------------
textui_strout:
		  sta krn_ptr3		  ;init for output below
		  stx krn_ptr3+1

		  inc screen_write_lock	 ;write lock on
		  ldy	 #$00
@l1:	  lda	 (krn_ptr3),y
		  beq	 @l2
		  jsr textui_dispatch_char
		  iny
		  bne	 @l1
@l2:	stz	 screen_write_lock	 ;write lock off
	 	rts
.endif

;----------------------------------------------------------------------------------------------
; Put the string following in-line until a NULL out to the console
; jsr primm
; .byte "Example Text!",$00
;----------------------------------------------------------------------------------------------
.ifdef TEXTUI_PRIMM
textui_primm:
		  pla								; Get the low part of "return" address
		  sta	  krn_ptr3
		  pla								; Get the high part of "return" address
		  sta	  krn_ptr3+1

		  inc screen_write_lock
		  ; Note: actually we're pointing one short
PSINB:  inc	  krn_ptr3				 ; update the pointer
		  bne	  PSICHO			 ; if not, we're pointing to next character
		  inc	  krn_ptr3+1				 ; account for page crossing
PSICHO: lda	  (krn_ptr3)				; Get the next string character
		  beq	  PSIX1			  ; don't print the final NULL
		  jsr	  textui_dispatch_char		  ; write it out
		  bra	  PSINB			  ; back around
PSIX1:  inc	  krn_ptr3				 ;
		  bne	  PSIX2			  ;
		  inc	  krn_ptr3+1				 ; account for page crossing
PSIX2:
		  stz screen_write_lock
		  jmp	  (krn_ptr3)			  ; return to byte following final NULL
.endif

textui_put:
	pha
	inc screen_write_lock	;write lock on
	sta saved_char
	stz screen_write_lock	;write lock off
	pla
	rts

textui_chrout:
	  	cmp #0
	  	beq @l1	 						; \0 char
	  	pha		  						; safe char
	  	inc screen_write_lock	 	; write on
	  	jsr textui_dispatch_char
	  	stz screen_write_lock	 	; write off
	  	pla						  		; restore a
@l1:	rts


; set crs x and y position absolutely - 0..32/0..23 or 0..39/0..23 40 char mode
;
textui_crsxy:
		  stx crs_x
		  sty crs_y
		  jmp textui_update_crs_ptr

textui_dispatch_char:
		  cmp	 #KEY_CR				;carriage return?
		  bne	 @lfeed
		  stz	 crs_x
		  jmp textui_update_crs_ptr
@lfeed:
			cmp #KEY_LF				;line feed
			bne @l1
			stz crs_x
			jmp textui_inc_cursor_y
@l1:	 	cmp #KEY_BACKSPACE
			bne @l4
			lda crs_x
			bne @l3
			lda crs_y						; cursor y=0, no dec
			beq @lupdate
			dec crs_y
			lda max_cols					; set x to end of line above
			sta crs_x
@l2:		jsr textui_update_crs_ptr
		  	lda #CURSOR_BLANK				; blank the saved char
		  	sta saved_char
		  	rts
@l3:	 	dec crs_x
		  	bra @l2	; TODO test
@l4:
			sta saved_char			; the trick, simple set saved value to plot as saved char, will be print by textui_update_crs_ptr
			lda crs_x
			cmp max_cols
			beq @l5
			inc crs_x
@lupdate:
		  	jmp textui_update_crs_ptr
@l5:	 	stz crs_x
		  	jmp textui_inc_cursor_y

.bss
screen_status:			.res 1
screen_write_lock:	.res 1
screen_frames:			.res 1
saved_char:				.res 1
a_r:	.res 2
a_w:	.res 2
