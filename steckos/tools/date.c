#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "include/time.cc65_2_17.h"

int main (void)
{
    struct timespec ts;

    clock_gettime(CLOCK_REALTIME, &ts);
    printf ("%s", asctime(localtime(&ts.tv_sec)));

    return EXIT_SUCCESS;
}
