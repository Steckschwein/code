    .export boot

    .import gfx_text
    .import game_state
    .importzp ptr1
    
    .include "pacman.inc"
    
boot:
      .if DEBUG = 1
      rts
      .endif
      
      sei
      set_irq boot_isr, _save_irq
      cli

      draw_text text_1_0
      draw_text text_1_1
      draw_text text_1_2
      draw_text text_2
      draw_text text_3
      draw_text text_4

      sei
      restore_irq _save_irq
      cli
      
      rts

boot_isr:
      save
      bit	a_vreg
      bpl	@exit
      
      bgcolor Color_Yellow
      
      inc game_state+GameState::frames
@exit:
      bgcolor Color_Bg

      restore
      rti

.data
_save_irq:  .res 2, 0

;   MARKO LAUKE
;       AND
;  STEFAN WEGNER
;     PRESENT
;FOR THOMAS WOINKE
;      FTW!!!

text_1_0:
  .byte 6,18,WAIT2,WAIT,"M",WAIT,"A",WAIT,"R",WAIT,"K",WAIT,"O ",WAIT,"L",WAIT,"A",WAIT,"U",WAIT,"K",WAIT,"E",0
text_1_1:
  .byte 8,14,WAIT2,"AND",0
text_1_2:
  .byte 10,19,WAIT2,"S",WAIT,"T",WAIT,"E",WAIT,"F",WAIT,"A",WAIT,"N ",WAIT,"W",WAIT,"E",WAIT,"G",WAIT,"N",WAIT,"E",WAIT,"R",0
text_2:
  .byte 12,16,WAIT2,"P",WAIT,"R",WAIT,"E",WAIT,"S",WAIT,"E",WAIT,"N",WAIT,"T",WAIT2,0
text_3:
  .byte 14,21,WAIT2,"F",WAIT,"O",WAIT,"R",WAIT," T",WAIT,"H",WAIT,"O",WAIT,"M",WAIT,"A",WAIT,"S",WAIT," W",WAIT,"O",WAIT,"I",WAIT,"N",WAIT,"K",WAIT,"E",0
text_4:
  .byte 16,15,WAIT,"FTW!!!",WAIT2,WAIT2,WAIT2,WAIT2,0