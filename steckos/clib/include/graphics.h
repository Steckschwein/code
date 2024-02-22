
#include <stdio.h>
#include <vdp/vdp.h>
#include <steckschwein.h>


// The standard Borland 16 colors
#define MAXCOLORS       15
static const enum colors { BLACK, BLUE, GREEN, CYAN, RED, MAGENTA, BROWN, LIGHTGRAY, DARKGRAY,\
              LIGHTBLUE, LIGHTGREEN, LIGHTCYAN, LIGHTRED, LIGHTMAGENTA, YELLOW, WHITE
};


#define getch(void) getchar(void)

#define putpixel(x, y, c) vdp_plot(x, y, (c & MAXCOLORS))

#define outtextxy(x, y, c) vdp_textxy(x, y, c)

#define setcolor(c) vdp_setcolor(c)
#define getcolor() vdp_getcolor()

#define line(x1,y1, x2,y2) vdp_line(x1,y1, x2,y2, getcolor())

#define delay(ms) _delay_ms(ms)

#define closegraph() vdp_restore()