.export boot

.autoimport

.include "pacman.inc"

boot:
              .ifndef __NO_BOOT
              draw_text text_0, Color_Gray
              draw_text text_1
              draw_text text_2
              draw_text text_3
              draw_text text_4
              draw_text text_5
              draw_text text_6
              draw_text text_7
              .endif
              rts
.data
; STECKSOFT 2019 (c)
;
;     PRESENTS
;
;   6502 PACMAN
;
; MARKO LAUKE    PRG
; STEFAN WEGNER  SFX
;
;   PORTING TO JC
;    POWERED BY
;
; BRANIK CZECH LAGER

text_0:
  .byte 6,20,TXT_WAIT2,"STECKSOFT 2019 @"
  .byte 0
text_1:
  .byte 9,16,TXT_WAIT2,"P",TXT_WAIT,"R",TXT_WAIT,"E",TXT_WAIT,"S",TXT_WAIT,"E",TXT_WAIT,"N",TXT_WAIT,"T",TXT_WAIT,"S",TXT_WAIT2,TXT_WAIT2,TXT_WAIT2
  .byte 0
text_2:
  .byte 12,18,"6502 PACMAN"
  .byte 0
text_3:
  .byte 15,21,TXT_WAIT2,TXT_WAIT,"M",TXT_WAIT,"A",TXT_WAIT,"R",TXT_WAIT,"K",TXT_WAIT,"O ",TXT_WAIT,"L",TXT_WAIT,"A",TXT_WAIT,"U",TXT_WAIT,"K",TXT_WAIT,"E    ",TXT_WAIT2,"PRG"
  .byte 0
text_4:
  .byte 17,21,TXT_WAIT2,"S",TXT_WAIT,"T",TXT_WAIT,"E",TXT_WAIT,"F",TXT_WAIT,"A",TXT_WAIT,"N ",TXT_WAIT,"W",TXT_WAIT,"E",TXT_WAIT,"G",TXT_WAIT,"N",TXT_WAIT,"E",TXT_WAIT,"R  ",TXT_WAIT2,"SFX"
  .byte 0
text_5:
  .byte 19,18,"PORTING TO JC",TXT_WAIT2
  .byte 0
text_6:
  .byte 20,17,"POWERED BY",TXT_WAIT2
  .byte 0
text_7:
  .byte 22,21,"B",TXT_WAIT,"R",TXT_WAIT,"A",TXT_WAIT,"N",TXT_WAIT,"I",TXT_WAIT,"K",TXT_WAIT," ",TXT_WAIT,"C",TXT_WAIT,"Z",TXT_WAIT,"E",TXT_WAIT,"C",TXT_WAIT,"H",TXT_WAIT," ",TXT_WAIT,"L",TXT_WAIT,"A",TXT_WAIT,"G",TXT_WAIT,"E",TXT_WAIT,"R"
  .byte TXT_WAIT2,TXT_WAIT2,TXT_WAIT2
  .byte 0
