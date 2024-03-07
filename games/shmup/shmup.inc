.include "steckos.inc"
.include "vdp.inc"


.macro sp_pattern sp, chr
    vdp_vram_w (ADDRESS_GFX3_SPRITE_PATTERN + (sp*32));
    lda #<(font+(chr*8)+0*$200)
    ldy #>(font+(chr*8)+0*$200)
    ldx #8
    jsr vdp_memcpys
    lda #<(font+(chr*8)+2*$200)
    ldy #>(font+(chr*8)+2*$200)
    ldx #8
    jsr vdp_memcpys
    lda #<(font+(chr*8)+1*$200)
    ldy #>(font+(chr*8)+1*$200)
    ldx #8
    jsr vdp_memcpys
    lda #<(font+(chr*8)+3*$200)
    ldy #>(font+(chr*8)+3*$200)
    ldx #8
    jsr vdp_memcpys
.endmacro