      .export gfx_init
      .export gfx_mode_on
      .export gfx_mode_off
      .export gfx_blank_screen
      .export gfx_sprites_off
      .export gfx_bgcolor
      .export gfx_vblank

      .export gfx_charout
      .export gfx_rotate_pal
      .export gfx_update
      .export gfx_display_maze
      .export gfx_hires_off
      
      
      .import vdp_init_reg
      .import vdp_memcpy
      .import vdp_fill
      
      .import game_state;

      .include "pacman.inc"
.code
gfx_mode_off:
gfx_mode_on:
gfx_rotate_pal:
gfx_write_pal:
gfx_init:
gfx_init_pal:
gfx_init_chars:
gfx_init_sprites:
gfx_blank_screen:
gfx_sprites_off:
gfx_update:
gfx_display_maze:
gfx_charout:
gfx_bgcolor:
gfx_vblank:
gfx_hires_off:  ;?!?

  rts


.data
