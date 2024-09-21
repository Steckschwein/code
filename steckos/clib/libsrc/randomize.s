; void __fastcall__ __randomize (void);
; /* Initialize the random number generator */
;

        .export         ___randomize
        .import         _srand

        .include        "asminc/rtc.inc"

___randomize:
        ldx rtc_systime_t+time_t::tm_sec
        lda rtc_systime_t+time_t::tm_min
        jmp _srand
