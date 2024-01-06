;
; unsigned char __fastcall__ read_block(unsigned char *target, unsigned long lba);
;
;
.include "asminc/zeropage.inc"
.include "asminc/debug.inc"
.include "asminc/spi.inc"

.import sd_read_block
.import popax

; .importzp read_blkptr,sreg
.importzp sreg

.export _read_block

.proc _read_block
    sta lba_addr+0
    stx lba_addr+1
    lda sreg           ; 32bit arg, A/X SREG/SREG+1
    sta lba_addr+2
    lda sreg+1
    sta lba_addr+3

    jsr popax
    sta read_blkptr
    stx read_blkptr+1
    jsr sd_read_block
@exit:
    ldx #0
    rts
.endproc
