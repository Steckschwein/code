      .importzp ptr1
      .importzp tmp1,tmp2

      .import char_out

      .export crc7

.code

crc = tmp2
polynom = $89
;polynom = $91

poly_shift = <(polynom<<1)

;
;  in:
;     .A/.Y - pointer to input data
;     .X length
;  out:
;     .A calculated crc7
.proc crc7
         cpx #0
         beq @rts
         stx tmp1

         sta ptr1
         sty ptr1+1

         ldy #0
         lda #0   ;crc = 0
@loop:
         ldx #8
         eor (ptr1),y
@loop_x:
         bit #$80          ;
         beq @crc_shift
         asl               ;
         eor #poly_shift   ; crc<<1 ^ polynome<<1
         bra @next
@crc_shift:
         asl               ; crc<<1
@next:
         dex
         bne @loop_x

         iny
         cpy tmp1
         bne @loop

         lsr   ; crc >> 1
@rts:
         rts
.endproc
