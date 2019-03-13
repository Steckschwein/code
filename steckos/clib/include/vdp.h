#define ADDRESS_GFX1_SCREEN             0x0000			// name table
#define ADDRESS_GFX1_PATTERN            0x3800
#define ADDRESS_GFX1_COLOR              0x1b80
#define ADDRESS_GFX1_SPRITE             ADDRESS_GFX_SPRITE
#define ADDRESS_GFX1_SPRITE_PATTERN     0x1000

#define ADDRESS_GFX2_SCREEN             0x1800			// name table
#define ADDRESS_GFX2_PATTERN		0x0000
#define ADDRESS_GFX2_COLOR			0x2000
#define ADDRESS_GFX2_SPRITE			ADDRESS_GFX_SPRITE
#define ADDRESS_GFX2_SPRITE_PATTERN     ADDRESS_GFX1_SPRITE_PATTERN



#ifndef _VDP_H
#define _VDP_H 
/*****************************************************************************/
/*                                   Code                                    */
/*****************************************************************************/
void __fastcall__ vdp_memcpy (unsigned int vram_addr, unsigned char bytes, unsigned char *data); 

#endif 