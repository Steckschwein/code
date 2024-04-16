   .export boot

   .autoimport

   .include "pacman.inc"

boot:
    .ifdef __NO_BOOT
    rts
    .endif

    draw_text text_1_0, 0;Color_Gray
    draw_text text_1_1
    draw_text text_1_2
    draw_text text_2
    draw_text text_3
    draw_text text_4
    ;draw_text text_5
    ;draw_text text_6

    rts
.data
;   MARKO LAUKE
;      AND
;  STEFAN WEGNER
;    PRESENT
; FOR THOMAS WOINKE
;      FOR
;THOMAS WOINKE / FTW!!!
;MY LOVELY WIFE SUSAN!
text_1_0:
  .byte 6,18,TXT_WAIT2,TXT_WAIT,"M",TXT_WAIT,"A",TXT_WAIT,"R",TXT_WAIT,"K",TXT_WAIT,"O ",TXT_WAIT,"L",TXT_WAIT,"A",TXT_WAIT,"U",TXT_WAIT,"K",TXT_WAIT,"E",0
text_1_1:
  .byte 8,14,TXT_WAIT2,"AND",0
text_1_2:
  .byte 10,19,TXT_WAIT2,"S",TXT_WAIT,"T",TXT_WAIT,"E",TXT_WAIT,"F",TXT_WAIT,"A",TXT_WAIT,"N ",TXT_WAIT,"W",TXT_WAIT,"E",TXT_WAIT,"G",TXT_WAIT,"N",TXT_WAIT,"E",TXT_WAIT,"R",0
text_2:
  .byte 12,16,TXT_WAIT2,"P",TXT_WAIT,"R",TXT_WAIT,"E",TXT_WAIT,"S",TXT_WAIT,"E",TXT_WAIT,"N",TXT_WAIT,"T",TXT_WAIT2,TXT_WAIT2,0
text_3:
  .byte 14,14,TXT_WAIT2,"F",TXT_WAIT,"O",TXT_WAIT,"R",TXT_WAIT,0
text_4:
  .byte 16,22,TXT_WAIT2,"T",TXT_WAIT,"H",TXT_WAIT,"O",TXT_WAIT,"M",TXT_WAIT,"A",TXT_WAIT,"S",TXT_WAIT," W",TXT_WAIT,"O",TXT_WAIT,"I",TXT_WAIT,"N",TXT_WAIT,"K",TXT_WAIT,"E",TXT_WAIT2," / FTW!!!",0
text_5:
  .byte 18,14,TXT_WAIT2,"AND",TXT_WAIT2,0
text_6:
  .byte 20,22,TXT_WAIT2,"M",TXT_WAIT,"Y ",TXT_WAIT,"L",TXT_WAIT,"O",TXT_WAIT,"V",TXT_WAIT,"E",TXT_WAIT,"L",TXT_WAIT,"Y ",TXT_WAIT,"W",TXT_WAIT,"I",TXT_WAIT,"F",TXT_WAIT,"E ",TXT_WAIT,"S",TXT_WAIT,"U",TXT_WAIT,"S",TXT_WAIT,"A",TXT_WAIT,"N",TXT_WAIT,"!",TXT_WAIT2,TXT_WAIT2,TXT_WAIT2,0
