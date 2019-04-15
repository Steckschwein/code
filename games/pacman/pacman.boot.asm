    .export boot

    .import gfx_text
    .import game_state
    .importzp ptr1
    
    .include "pacman.inc"
    
boot:
      sei
      set_irq boot_isr, _save_irq
      cli

      draw_text text_1
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

text_1:
  .byte 8,18,WAIT2,WAIT,"M",WAIT,".",WAIT,"L",WAIT,".",WAIT2," AND ",WAIT2,"S",WAIT,".",WAIT,"W",WAIT,".",0
text_2:
  .byte 10,15,WAIT2,"P",WAIT,"R",WAIT,"E",WAIT,"S",WAIT,"E",WAIT,"N",WAIT,"T",0
text_3:
  .byte 12,21,WAIT,"F",WAIT,"O",WAIT,"R",WAIT," T",WAIT,"H",WAIT,"O",WAIT,"M",WAIT,"A",WAIT,"S",WAIT," W",WAIT,"O",WAIT,"I",WAIT,"N",WAIT,"K",WAIT,"E",0
text_4:
  .byte 14,15,WAIT,"FTW!!!",WAIT2,WAIT2,WAIT2,WAIT2,0