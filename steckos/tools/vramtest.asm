.include "common.inc"
.include "vdp.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"

.import hexout
.importzp ptr2, ptr3

appstart $1000


VRAM_START=$0000

main:
	lda	#v_reg8_SPD | v_reg8_VR
	sta a_vreg
	lda #v_reg8
	sta a_vreg
	
	jsr krn_primm
	.byte $0a, "Video Mem:$",0

	lda #1		; start at vram $4000
	sta vbank

lbank:	
	lda #(WRITE_ADDRESS+>VRAM_START)
	sta adr_h_w
	ldx #>VRAM_START
	stx adr_h_r
	ldy #<VRAM_START
	jsr mem_ca
l2:
	tya
	phy
	ldy adr_h_w	

	sei
	jsr set_vaddr
	ply
	lda pattern, x
	vnops
	sta a_vram
	tya
	phy
	vnops
	ldy adr_h_r	
	jsr set_vaddr
	ply
	vnops
	
	lda a_vram
	
	jsr rset_vbank		; reset vbank - TODO FIXME, kernel has to make sure that correct video adress is set for all vram operations, use V9958 flag
	cli
	
	cmp pattern, x
	bne l3
	
	inx
	cpx   #(pattern_e-pattern)		; size of test pattern table
	bne   l2
	ldx   #0
	iny
	bne   l2
	inc   adr_h_w	; next 256 byte page
	inc   adr_h_r
	jsr   mem_ca
	
	lda	adr_h_r
	cmp	#$40		; 16k reached?
	bne l2
	
	inc vbank		;vram bank switch
	lda vbank
	cmp #08			;128K ?
	beq l_ok
	jmp lbank
	
l_ok:
	jsr	krn_primm
	.asciiz " OK"
	jmp	(retvec)
		
l3:	pha            	;save erroneous pattern
		jsr   mem_ca
		lda   #' '
		jsr   krn_chrout
		pla   
		jsr   hexout
		jsr krn_primm
		.asciiz " FAILED"
	jmp (retvec)

mem_ca:	; output value
	phy            	;save vram adress low byte
	ldx #11			; offset output
	ldy crs_y
	jsr krn_textui_crsxy
	lda vbank
	jsr hexout
	lda   #' '
	jsr   krn_chrout
	lda adr_h_r
	jsr hexout
	pla
	jsr hexout
	rts


set_vaddr:
	pha
	phy
	lda vbank
	ldy #v_reg14
	vdp_sreg
	vnops
	ply
	pla
	vdp_sreg
	rts

rset_vbank:
	pha
	phy
	lda #0
	ldy #v_reg14
	vdp_sreg	
	ply
	pla
	rts
	
   
pattern:  .byte $f0,$0f,$96,$69,$a9,$9a,$00,$ff
pattern_e:

adr_h_w:	.res 2
adr_h_r:	.res 2
vbank:	 	.res 1

m_vdp_nopslide