
.include "steckos.inc"

appstart $1000           

.code
    ldx #0
@loop:
    lda hellorld,x 
    beq @exit
    jsr krn_chrout
    inx 
    bne @loop

@exit:
    jmp (retvec)
.data
hellorld:   .asciiz "Hellorld!"