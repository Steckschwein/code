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
    rts
.data
;   MARKO LAUKE
;  STEFAN WEGNER
;    PRESENT
text_1:
  .byte 6,18,TXT_WAIT2,TXT_WAIT,"M",TXT_WAIT,"A",TXT_WAIT,"R",TXT_WAIT,"K",TXT_WAIT,"O ",TXT_WAIT,"L",TXT_WAIT,"A",TXT_WAIT,"U",TXT_WAIT,"K",TXT_WAIT,"E"
  .byte 0
text_2:
  .byte 8,19,TXT_WAIT2,"S",TXT_WAIT,"T",TXT_WAIT,"E",TXT_WAIT,"F",TXT_WAIT,"A",TXT_WAIT,"N ",TXT_WAIT,"W",TXT_WAIT,"E",TXT_WAIT,"G",TXT_WAIT,"N",TXT_WAIT,"E",TXT_WAIT,"R"
  .byte 0
text_3:
  .byte 11,16,TXT_WAIT2,"P",TXT_WAIT,"R",TXT_WAIT,"E",TXT_WAIT,"S",TXT_WAIT,"E",TXT_WAIT,"N",TXT_WAIT,"T",TXT_WAIT2,TXT_WAIT2,TXT_WAIT2
  .byte 0
