.export bin2dual
.import char_out
.segment "CODE"

;@module: util
;@name: "bin2dual"
;@in: A, "value to output"
;@desc: "output 8bit value as binary string"
bin2dual:
        pha
        phx
        ldx #$07
@l:
        rol
        bcc @skip
        pha
        lda #'1'
        bra @out
@skip:
        pha
        lda #'0'
@out:
        jsr char_out
        pla
        dex
        bpl @l
        plx
        pla
        rts
