.setcpu "65c02"

.include "common.inc"
.include "system.inc"
.include "appstart.inc"

appstart $0800

.zeropage
p_src:		.res 2
p_tgt:		.res 2

.code
      SetVector biosdata, p_src
      SetVector $e000, p_tgt
      ldy #0
loop:
      lda (p_src),y
      sta (p_tgt),y
      iny
      bne loop
      inc p_src+1
      inc p_tgt+1
      bne loop
      
      ; rom off
      lda #$01
      sta ctrl_port

      ;reset
      jmp ($fffc)
.data
biosdata:
.incbin "bios.bin"