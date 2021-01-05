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

;| VDP VRAM              |
;|---------------------- |

.include "common.inc"
.include "kernel.inc"
.include "keyboard.inc"
.include "vdp.inc"

ROWS=24
CURSOR_BLANK=' '
CURSOR_CHAR=$db ; invert blank char - @see charset_6x8.asm

STATE_CURSOR_OFF			=1<<1
STATE_CURSOR_BLINK		=1<<2
STATE_TEXTUI_ENABLED		=1<<3

.code
.export textui_init0, textui_init, textui_update_screen, textui_chrout, textui_put

.ifdef TEXTUI_STROUT
.export textui_strout
.endif

.ifdef TEXTUI_PRIMM
.export textui_primm
.endif

.export textui_enable, textui_disable, textui_blank, textui_update_crs_ptr, textui_crsxy, textui_cursor_onoff, textui_setmode

.import vdp_fill
.import vdp_text_on

textui_scroll_up:
	php
	sei	; critical section, we use the vdp regs
	phx
	phy

	lda #<ADDRESS_TEXT_SCREEN
	clc
    bit video_mode
    bvc :+
    adc #40
:	adc #40
	sta a_r
	lda #>ADDRESS_TEXT_SCREEN
	sta a_r+1
	SetVector (ADDRESS_TEXT_SCREEN+(WRITE_ADDRESS<<8)), a_w	; offset first row as "write address"

	; 40/80 col mode, 10/20 * 100 calc pages to copy
    ldy #10
	bit video_mode
    bvc @l1
	ldy #20
@l1:
	lda a_r+0	; 4cl
	sta a_vreg
	ldx #scroll_buffer_size-1
	lda a_r+1
	vdp_wait_s
	sta a_vreg
	vdp_wait_l
@vram_read:
	vdp_wait_l 18
	lda a_vram
	sta scroll_buffer,x	; 4cl
	inc a_r+0	; 6cl
	bne :+		; 3cl
	inc a_r+1
:	dex					; 2cl
	bpl @vram_read ;3cl
@write:
	ldx #scroll_buffer_size-1
	lda a_w+0	; 3cl
	sta a_vreg
	lda a_w+1
	vdp_wait_s 4
	sta a_vreg
	vdp_wait_l
@vram_write:
	vdp_wait_l 18
	lda scroll_buffer,x	;4
	sta a_vram
	inc a_w+0  ; 6cl
	bne :+	  ; 3cl
	inc a_w+1
:	dex ; 2cl
	bpl @vram_write ;3cl
	dey
	bne @l1

	ldx #80 ; write address is already setup from loop above
	lda #' '
@l5:
	vdp_wait_l 5
	sta a_vram
	dex
	bne @l5

	ply
	plx
	plp

textui_update_crs_ptr:				; updates the 16 bit pointer crs_ptr upon crs_x, crs_y values
	jsr _vram_crs_ptr_write_saved ; restore saved char
	lda #STATE_CURSOR_BLINK
	trb screen_status		 ;reset cursor state

	;use the crs_ptr as tmp variable
	php
	sei
	stz crs_ptr+1
	lda crs_y
    asl							; y*2
	asl							; y*4
	asl							; y*8
	sta crs_ptr					; save for add below

	asl							; y*16
	rol crs_ptr+1				; shift carry to address high byte
	asl							; y*32
	rol crs_ptr+1			  	; shift carry to address high byte

	adc crs_ptr					; y*40 = y*8+y*32
	bcc :+
	inc crs_ptr+1				; overflow inc page count
	clc

:	bit video_mode
	bvc :+
	asl 						; y*80 => y*40*2
	rol crs_ptr+1               ; shift carry to address high byte

:	adc crs_x					; add cursor x
	sta a_vreg
	sta crs_ptr

	lda #>ADDRESS_TEXT_SCREEN
	adc crs_ptr+1		  		; add carry (above) and page to address high byte
	sta a_vreg
	sta crs_ptr+1
	vdp_wait_l 3
	lda a_vram
	sta saved_char		  ; save char at new position
	plp
	rts

_vram_crs_ptr_write_saved:
	lda saved_char
_vram_crs_ptr_write:
	php
	sei
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
	plp
	rts

textui_init0:
    lda #VIDEO_MODE_80_COLS
.ifdef COLS80
    tsb video_mode
.else
    trb video_mode
.endif
    bra textui_init

textui_setmode:
    and #VIDEO_MODE_80_COLS
    bne :+
    lda #VIDEO_MODE_80_COLS
    trb video_mode
    bra @blank
:   tsb video_mode
@blank:
    jsr textui_blank

textui_init:
	stz screen_write_lock					;reset write lock
	jsr textui_enable

	lda #CODE_LF
	jsr __textui_dispatch_char

.ifndef DISABLE_VDPINIT
	jmp vdp_text_on
.endif
	rts

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
	jmp _vram_crs_ptr_write
@l1:
	jmp _vram_crs_ptr_write_saved
@l_exit:
	rts

textui_update_screen:
	lda screen_status
	and #STATE_TEXTUI_ENABLED
	beq :+
	inc screen_frames
	jmp textui_cursor
:	rts

textui_enable:
	lda #STATE_TEXTUI_ENABLED
	sta screen_status		 ;set enable
	rts
textui_disable:
	stz screen_status
	jmp _vram_crs_ptr_write_saved ;restore char

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
@l1:
	lda	 (krn_ptr3),y
	beq	 @l2
	jsr __textui_dispatch_char
	iny
	bne	 @l1
@l2:
	stz screen_write_lock	 ;write lock off
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
		  jsr	  __textui_dispatch_char		  ; write it out
		  bra	  PSINB			  ; back around
PSIX1:  inc	  krn_ptr3				 ;
		  bne	  PSIX2			  ;
		  inc	  krn_ptr3+1				 ; account for page crossing
PSIX2:
		  stz screen_write_lock
		  jmp	  (krn_ptr3)			  ; return to byte following final NULL
.endif

textui_put:
	inc screen_write_lock	 	; write on
	sta saved_char
	stz screen_write_lock	 	; write off
	rts

textui_chrout:
	cmp #0
	beq @l1	 						; \0 char
	php
	sei
	pha		  						; save char
	inc screen_write_lock	 	; write on
	jsr __textui_dispatch_char
	stz screen_write_lock	 	; write off
	pla						  		; restore a
	plp
@l1:
	rts

textui_blank:
	ldx #4
	bit video_mode
	bvc :+
	ldx #8
:	php
	sei
	vdp_vram_w ADDRESS_TEXT_SCREEN
	lda #CURSOR_BLANK
	sta saved_char
	jsr vdp_fill
	plp

	ldx #0
	ldy #0
	; set crs x and y position absolutely - 0..32/0..23 or 0..39/0..23 40 char mode
textui_crsxy:
	stx crs_x
	sty crs_y
	jmp textui_update_crs_ptr

__textui_dispatch_char:
	cmp #KEY_CR	;carriage return?
	bne @lfeed
	stz crs_x
	jmp textui_update_crs_ptr
@lfeed:
	cmp #KEY_LF	;line feed
	beq @l5
	cmp #KEY_BACKSPACE
	bne @l4
	lda crs_x
	bne @l3
	lda crs_y						; cursor y=0, no dec
	beq @exit
	dec crs_y
	lda #40
    bit video_mode					; set x to max-cols -1
    bvc @l3
    lda #80
@l3:
	dec 							; which is end of the line
	sta crs_x
@l2:
	jsr textui_update_crs_ptr
	lda #CURSOR_BLANK				; blank the saved char
	sta saved_char
@exit:
	rts
@l4:
	sta saved_char			; the trick, simple set saved value to plot as saved char, will be print by textui_update_crs_ptr
	lda crs_x
	inc
    bit video_mode
    bvs :+
    cmp #40
    beq @l5
:   cmp #80
	beq @l5
	sta crs_x
	jmp textui_update_crs_ptr
@l5:
	stz crs_x

	lda crs_y
	cmp #ROWS-1					; last line
	bne @l6

	jsr _vram_crs_ptr_write_saved	; restore saved char
	lda #CURSOR_BLANK
	sta saved_char			 	; reset saved_char to blank, cause we scroll up
	;lda #STATE_CURSOR_BLINK
	;trb screen_status		 	; reset cursor state
	jmp textui_scroll_up	; scroll and exit
@l6:
	inc crs_y
	jmp textui_update_crs_ptr


.bss
scroll_buffer_size = 100 ; 40/80 col mode => 1000/2000 chars to copy
scroll_buffer:			.res scroll_buffer_size
screen_status:			.res 1
screen_write_lock:	    .res 1
screen_frames:			.res 1
saved_char:				.res 1
a_r:					.res 2
a_w:					.res 2
