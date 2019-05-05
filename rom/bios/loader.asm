      .setcpu "65c02"

      .include "bios.inc"
      
      .importzp ptr3,ptr4
      
.code
      SetVector biosdata, ptr3
      SetVector $e000, ptr4
      ldy #0
loop:
      lda (ptr3),y
      sta (ptr4),y
      iny
      bne loop
      inc ptr3+1
      inc ptr4+1
      bne loop
      
      ; rom off
      lda #$01
      sta ctrl_port

      ;reset
      jmp ($fffc)
.data
biosdata:
.incbin "bios.bin"