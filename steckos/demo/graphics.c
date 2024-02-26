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

#include <graphics.h>

int main(int argc, char* argv){

  int x;
  int y;

  initgraph(NULL, 7, NULL);
  cleardevice();
/*
  for(x=0;x<256;x++){
    for(y=0;y<212;y++){
      vdp_plot(x,y,x);

      vdp_setcolor(x);
      vdp_putpixel(255-x,y);
    }
  }
*/
  for(x=0;x<=15;x++){
    setcolor(x);
    outtextxy(0x10, (x<<3), "Hallo Steckschwein!");
  }
  getch();

  for(x=0;x<=15;x++){
    setcolor(x);
    bar(10, 10+x*10, 100, 20+x*10);
  }
  getch();


  for(x=0;x<255;x++){
    setcolor(x);
    rectangle(x,x+16,x+32,x+32);
  }

  getch();

  return EXIT_SUCCESS;
}