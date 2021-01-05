
;
; clock_t clock (void);
;

		.include "asminc/rtc.inc"
        .include "asminc/zeropage.inc"

        .export         _clock, __clocks_per_sec
        .importzp		sreg

.proc	_clock

		  lda	  #0
		  sta	  sreg+1
		  sta	  sreg
		  ldx	  #0
		  lda	  rtc_systime_t+time_t::tm_sec ; TODO FIXME just seconds
		  rts

.endproc

; unsigned _clocks_per_sec(void);
;
.proc   __clocks_per_sec

        ldx     #0            ; Clear high byte of return value
        lda     video_mode      
        bpl     @NTSC
        lda     #50
        rts
@NTSC:  lda     #60
        rts

.endproc 
