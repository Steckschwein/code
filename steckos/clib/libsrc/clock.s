
;
; clock_t clock (void);
;

		.include "asminc/rtc.inc"
        .include "asminc/zeropage.inc"

        .import mulax6,mulax5,mulax10
        .importzp sreg

        .export         _clock, __clocks_per_sec

_CPS_PAL=50
_CPS_NTSC=60

.proc	_clock

        ; TODO FIXME gives wrong results on overflow of tm_sec
        jsr __clocks_per_sec
        stx sreg
        stx sreg+1

        cmp #_CPS_NTSC
        lda rtc_systime_t+time_t::tm_sec ; seconds * __clocks_per_sec
        bcs @NTSC  ; >=60 NTSC
        jsr mulax5
        bra :+
@NTSC:
@mul60: jsr mulax6
:       jmp mulax10

.endproc

; unsigned _clocks_per_sec(void);
;
.proc   __clocks_per_sec

        ldx     #0            ; Clear high byte of return value
        lda     video_mode      
        bpl     @NTSC
        lda     #_CPS_PAL
        rts
@NTSC:  lda     #_CPS_NTSC
        rts

.endproc
