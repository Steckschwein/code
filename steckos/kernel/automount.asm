      .export __automount
      
      .import primm
      .import init_sdcard
      .import fat_mount
      .import vdp_bgcolor
      
      
      .include "via.inc"
      .include "vdp.inc"
      
.code

__automount:
      lda via1portb
      and #SDCARD_DETECT
      cmp sdcard_state    ; changed?
      sta sdcard_state    
      beq @exit           ; no, exit
      and #SDCARD_DETECT  ; yes, card inserted?
      bne @exit           ; no, exit
@init:                    ; try init and mount otherwise
      jsr init_sdcard
      bne @error
@mount:
      jsr fat_mount
      beq @exit
@error:
      pha
      lda #Dark_Red
      jsr vdp_bgcolor
      jsr primm
      .byte $0a,"automount failed!",$0a,0
      pla
@exit:
      rts

sdcard_state: .res 1,0