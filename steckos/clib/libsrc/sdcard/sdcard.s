;
; unsigned char __fastcall__ read_block(unsigned char *target, unsigned long lba);
;
;
.include "asminc/zeropage.inc"
.include "asminc/debug.inc"
.include "asminc/spi.inc"

.import sd_read_block
.import popax

.importzp sd_blkptr,sreg

.export _read_block

.proc _read_block
    sta lba_addr+0
    stx lba_addr+1
    lda sreg           ; 32bit arg, A/X SREG/SREG+1
    sta lba_addr+2
    lda sreg+1
    sta lba_addr+3

    jsr popax
    sta sd_blkptr
    stx sd_blkptr+1
    jsr sd_read_block
    ldx #0
    bcs @exit
    txa
@exit:
    rts
.endproc
