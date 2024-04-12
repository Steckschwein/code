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

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

#include <vdp.h>

int main(int argc, char* argv){

  int x;
  int maxx;
  unsigned char y;

  vdp_screen(6);
  vdp_blank(0);

  maxx = vdp_maxx();

  do{
    for(x=0;x<=maxx;x++){
      for(y=0;y<212;y++){
        vdp_plot(x,y,x);

        vdp_setcolor(x);
        vdp_putpixel(maxx-x,y);

      }
      vdp_line(x,0,maxx>>1,96);
      vdp_setcolor(x^0xff);
      vdp_rectangle(x,x+16,x+32,x+32);
    }
  } while (!kbhit());

  return EXIT_SUCCESS;
}