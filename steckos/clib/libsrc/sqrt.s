;
; extern short __fastcall__ sqrts(short);
;
.export _sqrts

.importzp tmp1,tmp2
.importzp tmp3,tmp4

.include "asminc/system.inc"
.include "asminc/common.inc"
;
; in:
;   A/X 16bit number
; out:
;   X square root of given number
;   A remainder
;   C carry (bit 8) of the remainder
.proc _sqrts
;      stp
      sta tmp3
      stx tmp4
      STZ tmp1
      STZ tmp2
      LDX #8
@l1:  SEC
      LDA tmp4
      SBC #$40
      TAY
      LDA tmp2
      SBC tmp1
      BCC @l2
      STY tmp4
      STA tmp2
@l2:  ROL tmp1
      ASL tmp3
      ROL tmp4
      ROL tmp2
      ASL tmp3
      ROL tmp4
      ROL tmp2
      DEX
      BNE @l1
      ; ldx #0 ; tmp1
      lda tmp1
      rts
.endproc
