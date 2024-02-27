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



#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <unistd.h>

#include <dirent.h>
#include <dir.h>

/*****************************************************************************/
/*                                   Code                                    */
/*****************************************************************************/

void fat_name(register DIR* d, char* t){

    unsigned char i, j = 0;
    unsigned char c;
    for(i=0;i<sizeof(((DIR *)0)->f32_dirent.name);i++){
      c = d->f32_dirent.name[i];
      if(c == ' '){
        break;
      }
      t[j++] = c;
    }
    for(i=0;i<sizeof(((DIR *)0)->f32_dirent.ext);i++){
      c = d->f32_dirent.ext[i];
      if(c == ' '){
        break;
      }else if (i == 0) {
        t[j++] = '.';
      }
      t[j++] = c;
    }
    t[j] = 0;
}



struct dirent* __fastcall__ readdir (register DIR* dir)
{
    register struct dirent* entry = &dir->current_entry;

    if (read(dir->fd, &dir->f32_dirent, sizeof(dir->f32_dirent)) != sizeof(dir->f32_dirent)) {
      /* Just return failure as read() has */
      /* set errno if (and only if) no EOF */
      return NULL;
    }

    if(dir->f32_dirent.name[0] == 0){ // eod?
      return NULL;
    }

    fat_name(dir, entry->d_name);

    //printf("dirent: %d %s\n", strlen(entry->d_name), entry->d_name);

    entry->d_off = dir->off;
    entry->d_attr = dir->f32_dirent.attr;

    dir->off += sizeof(dir->f32_dirent);

    /* Return success */
    return entry;
}
