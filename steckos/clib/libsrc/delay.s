;
; extern void __fastcall__ _delay_ms(unsigned int);
;
.export __delay_ms

.importzp tmp1

.include "asminc/system.inc"

.proc __delay_ms

    sta tmp1
    cmp #0
    bne li
    cpx #0
    beq exit
li: inx ;+1
l0:    
    lda tmp1
l1:
    sys_delay_ms 1
    dec a
    bne l1
    dex
    bne l0
exit:
    rts
.endproc
