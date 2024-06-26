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
  char y;
  int maxx,maxy;

  initgraph(NULL, 3, NULL);
  setbkcolor(BLACK);
  cleardevice();

  maxx = getmaxx();
  maxy = getmaxy();

  do{
    for(x=0;x<=maxx;x++){
      for(y=0;y<maxy;y++){
        putpixel(x,y,x);
        putpixel(maxx-x,y,x);
      }
    }
  } while (!kbhit());

  return EXIT_SUCCESS;


  setcolor(WHITE);
  line(0,0,3,0);
  putpixel(10,10,MAGENTA);

  line(0,24,63,24);
  rectangle(10,10,20,20);


  rectangle(1,2,1,100);
  setcolor(YELLOW);
  rectangle(1,2,100,2);
//  getch();

  for(x=0;x<=15;x++){
    setcolor(x);
    outtextxy(0x10+x<<3, (x<<3), "Hallo Steckschwein!");
  }
//  getch();

  for(x=0;x<=15;x++){
    setfillstyle(0,x);
    bar(10, 10+x*10, 100, 20+x*10);
  }
//  getch();

  for(x=0;x<maxx;x++){
    setcolor(x);
    rectangle(x,x+16,x+32,x+32);
  }

  for(x=0;x<16;x++){
//    getch();
    setbkcolor(x);
    cleardevice();
  }


  return EXIT_SUCCESS;
}