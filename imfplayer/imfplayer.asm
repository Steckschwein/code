
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/kernel/fat32.inc"
.include "../steckos/asminc/filedes.inc"

.include "../steckos/kernel/via.inc"
.include "ym3812.inc"

CPU_CLOCK=clockspeed * 1000000

imf_ptr   = $a0
imf_ptr_h = imf_ptr + 1

delayl    = $a2
delayh    = delayl + 1

irq = $fffe

main:
   		SetVector test_filename, filenameptr
		; copypointer paramptr, filenameptr

		ldy #$00
@l1:	lda (filenameptr),y
		beq @l2
	
		iny
		bra @l1
@l2:
		dey 
		lda (filenameptr),y
		and #%11011111
		cmp #'F'
		beq @l3
		jmp error
@l3:

		dey 
		lda (filenameptr),y
		and #%11011111
		cmp #'L'
		bne @l4

		dey 
		lda (filenameptr),y
		and #%11011111
		cmp #'W'
		bne @l4

		lda #$04
		sta temponr

		lda #'X'
		jsr krn_chrout


@l4:
    	lda filenameptr
    	ldx filenameptr +1

		jsr krn_open

		lda errno	
		jsr krn_hexout

		beq @l5
		jmp error
@l5:
		SetVector imf_data, sd_read_blkptr


;     +Println
; 	+PrintString .loading
		lda #>imf_data
		; jsr krn_hexout
		lda #<imf_data
		; jsr krn_hexout
	
		jsr krn_read    
		lda errno
		beq @l6
		jmp error
@l6:
		jsr krn_close

		plx
		lda fd_area + FD_file_size + 0, x
		jsr krn_hexout
		clc
		adc #<imf_data 
		sta imf_end

		lda fd_area + FD_file_size + 1, x
		jsr krn_hexout
		adc #>imf_data
		sta imf_end+1
    
;     +PrintString .loading_to
	    lda imf_end+1
	    ; jsr krn_hexout
	    lda imf_end
	    ; jsr krn_hexout

	    jmp (retvec)

; 	+Println

; 	+SetVector	imf_data, .imf_ptr
; 	stz .delayl
; 	stz .delayh

	; jsr .init_opl2

	sei
; 	; TODO - set clockspeed according to filename extension
; 	; 560 for imf
; 	; 700 for wlf

; 	; tempo is one of 280Hz (DN2), 560Hz (imf), 700Hz (.wlf) -> 4Mhz
; 	; 280 Hz --> 14280
; 	; 560 Hz -->  7140
; 	; 700 Hz -->  5714
; 	; tempo = 560
	ldx temponr
	lda tempo+0,x

	sta via1t1cl  
	lda tempo+1,x
	sta via1t1ch            ; set high byte of count

    lda #%11000000
	sta via1ier             ; enable VIA1 T1 interrupt
	lda #%01000000          ; T1 continuous, PB7 disabled  
	sta via1acr 

	SetVector player_isr, user_isr
    
    cli

loop:
	jmp loop
; -	jsr keyin
;  	cmp #$03
;  	beq +

;  	cmp #'x'
;  	beq +
;  	bra -
    
; +   sei
;  	lda #%01111111          ; disable T1 interrupt
;     sta via1ier             
; ; SR shift in, External clock on CB1
;     lda #%00001100
;     sta via1acr

;  	+copyPointer old_isr, user_isr
;  	jsr .init_opl2
;  	cli
;  	jmp (retvec)

player_isr:
	lda #$81

	; lda $0230
	; eor #$80
	sta $0230
	bit via1ifr		; Interrupt from VIA?
	bpl @isr_end
	
	bit via1t1cl	; Acknowledge timer interrupt by reading channel low	

@isr_end:
	rts

; 	bit via1t1cl	; Acknowledge timer interrupt by reading channel low	

; 	; delay counter zero? 
; 	lda .delayh    
; 	clc
; 	adc .delayl
; 	beq ++	
	
; 	; if no, 16bit decrement and exit routine
; 	+dec16 .delayh

; 	bra +++
; ++	
; 	ldy #$00
; 	lda (.imf_ptr),y
; 	sta opl_stat
	
; 	iny
; 	lda (.imf_ptr),y

; 	jsr opl2_delay_register

; 	sta opl_data		

; 	; jsr opl2_delay_data

; 	iny
; 	lda (.imf_ptr),y
; 	sta .delayh

; 	iny
; 	lda (.imf_ptr),y
; 	sta .delayl

; 	; song data end reached? then jump back to the beginning
; 	lda .imf_ptr_h
; 	cmp imf_end+1
; 	bne +
; 	lda .imf_ptr
; 	cmp imf_end+0
; 	bne +
; 	+SetVector	imf_data, .imf_ptr
; 	bra +++
; +	

; 	;advance pointer by 4 bytes
; 	clc
; 	lda #$04
; 	adc .imf_ptr
; 	sta .imf_ptr
; 	bcc +
; 	inc .imf_ptr_h
; +	
;     lda #10
;     jsr chrout
;     lda .imf_ptr_h
;     jsr hexout
;     lda .imf_ptr
;     jsr hexout

; +++
;     rts


error:
	jsr krn_hexout
	jsr krn_primm
	.asciiz "load error"
end:	
	jmp (retvec)

tempo:
	.word (CPU_CLOCK/240)
	.word (CPU_CLOCK/560)
	.word (CPU_CLOCK/700)
temponr:
	.byte $02
test_filename:  .asciiz "test.wlf"
; .loading 		!text "Loading from $",$00
; .loading_to		!text " to $",$00
; ; !source <ym3812.a>
; ; !source <t99xx.lib.a>
; old_isr	!16 $ffff
imf_end:	.word $ffff
imf_data:

