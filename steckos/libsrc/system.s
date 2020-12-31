.include "vdp.inc"
.include "ym3812.inc"
.include "via.inc"

.export system_irr

.code

; collect irq sources
;  out:  .A - with individual bits set for collected IRQ's. bit masks in system.inc
system_irr:
   lda #0           ; irr status
   bit a_vreg       ; Interrupt from VDP?
   bpl @is_irq_snd
   ora #IRQ_VDP
@is_irq_snd:
   bit opl_stat     ; Interrupt from OPL?
   bpl @is_irq_via
   ora #IRQ_SND
@is_irq_via:
   bit via1ifr      ; Interrupt from VIA?
   bpl @exit
   ora #IRQ_VIA
   
@exit:
   rts
