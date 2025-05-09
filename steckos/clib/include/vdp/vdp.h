// MIT License
//
// Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#ifndef _VDP_H
#define _VDP_H

#define Color_Transparent    0x00
#define Color_Black          0x01	 //0	0	0		"black"
#define Color_Medium_Green   0x02  //35	203	50		"23
#define Color_Light_Green    0x03	 //96	221	108
#define Color_Dark_Blue      0x04  //84	78	255		"544EFF"
#define Color_Light_Blue     0x05  //125 112 255	"7D70FF"
#define Color_Dark_Red       0x06  //210 84	66		"D25442"
#define Color_Cyan           0x07  //69 232	255		(Aqua Blue)
#define Color_Medium_Red     0x08  //250 89	72 		"FA5948"
#define Color_Light_Red      0x09  //255 124 108	"FF7C6C"
#define Color_Dark_Yellow    0x0a  //211 198 60		"D3C63C"
#define Color_Light_Yellow   0x0b  //229 210 109	"E5D26D"
#define Color_Dark_Green     0x0c  //35 178	44
#define Color_Magenta        0x0d  //200 90	198 	"C85AC6" (Purple)
#define Color_Gray           0x0e  //204 204 204	"CCCCCC"
#define Color_White          0x0f  //255 255 255	"white"

#define SCREEN_BUFFER        0xd000 // screen back buffer

#define ADDRESS_TEXT_SCREEN	    0x0000			// name table
#define ADDRESS_TEXT_PATTERN	0x1000			// pattern table
#define ADDRESS_TEXT_COLOR		0x2000			// color table, v9938/58 "blink" color code vram

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

/*****************************************************************************/
/*                                   Code                                    */
/*****************************************************************************/

void __fastcall__ vdp_memcpy (unsigned char *data, unsigned int vramaddress, unsigned char pages);

void __fastcall__ vdp_screen (unsigned char mode);

int __fastcall__ vdp_maxx();

int __fastcall__ vdp_maxy();

void __fastcall__ vdp_reg (unsigned char reg, unsigned char val);

void __fastcall__ vdp_plot (unsigned int x, unsigned char y, unsigned char color);

void __fastcall__ vdp_putpixel (unsigned int x, unsigned char y);

void __fastcall__ vdp_line(int x1, char y1, int x2, char y2);

void __fastcall__ vdp_rectangle( int left, char top, int right, char bottom );

void __fastcall__ vdp_fill( int x, int y, int border );

int  __fastcall__ vdp_getcolor();
void __fastcall__ vdp_setcolor(unsigned char color);

void __fastcall__ vdp_blank (unsigned char color);

void __fastcall__ vdp_restore(void);

void __fastcall__ vdp_blank (unsigned char color);


#endif
