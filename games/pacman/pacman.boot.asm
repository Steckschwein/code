.export boot

.autoimport

.include "pacman.inc"

boot:
    .ifdef __NO_BOOT
    rts
    .endif

    draw_text text_1, Color_Gray
    draw_text text_2
    draw_text text_3
    draw_text text_4
    rts
.data
;   MARKO LAUKE
;  STEFAN WEGNER
;  THOMAS WOINKE
;    PRESENT
text_1:
  .byte 6,18,TXT_WAIT2,TXT_WAIT,"M",TXT_WAIT,"A",TXT_WAIT,"R",TXT_WAIT,"K",TXT_WAIT,"O ",TXT_WAIT,"L",TXT_WAIT,"A",TXT_WAIT,"U",TXT_WAIT,"K",TXT_WAIT,"E",0
text_2:
  .byte 8,19,TXT_WAIT2,"S",TXT_WAIT,"T",TXT_WAIT,"E",TXT_WAIT,"F",TXT_WAIT,"A",TXT_WAIT,"N ",TXT_WAIT,"W",TXT_WAIT,"E",TXT_WAIT,"G",TXT_WAIT,"N",TXT_WAIT,"E",TXT_WAIT,"R",0
text_3:
  .byte 10,19,TXT_WAIT2,"T",TXT_WAIT,"H",TXT_WAIT,"O",TXT_WAIT,"M",TXT_WAIT,"A",TXT_WAIT,"S",TXT_WAIT," W",TXT_WAIT,"O",TXT_WAIT,"I",TXT_WAIT,"N",TXT_WAIT,"K",TXT_WAIT,"E",TXT_WAIT2,0
text_4:
  .byte 13,16,TXT_WAIT2,"P",TXT_WAIT,"R",TXT_WAIT,"E",TXT_WAIT,"S",TXT_WAIT,"E",TXT_WAIT,"N",TXT_WAIT,"T",TXT_WAIT2,TXT_WAIT2,0
