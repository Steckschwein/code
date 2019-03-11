#include <stdlib.h>
#include <conio.h>
#include <time.h>
#include "include/time.cc65_2_17.h"

int main (void)
{
    struct timespec ts;

    clock_gettime(CLOCK_REALTIME, &ts);
    cprintf ("%s\n", asctime(localtime(&ts.tv_sec)));

    return EXIT_SUCCESS;
}
