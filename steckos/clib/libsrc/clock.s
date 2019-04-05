;
; clock_t clock (void);
;

         .include "asminc/rtc.inc"

        .export         _clock
        .importzp       sreg

.proc   _clock

        lda     #0
        sta     sreg+1
        sta     sreg
        ldx     #0
        lda     rtc_systime_t+time_t::tm_sec ; TODO FIXME just seconds
        rts

.endproc
