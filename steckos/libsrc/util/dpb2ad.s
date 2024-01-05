.export dpb2ad
.import char_out

.code
dpb2ad:
    sta tmp3
    stx tmp1
    ldy #$00
    sty tmp2
nxtdig:
    ldx #$00
subem:
    lda tmp3
    sec
    sbc subtbl,y
    sta tmp3
    lda tmp1
    iny
    sbc subtbl,y
    bcc adback
    sta tmp1
    inx
    dey
    bra subem

adback:
    dey
    lda tmp3
    adc subtbl,y
    sta tmp3
    txa
    bne setlzf
    bit tmp2
    bmi cnvta
    bpl printspc
setlzf:
    ldx #$80
    stx tmp2

cnvta:
		ora #$30
    jsr char_out
    bra uptbl
printspc:
    lda #' '
    jsr char_out

uptbl:
    iny
    iny
    cpy #08
    bcc nxtdig
    lda tmp3
    ora #$30

		jmp char_out

subtbl:		
    .word 10000
    .word 1000
    .word 100
    .word 10

.bss 
tmp1: .res 1
tmp2: .res 1
tmp3: .res 1
