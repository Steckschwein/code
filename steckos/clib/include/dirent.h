/*****************************************************************************/
/*                                                                           */
/*                                 dirent.h                                  */
/*                                                                           */
/*                        Directory entries for cc65                         */
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


#ifndef _DIRENT_H
#define _DIRENT_H



/*****************************************************************************/
/*                                   Data                                    */
/*****************************************************************************/


typedef struct DIR DIR;

struct dirent {
    unsigned char       d_name[8+1+3+1];  // name - trailing 0
    unsigned char       d_attr;

    unsigned int        d_off;
};


/*****************************************************************************/
/*                                   Code                                    */
/*****************************************************************************/



DIR* __fastcall__ opendir (const char* name);

struct dirent* __fastcall__ readdir (DIR* dir);

int __fastcall__ closedir (DIR* dir);

long __fastcall__ telldir (DIR* dir);

void __fastcall__ seekdir (DIR* dir, long offs);

void __fastcall__ rewinddir (DIR* dir);



/* End of dirent.h */
#endif
