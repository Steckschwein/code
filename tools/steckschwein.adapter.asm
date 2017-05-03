!src <defs.h.a>
!src <t9929.h.a>
!src "../steckos/asminc/via.inc"
;!src "../steckos/asminc/vdp.inc"

;!src "../bios/vdp.a"
!src "../bios/bios_call.inc"

.init_io
    +SetVector RESET, nmivec
    +SetVector COUT1, CSWL
    +SetVector .getkey, KSWL
    jmp init_vdp
    
.getkey
	phx
-	lda #%01111010
	sta via1portb
	jsr .spi_r_byte
	ldx #%11111110
	stx via1portb
    cmp #$00
    beq -
	plx
    ora #$80; apple 2 monitor specific
    rts 
    
; output char upon CH/CV cursor pointer
;
.chrout2
    pha
                    ; set the vdp vram adress to write one byte afterwards
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
	ora	#.WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN
	sta a_vreg
    
    pla
    and #$7f    
    sta a_vram
    
    rts
    
;----------------------------------------------------------------------------------------------
; Receive byte VIA SPI
; Received byte in A at exit
; Destructive: A,Y
;----------------------------------------------------------------------------------------------	
.spi_r_byte
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
