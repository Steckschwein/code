
.export hextodec
.code
; hextodec 8bit hex to decimal converter
; from https://x.com/mrdoornbos/status/1715326394970862020?s=20
    ; accumulator
    ; to
    ; y - hundreds
    ; x - tens
    ; a - ones
hextodec:
    ldy #$2f 
    ldx #$3a
    sec 
:
    iny
    sbc #100
    bcs :- 
:
    dex
    adc #10
    bmi :-
    adc #$2f 
    rts