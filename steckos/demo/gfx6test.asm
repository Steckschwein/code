      .include "steckos.inc" 
      .include "vdp.inc" 

      .import vdp_gfx6_on
      .import vdp_gfx6_blank
      .import vdp_fill
      
appstart

.code
    
    jsr	krn_textui_disable			;disable textui 
    
    jsr vdp_gfx6_on
    
    lda #Black<<4|Black
    jsr vdp_gfx6_blank
    
    vdp_vram_r ADDRESS_TEXT_PATTERN
    vdp_vram_w ADDRESS_GFX6_SCREEN
    lda $0300;#Cyan<<4
    ldx #192  ;lines
    jsr vdp_fill
    keyin
    
    jsr	krn_textui_init
    
		jmp (retvec) 
    
.data
charset:
    .include "../bios/charset_8x8.asm"