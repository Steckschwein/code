    .export boot

    .import game_state
    .import frame_isr
    
    .include "pacman.inc"
    

boot:
      .ifdef __NO_BOOT
      rts
      .endif
     
      sei
      jsr io_irq_on
      setIRQ frame_isr, _save_irq
      cli
      
      draw_text text_1_0
      draw_text text_1_1
      draw_text text_1_2
      draw_text text_2
      draw_text text_3
      draw_text text_4
      ;draw_text text_5
      ;draw_text text_6

      restoreIRQ _save_irq
      
      rts
      
.data
_save_irq:  .res 2, 0

;    MARKO LAUKE
;        AND
;   STEFAN WEGNER
;      PRESENT
; FOR THOMAS WOINKE
;        FOR
;THOMAS WOINKE / FTW!!!
;MY LOVELY WIFE SUSAN!
text_1_0:
  .byte 6,18,1,2,3,4,WAIT2,WAIT,"M",WAIT,"A",WAIT,"R",WAIT,"K",WAIT,"O ",WAIT,"L",WAIT,"A",WAIT,"U",WAIT,"K",WAIT,"E",0
text_1_1:
  .byte 8,14,WAIT2,"AND",0
text_1_2:
  .byte 10,19,WAIT2,"S",WAIT,"T",WAIT,"E",WAIT,"F",WAIT,"A",WAIT,"N ",WAIT,"W",WAIT,"E",WAIT,"G",WAIT,"N",WAIT,"E",WAIT,"R",0
text_2:
  .byte 12,16,WAIT2,"P",WAIT,"R",WAIT,"E",WAIT,"S",WAIT,"E",WAIT,"N",WAIT,"T",WAIT2,WAIT2,0
text_3:
  .byte 14,14,WAIT2,"F",WAIT,"O",WAIT,"R",WAIT,0
text_4:
  .byte 16,22,WAIT2,"T",WAIT,"H",WAIT,"O",WAIT,"M",WAIT,"A",WAIT,"S",WAIT," W",WAIT,"O",WAIT,"I",WAIT,"N",WAIT,"K",WAIT,"E",WAIT2," / FTW!!!",0
text_5:
  .byte 18,14,WAIT2,"AND",WAIT2,0
text_6:
  .byte 20,22,WAIT2,"M",WAIT,"Y ",WAIT,"L",WAIT,"O",WAIT,"V",WAIT,"E",WAIT,"L",WAIT,"Y ",WAIT,"W",WAIT,"I",WAIT,"F",WAIT,"E ",WAIT,"S",WAIT,"U",WAIT,"S",WAIT,"A",WAIT,"N",WAIT,"!",WAIT2,WAIT2,WAIT2,0
