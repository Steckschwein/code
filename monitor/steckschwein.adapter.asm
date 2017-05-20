.include "../steckos/asminc/common.inc"
.include "../steckos/asminc/via.inc"
.include "../steckos/asminc/vdp.inc"
;!src <t9929.h.a>

; general purpose pointer
addr 		= $e0
adrl     	= addr
adrh     	= addr+1
ptr1		= $e2
ptr1l		= ptr1
ptr1h		= ptr1+1
ptr2		= $e4
ptr2l		= ptr2
ptr2h		= ptr2+1 
; general purpose temp variables
tmp0		= $e6
tmp1		= $e7 

init_io:
		;+SetVector RESET, nmivec direct loaded into ROM
		SetVector COUT1, CSWL
		SetVector getkey, KSWL
		rts
		
getkey:
		phx
@l:		lda #%01111010
		sta via1portb
		jsr spi_r_byte
		ldx #%11111110
		stx via1portb
		cmp #$00
		beq @l
		plx
		ora #$80; apple 2 monitor specific
		rts
	
vdp_nopslide:
		rts	;jsr/rts 12

vdp_bgcolor:
		sta   a_vreg
		lda   #v_reg7
		vnops
		sta   a_vreg
		rts
		
scroll_page:
		lda	ptr1l
		sta	a_vreg
		vnops
		lda	ptr1h	; 3cl
		sta	a_vreg
		
		nop			;2
		ldx	tmp0	;3		
@l1:
		nop
		nop
		nop
		lda	a_vram	;4
		sta BUFFER,x	;5
		dex			;2
		bne	@l1		;2/3
		
		vnops
		lda	ptr2l
		sta	a_vreg
		vnops
		lda	ptr2h	; 3
		sta a_vreg	; 4
		
		nop			;2
		ldx	tmp0	;3		

@l2:
		nop			;2
		nop			;2
		nop			;2
		lda	BUFFER,x	;4
		sta	a_vram	;4
		dex			;2
		bne	@l2		;3
		
		inc	ptr2h
		inc	ptr1h
		rts
		
scroll:
		pha
		phx
		
		SetVector	(ADDRESS_GFX1_SCREEN+COLS), ptr1		        ; +COLS - offset second row
		SetVector	(ADDRESS_GFX1_SCREEN+(WRITE_ADDRESS<<8)), ptr2	; offset first row as "write adress"
		
		lda	a_vreg  ; clear v-blank bit, we dont know where we are...
@l:
		bit	a_vreg  ; sync with next v-blank, so that we have the full 4300µs to copy the vram
		vnops
		bpl	@l
		
;		lda	#Gray<<4|Dark_Blue
;		jsr vdp_bgcolor
		
		stz	tmp0
		jsr	scroll_page
		jsr	scroll_page
		jsr	scroll_page
		lda	#192			;40*24 = 960 => 256 * 3 + 192
		sta	tmp0
		jsr	scroll_page
		
		lda	#Gray<<4|Black
		jsr vdp_bgcolor
		
		plx
		pla		
		rts
		
; output char upon CH/CV cursor pointer
;
chrout:						; set the vdp vram adress and write one byte afterwards
		pha
		pha
		
.ifdef CHAR6X8
		lda	CV   		; * 32
		asl
		asl
		asl
		asl
		asl
		ora	CH
		sta	a_vreg
		
		lda CV   		; * 32
		lsr					; div 8 -> page offset 0-2
		lsr
		lsr
		ora	#WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN
		sta a_vreg
.else
		stz	tmp1
		lda CV
		asl
		asl
		asl
		sta tmp0			; save crs_y * 8
		asl		   			; crs_y*16
		rol tmp1		   	; save carry if overflow
		asl					; crs_y*32
		rol tmp1			; again, save carry
		adc tmp0		   	; crs_y*32 + crs_y*8 (crs_ptr) => y*40
		bcc @l
		inc	tmp1			; overflow inc page count
		clc					; 
@l:		adc CH				; add x to address
		sta a_vreg
		lda #(WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN)
		adc	tmp1			; add carry and page to address high byte
		sta	a_vreg
.endif
		pla
		and #$7f
		sta a_vram
		pla
		rts
    
;----------------------------------------------------------------------------------------------
; Receive byte VIA SPI
; Received byte in A at exit
; Destructive: A,Y
;----------------------------------------------------------------------------------------------	
spi_r_byte:
    lda via1portb   ; Port laden
    AND #$fe        ; Takt ausschalten
    TAX             ; aufheben
    ORA #$01

    STA via1portb ; Takt An 1
    STX via1portb ; Takt aus
    STA via1portb ; Takt An 2
    STX via1portb ; Takt aus
    STA via1portb ; Takt An 3
    STX via1portb ; Takt aus
    STA via1portb ; Takt An 4
    STX via1portb ; Takt aus
    STA via1portb ; Takt An 5
    STX via1portb ; Takt aus
    STA via1portb ; Takt An 6
    STX via1portb ; Takt aus
    STA via1portb ; Takt An 7
    STX via1portb ; Takt aus
    STA via1portb ; Takt An 8
    STX via1portb ; Takt aus

    lda via1sr
    rts
