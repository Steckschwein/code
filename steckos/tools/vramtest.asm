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
.setcpu "65c02"

.include "common.inc"
.include "vdp.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"

.import hexout
.import hexout_s
.import primm
.importzp ptr2, ptr3

.export char_out=krn_chrout

appstart $1000

VRAM_START=$0000

main:
	lda	#v_reg8_VR ;64K
	sta a_vreg
    vdp_wait_s
	lda #v_reg8
	sta a_vreg

	jsr primm
	.byte $0a, "Video Mem - Address:",0

	; start from 2nd bank, after text ui
	lda #<((VRAM_START+$4000)>>14)
	sta vbank

lbank:
	lda #(>(VRAM_START & $3fff) | WRITE_ADDRESS)
	sta adr_h_w
	ldx #>(VRAM_START & $3fff)
	stx adr_h_r
	ldy #<(VRAM_START & $3fff)
	jsr mem_ca
l2:
	tya
	phy
	ldy adr_h_w

	sei
	jsr set_vaddr
	ply
	lda pattern, x
	vdp_wait_l 10
	sta a_vram
	tya
	phy
	ldy adr_h_r
	vdp_wait_l 12
    ply
    vdp_wait_l 8
	lda a_vram

	cli

	cmp pattern, x
	bne l3

	inx
	cpx #(pattern_e-pattern)		; size of test pattern table
	bne l2
	ldx #0
	iny								; 
	bne l2
	inc adr_h_w	; next 256 byte page
	inc adr_h_r
	jsr mem_ca

	lda	adr_h_r
	cmp	#$40		; 16k reached?
	bne l2

	inc vbank		;vram bank switch
	lda vbank
	cmp #08			;128K ?
	beq l_ok
	jmp lbank

l_ok:
	jsr	primm
	.asciiz " OK"
	jmp	(retvec)

l3:	pha            	;save erroneous pattern
	jsr mem_ca
	lda #' '
	jsr krn_chrout
	pla
	jsr  hexout
	jsr primm
	.asciiz " FAILED"
	jmp (retvec)

mem_ca:	; output current address
	sei
	phy            	; save vram adress low byte
	jsr rset_vbank	; reset vbank (for text output)
	ldx #20			; offset output
	
	lda vbank		; vbank (#reg14) A16-A14
	lsr
	lsr
	jsr hexout_s
	clc
	lda vbank
	and #$03
	ror
	ror
	ror
	ora adr_h_r
	jsr hexout
	pla
	jsr hexout
	cli

	jsr primm
	.byte 27,"[7C",0

	rts


set_vaddr:
	pha
	phy
	lda vbank
	ldy #v_reg14
	vdp_sreg
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


.data
pattern:  .byte $f0,$0f,$96,$69,$a9,$9a,$10,$01
pattern_e:

.bss
adr_h_w:	.res 2
adr_h_r:	.res 2
vbank:	 	.res 1
