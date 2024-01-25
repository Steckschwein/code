/*
** Internal include file, do not use directly.
** Written by Ullrich von Bassewitz. Based on code by Groepaz.
*/



#ifndef _DIR_H
#define _DIR_H



#include <dirent.h>



/*****************************************************************************/
/*                                   Data                                    */
/*****************************************************************************/



struct DIR {

    int fd;                   /* File descriptor for directory */
    char      name[8+1+3 +1]; /* Name passed to opendir */
    unsigned long off;        /* Current byte offset in directory */

    struct dirent current_entry;

    struct {
      unsigned char       name[8];  // fat32 name
      unsigned char       ext[3];   // fat32 ext
      unsigned char       attr;
      char                res;
      unsigned char       crt_ms;
      unsigned int        crt_time; // fat 32 create time
      unsigned int        crt_date; // fat 32 create date
      unsigned int        lmd; // fat 32 last modified

      unsigned int        cl_h; // fat 32 cluster high word

      unsigned int        wrt_time; // fat 32 create time
      unsigned int        wrt_date; // fat 32 create date

      unsigned int        cl_l; // fat 32 cluster low word

      unsigned long       fsize;

    } f32_dirent;

};


/*****************************************************************************/
/*                                   Code                                    */
/*****************************************************************************/



unsigned char __fastcall__ _dirread (DIR* dir, void* buf, unsigned char count);
/* Read characters from the directory into the supplied buffer. Makes sure,
** errno is set in case of a short read. Return true if the read was
** successful and false otherwise.
*/

/* End of dir.h */
#endif
