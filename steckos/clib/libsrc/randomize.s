;
; /* Initialize the random number generator */
; void _randomize (void);
;
      .include "asminc/rtc.inc"

      .export __randomize

      .import _srand

;--------------------------------------------------------------------------
; _random
__randomize:
      ldx rtc_systime_t+time_t::tm_min
      lda rtc_systime_t+time_t::tm_sec
      jmp _srand
