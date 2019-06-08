      .setcpu "65c02"
      .importzp ptr1
      .importzp tmp1,tmp2

      .export crc7

.code

crc = tmp2
polynom = $89
;polynom = $91
;
;  in:
;     .A/.Y - pointer to input data with data length at position 0
;  out:
;     .A calculated crc7
.proc crc7
         sta ptr1
         sty ptr1+1
         lda (ptr1)
         beq @exit

         sta tmp1 ; data length
         stz crc
         ldy #1
@loop:
         ldx #7
@loop_x:
         ;crc <<= 1;
         asl crc
         ; crc |= ((data[i] >> x) & 1);
         jsr _data
         ora crc
         brk
         bpl @s_crc
         eor #polynom
@s_crc:  sta crc

         dex
         bpl @loop_x

         iny
         cpy tmp1
         bcc @loop

         ldx #0
;         lda crc
@loop2:
         ;crc <<= 1;
         asl
         bpl @s2_crc
         eor #polynom
@s2_crc:
         sta crc
         inx
         cpx #7
         bne @loop2

;         lda crc
@exit:
         rts

_data:
         phx
         lda (ptr1),y
@l0:     lsr
         dex
         bne @l0
         and #$01
         plx
         rts
.endproc
