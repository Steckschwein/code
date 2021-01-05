/*
** puts.c
**
** Ullrich von Bassewitz, 11.08.1998
*/



#include <stdio.h>
#include <string.h>
#include <unistd.h>
//#include <_file.h>



/*****************************************************************************/
/*                                   Code                                    */
/*****************************************************************************/



int __fastcall__ puts (const char* s)
{
    static const char nl = '\n';

    /* Assume stdout is always open */
    if (write (NULL, s, strlen (s)) < 0 ||
        write (NULL, &nl, 1)        < 0) {
        //stdout->f_flags |= _FERROR;
        return -1;
    }

    /* Done */
    return 0;
}



