/*
** from vendor sleep.c
*/
#define CLOCKS_PER_SEC _clocks_per_sec()
extern unsigned _clocks_per_sec(void);

#include <time.h>

/* We cannot implement this function without a working clock function */
#if defined(CLOCKS_PER_SEC)
unsigned __fastcall__ sleep (unsigned wait)
{
    clock_t goal = clock () + ((clock_t) wait) * CLOCKS_PER_SEC;
    while ((long) (goal - clock ()) > 0) ;
    return 0;
}
#endif
