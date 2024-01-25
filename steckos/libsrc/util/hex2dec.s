
.export hextodec
.code
;@module: util
;@name: "hextodec"
;@in: A, "value to convert"
;@out: A, "ones"
;@out: X, "tens"
;@out: Y, "hundreds"
;@desc: "8bit hex to decimal converter"

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