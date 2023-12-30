/*****************************************************************************/
/*                                                                           */
/*                                readdir.c                                  */
/*                                                                           */
/*                           Read directory entry                            */
/*                                                                           */
/*                                                                           */
/*                                                                           */
/* (C) 2005  Oliver Schmidt, <ol.sc@web.de>                                  */
/*                                                                           */
/*                                                                           */
/* This software is provided 'as-is', without any expressed or implied       */
/* warranty.  In no event will the authors be held liable for any damages    */
/* arising from the use of this software.                                    */
/*                                                                           */
/* Permission is granted to anyone to use this software for any purpose,     */
/* including commercial applications, and to alter it and redistribute it    */
/* freely, subject to the following restrictions:                            */
/*                                                                           */
/* 1. The origin of this software must not be misrepresented; you must not   */
/*    claim that you wrote the original software. If you use this software   */
/*    in a product, an acknowledgment in the product documentation would be  */
/*    appreciated but is not required.                                       */
/* 2. Altered source versions must be plainly marked as such, and must not   */
/*    be misrepresented as being the original software.                      */
/* 3. This notice may not be removed or altered from any source              */
/*    distribution.                                                          */
/*                                                                           */
/*****************************************************************************/



#include <stddef.h>
#include <unistd.h>
#include <dirent.h>
#include "dir.h"



/*****************************************************************************/
/*                                   Code                                    */
/*****************************************************************************/



struct dirent* __fastcall__ readdir (register DIR* dir)
{
    register unsigned char* entry;

    if (read (dir->fd, NULL, 0)) {

        /* Just return failure as read() has */
        /* set errno if (and only if) no EOF */
        return NULL;
    }

    /* Return success */
    return (struct dirent*)&entry[0x01];
}
