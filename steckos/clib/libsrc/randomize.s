; void _randomize (void);
; /* Initialize the random number generator */
;

        .export         __randomize
        .import         _srand

        .include        "asminc/rtc.inc"

__randomize:
        ldx rtc_systime_t+time_t::tm_sec
        lda rtc_systime_t+time_t::tm_min
        jmp _srand
