
      .include "steckos.inc"
      .include "keyboard.inc"
      .include "via.inc"

      .export char_out = krn_chrout
.code
      lda via1portb
      sta sdcard
      and #SDCARD_DETECT
      beq :+
      jsr krn_primm
      .byte "no sdcard inserted!",KEY_LF,0
      bra @exit
:     
      jsr krn_primm
      .byte "sdcard available. going to init... ",0
      jsr krn_init_sdcard
      beq :+
      jsr krn_primm
      .byte "ERROR",KEY_LF,0
      bra @exit
      
:
      jsr krn_primm
      .byte "OK",KEY_LF,0
      
      lda sdcard
      and #SDCARD_WRITE_PROTECT
      beq :+
      jsr krn_primm
      .byte "sdcard write protected, mounting read only.",KEY_LF,0
:
      lda via1portb
      .import hexout
      jsr hexout
      
@exit:
      jmp (retvec)
.bss
  sdcard: .res 1
  