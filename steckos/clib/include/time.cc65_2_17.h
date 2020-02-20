/*
 * v2.17 master back port...
 */
#if (__CC65__ == (2*0x100+17*0x10+0))
struct timespec {
    time_t  tv_sec;
    long    tv_nsec;
};

#define CLOCK_REALTIME 0

/* POSIX function prototypes */
typedef unsigned char clockid_t;

int __fastcall__ clock_getres (clockid_t clock_id, struct timespec *res);
int __fastcall__ clock_gettime (clockid_t clock_id, struct timespec *tp);
int __fastcall__ clock_settime (clockid_t clock_id, const struct timespec *tp);

#endif