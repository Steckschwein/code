/*
  !!DESCRIPTION!! mandelbrot test program
  !!ORIGIN!!      testsuite
  !!LICENCE!!     Public Domain
  !!AUTHOR!!      Groepaz/Hitmen
*/

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <vdp.h>

static unsigned short SCREEN_X;
static unsigned char  SCREEN_Y;

static unsigned short SCREEN_X2;
static unsigned char  SCREEN_Y2;

#define maxiterations 50

#define fpshift (12)

#define tofp(_x)        ((_x)<<fpshift)
#define fromfp(_x)      ((_x)>>fpshift)
#define fpabs(_x)       (abs(_x))

#define mulfp(_a,_b)    ((((signed long)_a)*(_b))>>fpshift)
#define divfp(_a,_b)    ((((signed long)_a)<<fpshift)/(_b))

void mandelbrot(signed short x1,signed short y1,signed short x2,signed short y2)
{
register signed short  r,r1,i;
register unsigned char count;
register signed short xs,ys,xx,yy;
register signed short x;
register unsigned char y;
register unsigned char color;


        /* calc stepwidth */
        xs=((x2-x1)/(SCREEN_X));
        ys=((y2-y1)/(SCREEN_Y));

        yy=y1;
        for(y = 0; y <= (SCREEN_Y2); ++y)
        {
                yy+=ys; xx=x1;
                for(x = 0; x < (SCREEN_X); ++x)
                {
                    xx+=xs;
                    /* do iterations */
                    r=0;i=0;
                    for(count=0;(count<maxiterations)&&
                                (fpabs(r)<tofp(2))&&
                                (fpabs(i)<tofp(2))
                                ;++count)
                    {
                            r1 = (mulfp(r,r)-mulfp(i,i))+xx;
                            /*
                            i = (mulfp(mulfp(r,i),tofp(2)))+yy;
                            */
                            i = (((signed long)r*i)>>(fpshift-1))+yy;
                            r=r1;
                    }
                    if(count!=maxiterations)
                    {
                        color= count<<2;
                        vdp_plot(x,y,color);
                        vdp_plot(x,SCREEN_Y-y,color);
                    }
                }
        }
}

int main (void)
{
    SCREEN_X = 256;
    SCREEN_Y = 192;
    SCREEN_Y2 = SCREEN_Y>>1;

    vdp_screen(7);
    vdp_blank(0);

    /* calc mandelbrot set */
    mandelbrot(tofp(-1),tofp(-1),tofp(1),tofp(1));

    while (!kbhit());

    return EXIT_SUCCESS;
}
