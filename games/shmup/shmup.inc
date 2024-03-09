.include "steckos.inc"
.include "vdp.inc"

.macro sp_pattern sp, chr
    vdp_vram_w (ADDRESS_GFX3_SPRITE_PATTERN + (sp*32));
    lda #<(chars_2x2_numbers+(chr*8)+0*$80)
    ldy #>(chars_2x2_numbers+(chr*8)+0*$80)
    ldx #8
    jsr vdp_memcpys
    lda #<(chars_2x2_numbers+(chr*8)+2*$80)
    ldy #>(chars_2x2_numbers+(chr*8)+2*$80)
    ldx #8
    jsr vdp_memcpys
    lda #<(chars_2x2_numbers+(chr*8)+1*$80)
    ldy #>(chars_2x2_numbers+(chr*8)+1*$80)
    ldx #8
    jsr vdp_memcpys
    lda #<(chars_2x2_numbers+(chr*8)+3*$80)
    ldy #>(chars_2x2_numbers+(chr*8)+3*$80)
    ldx #8
    jsr vdp_memcpys
.endmacro