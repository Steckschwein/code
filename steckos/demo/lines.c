#include <graphics.h>
#include <stdlib.h>

int main (int argc, char *argv[])
{
  int i, maxx, maxy;

  initgraph(NULL, 6, NULL);

  maxx = getmaxx();
  maxy = getmaxy();

  setbkcolor(BLACK);
  cleardevice();
  outtextxy(0, 0, "Drawing 1000 lines...");
  for (i = 0; i < 1000; i++) {
    setcolor(1 + random(15));
    line(random(maxx), random(maxy),
         random(maxx), random(maxy));
  }
  getch();
  closegraph();
  return 0;
}