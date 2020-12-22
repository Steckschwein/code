#include <stdio.h>
#include <string.h>
#include <unistd.h>

/*****************************************************************************/
/*                                   Code                                    */
/*****************************************************************************/



int __fastcall__ puts (const char* s)
{
    static const char nl = '\n';

    /* Assume stdout is always open */
    if (write (NULL, s, strlen (s)) < 0 ||
        write (NULL, &nl, 1)        < 0) {
//        stdout->f_flags |= _FERROR;
        return -1;
    }

    /* Done */
    return 0;
}



