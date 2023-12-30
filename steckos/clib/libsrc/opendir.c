/*
 * steckos adaption
 */
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <dirent.h>
#include <string.h>
#include "dir.h"

#include <conio.h>
/*****************************************************************************/
/*                                   Data                                    */
/*****************************************************************************/
extern char _cwd[FILENAME_MAX];

// from global dirent.h
DIR* __fastcall__ opendir (register const char* name)
{

    register DIR* dir;

    if(strlen(name)>8+3){
		  _directerrno (ENOSYS);
		  return NULL;
	  }

    /* Alloc DIR */
    if ((dir = malloc (sizeof (*dir))) == NULL) {

        /* May not have been done by malloc() */
        _directerrno (ENOMEM);

        /* Return failure */
        return NULL;
    }

    /* Interpret dot as current working directory */
    if (*name == '.') {
        name = _cwd;
    }

    /* Open directory file */
    if ((dir->fd = open (name, O_RDONLY)) != -1) {

          // Skip directory header entry
          //dir->current_entry = 1;
        memcpy(&dir->name, name, 8+3+1);

        printf("%s\n", dir->name);

        // Return success
        return dir;
    }

    // Cleanup DIR
    free (dir);

    //Return failure
    return NULL;
}
