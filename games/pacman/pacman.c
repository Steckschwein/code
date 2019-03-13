#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

#include <vdp.h>
#include "pacman.sprites.xpm"

int main (int argc, const char* argv[])
{
  unsigned int i;
  unsigned int l;
  unsigned char *c;
  
//  cprintf("\n%d", sizeof(pacman_sprites_xpm));
  for(i=0;i<sizeof(pacman_sprites_xpm)/sizeof(unsigned char*);i++){
    cprintf("\n");
    for(l=0;(c=pacman_sprites_xpm[i][l]) != NULL;l++){
      cprintf("%c", c);
    }
  }
//  vdp_memcpy(ADDRESS_GFX2_SPRITE_PATTERN, 256, );
  
  
  return EXIT_SUCCESS;
}