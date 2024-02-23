#ifndef _GRAPHICS_H
#define _GRAPHICS_H

#include <stdio.h>
#include <vdp/vdp.h>
#include <steckschwein.h>


// The standard Borland 16 colors
#define MAXCOLORS       15
static const enum colors { BLACK, BLUE, GREEN, CYAN, RED, MAGENTA, BROWN, LIGHTGRAY, DARKGRAY,\
              LIGHTBLUE, LIGHTGREEN, LIGHTCYAN, LIGHTRED, LIGHTMAGENTA, YELLOW, WHITE
};

// ---------------------------------------------------------------------------
//                          Definitions
// ---------------------------------------------------------------------------
// Definitions for the key pad extended keys are added here.  When one
// of these keys are pressed, getch will return a zero followed by one
// of these values. This is the same way that it works in conio for
// dos applications.
#define KEY_HOME        71
#define KEY_UP          72
#define KEY_PGUP        73
#define KEY_LEFT        75
#define KEY_CENTER      76
#define KEY_RIGHT       77
#define KEY_END         79
#define KEY_DOWN        80
#define KEY_PGDN        81
#define KEY_INSERT      82
#define KEY_DELETE      83
#define KEY_F1          59
#define KEY_F2          60
#define KEY_F3          61
#define KEY_F4          62
#define KEY_F5          63
#define KEY_F6          64
#define KEY_F7          65
#define KEY_F8          66
#define KEY_F9          67

#define getch() kbhit()

#define getmaxx() vdp_maxx()
#define getmaxy() vdp_maxy()

#define putpixel(x, y, c) vdp_plot(x, y, (c & MAXCOLORS))


#define outtextxy(x, y, s) vdp_textxy(x, y, s)


#define setcolor(color) vdp_setcolor(color<<2)
#define getcolor() vdp_getcolor()

#define settextstyle(font, direction, charsize)
#define setfillstyle(pattern, color)

#define rectangle( left, top, right, bottom ) vdp_rectangle(left, top, right, bottom)
#define floodfill( x, y, border ) vdp_fill(x, y, border)

#define cleardevice() vdp_blank(0)

#define line(x1,y1, x2,y2) vdp_line(x1,y1, x2,y2, getcolor())

#define delay(ms) _delay_ms(ms)

#define closegraph() vdp_restore()

#endif