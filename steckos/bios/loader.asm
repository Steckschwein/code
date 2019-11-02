      .setcpu "65c02"

      .include "common.inc"
      .include "system.inc"
      
src=$0
tgt=$2
.code
      SetVector biosdata, src
      SetVector $e000, tgt
      ldy #0
loop:
      lda (src),y
      sta (tgt),y
      iny
      bne loop
      inc src+1
      inc tgt+1
      bne loop
      
      ; rom off
      lda #$01
      sta ctrl_port

      ;reset
      jmp ($fffc)
.data
biosdata:
.incbin "bios.bin"