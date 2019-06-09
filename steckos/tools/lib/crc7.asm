      .setcpu "65c02"
      .importzp ptr1
      .importzp tmp1,tmp2

      .import char_out

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

         stz crc

         lda (ptr1)  ;zero length?
         beq exit

         inc
         sta tmp1 ; data length

         ldy #1
loop:
         ldx #7
loop_x:
         asl crc        ;crc <<= 1;

         lda (ptr1),y   ; crc |= ((data[i] >> x) & 1);
         cpx #0
         beq d_msk

         phx
l0:      lsr
         dex
         bne l0
         plx
d_msk:
         and #$01
         ora crc

         bpl s_crc
         eor #polynom
s_crc:   sta crc

         dex
         bpl loop_x

         iny
         cpy tmp1
         bne loop

         ldx #7
@loop2:
         ;crc <<= 1;
         asl
         bpl @s2_crc
         eor #polynom
@s2_crc:
         sta crc
         dex
         bne @loop2
exit:
         rts
.endproc
