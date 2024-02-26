
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <graphics.h>
#include <time.h>

#define ROWS 20
#define COLS 10

//The tetris matrix (2d array)
int board[ROWS][COLS];
//Different versions of T block (rotated)
int t_[8] = { 1, 0, 1, 1, 1, 2, 2, 1 };
int t_90[8] = { 0, 1, 1, 0, 1, 1, 2, 1 };
int t_180[8] = { 0, 1, 1, 0, 1, 1, 1, 2 };
int t_270[8] = { 0, 1, 1, 1, 1, 2, 2, 1 };

//Different versions of L block (rotated)
int l_[8] = { 0, 2, 1, 0, 1, 1, 1, 2 };
int l_90[8] = { 0, 1, 1, 1, 2, 1, 2, 2 };
int l_180[8] = { 1, 0, 1, 1, 1, 2, 2, 0 };
int l_270[8] = { 0, 0, 0, 1, 1, 1, 2, 1 };

//S block

int s_[8] = { 0, 0, 0, 1, 1, 0, 1, 1 };

//Different versions of Z block
int z_[8] = { 1, 1, 1, 2, 2, 0, 2, 1 };
int z_90[8] = { 0, 1, 1, 1, 1, 2, 2, 2 };

//Different versions of I block

int i_ver[8] = { 0, 1, 1, 1, 2, 1, 3, 1 };
int i_hor[8] = { 1, 0, 1, 1, 1, 2, 1, 3 };

//score as string
char *scorestr;
/*
Numbering for type of blocks:
(values of fallingBlockNumber)
0=T
1=L
2=S
3=Z
4=I
*/
//pointer to current falling block type array
int *blockarray;
int fallingblockNum;
int fallingBlockVersion = 0;	//values 0 to 4
int fallingBlockRow = 0;		//the current row of falling block
int fallingBlockCol = 0;		//the current column of falling block
int startdelay = 200;
int motiondelay;
int scoreInc = 5;				//score for each line clearance
int myscore = 0;				//score

int isAtBottom ();

//spawning next falling block
void
NextBlock ()
{
  fallingblockNum = rand () % 5;
  if (fallingblockNum == 0 || fallingblockNum == 1)
	fallingBlockVersion = rand () % 4;
  else if (fallingblockNum == 4 || fallingblockNum == 3)
	fallingBlockVersion = rand () % 2;
  else
	fallingBlockVersion = 0;
  fallingBlockRow = 0;
  fallingBlockCol = 5;
}

//store pointer to current falling block's array in *blockarray;
int *
getFallingBlockArray ()
{
  int a = fallingblockNum * 10 + fallingBlockVersion;
  switch (a)
	{
	case 0:
	  return ((int *) &t_);
	case 1:
	  return ((int *) &t_90);
	case 2:
	  return ((int *) &t_180);
	case 3:
	  return ((int *) &t_270);
	case 10:
	  return ((int *) &l_);
	case 11:
	  return ((int *) &l_90);
	case 12:
	  return ((int *) &l_180);
	case 13:
	  return ((int *) &l_270);
	case 20:
	  return ((int *) &s_);
	case 30:
	  return ((int *) &z_);
	case 31:
	  return ((int *) &z_90);
	case 40:
	  return ((int *) &i_hor);
	case 41:
	  return ((int *) &i_ver);
	}
  return ((int *) &i_ver);
}

/* To check if moving to left or right
or rotation of falling block is feasible.
i.e to check whether there is enough space around it.
*/
int
isDrawable (int newrow, int newcol, int blockversion)
{
  int i, tempversion, flag = 1;;
  tempversion = fallingBlockVersion;
  fallingBlockVersion = blockversion;
  blockarray = getFallingBlockArray ();
  for (i = 0; i < 8; i += 2)
	{
//check if block goes out of the matrix (up or down)

	  if (newrow + blockarray[i] > ROWS-1 || newrow + blockarray[i] < 0)
		{
		  flag = 0;
		  break;
		}
//check if block goes out of the matrix (left or right)

	  if (newcol + blockarray[i + 1] > COLS-1 || newcol + blockarray[i + 1] < 0)
		{
		  flag = 0;
		  break;
		}
//check if there is any obstacle on the proposed position

	  if (board[(newrow + blockarray[i])][(newcol + blockarray[i + 1])] == 2)
		{
		  flag = 0;
		  break;
		}
	}
  fallingBlockVersion = tempversion;
  blockarray = getFallingBlockArray ();
  return flag;
}

/*
To clear the old position of falling block
after it moves to a new position (row/column change)
or after it is rotated
*/
void
clearOldBlockVersion ()
{
  int i, r, c;
  for (i = 0; i < 8; i += 2)
	{
	  r = fallingBlockRow + blockarray[i];
	  c = fallingBlockCol + blockarray[i + 1];
	  board[r][c] = 0;
	  setfillstyle (EMPTY_FILL, BLACK);
	  setcolor (BLACK);
	        bar (2 + c * COLS, 2 + r * COLS, 2 + c * COLS + COLS, 2 + r * COLS + COLS);
	  rectangle (2 + c * COLS, 2 + r * COLS, 2 + c * COLS + COLS, 2 + r * COLS + COLS);
	}
}

/*

To draw the new picture

after it moves to a new position (row/column change)

or after it is rotated

*/

void
drawNewBlockVersion ()
{
  int i, r, c;
  for (i = 0; i < 8; i += 2)
	{
	  r = fallingBlockRow + blockarray[i];
	  c = fallingBlockCol + blockarray[i + 1];
	  board[r][c] = 1;
	  setfillstyle (XHATCH_FILL, CYAN);
	  setcolor (GREEN);
          bar (2 + c * COLS, 2 + r * COLS, 2 + c * COLS + COLS, 2 + r * COLS + COLS);
	  rectangle (2 + c * COLS, 2 + r * COLS, 2 + c * COLS + COLS, 2 + r * COLS + COLS);
	}
}

/*

To check whether game is over.

called after every move.

Game is over when tetris matrix is filled.

*/
int
isGameOver ()
{
  if (isDrawable (0, 5, fallingBlockVersion) == 0)
	return 1;
  drawNewBlockVersion ();
  if (isAtBottom ())
	return 1;
  return 0;
}

/*
To check if falling block reached the bottom
*/
int
isAtBottom ()
{
  int i, max = 0, ti, tj;
  for (i = 0; i < 8; i += 2)
	if (*(blockarray + i) > max)
	  max = *(blockarray + i);
  if (fallingBlockRow + max >= ROWS-1)
	return 1;
  for (i = 0; i < 8; i += 2)
	{
	  ti = *(blockarray + i) + fallingBlockRow;
	  tj = *(blockarray + i + 1) + fallingBlockCol;
	  if (board[ti + 1][tj] == 2)
		return 1;
	}
  return 0;
}

/*
Draw score on screen
*/
void
showScore ()
{
  int left, top;
  setcolor (BLACK);
  setfillstyle (EMPTY_FILL, BLACK);
  left = getmaxx () - 100;
  top = getmaxy()/2;
  bar3d(left,top,left+80,top+70,2,1);
  setcolor(YELLOW);
  settextstyle(TRIPLEX_FONT, HORIZ_DIR,2);
  outtextxy(left, top, "Score: ");
  outtextxy(left, top+20, itoa(++myscore,scorestr,10));
}

/*

To clear any row that is fully filled and increment score.

Also settles rows over the cleared row down.

*/

void
CollapseFullRow ()
{
  int i, j, k, sum, copyskipover = 0, r;
  for (i = ROWS-1; i >= 0;)
	{
	  sum = 0;					//full flag
	  for (j = 0; j < COLS; j++)
		sum += board[i][j];
	  if (sum == 2 * COLS)		//row full
		{
		  myscore += scoreInc;
		  copyskipover++;
		}
	  if (sum == 0)
		break;
	  i--;
	  if (copyskipover > 0)
		{
		  for (j = 0; j < COLS; j++)
			{
			  r = i + copyskipover;
			  board[r][j] = board[i][j];
			  if (board[i][j] == 0)
				{
				  setfillstyle (EMPTY_FILL, BLACK);	//empty yo hatch
				  setcolor (BLACK);
				  bar (2 + j * COLS, 2 + r * COLS, 2 + j * COLS + COLS, 2 + r * COLS + COLS);
				}
			  else
				{
				  setfillstyle (XHATCH_FILL, CYAN);
				  setcolor (GREEN);
				  bar (2 + j * COLS, 2 + r * COLS, 2 + j * COLS + COLS, 2 + r * COLS + COLS);
				  rectangle (2 + j * COLS, 2 + r * COLS, 2 + j * COLS + COLS, 2 + r * COLS + COLS);
				}
			}
		}
	}
  for (k = 0; k < copyskipover; k++)
	{
	  r = i + k;
	  for (j = 0; j < COLS; j++)
		{
		  board[r][j] = 0;
		  setfillstyle (XHATCH_FILL, BLACK);
		  setcolor (BLACK);
		  bar (2 + j * COLS, 2 + r * COLS, 2 + j * COLS + COLS, 2 + r * COLS + COLS);
		}
	}
  showScore ();
}

//function to display game over and end game
void GameOver ();

int main ()
{
  int scorespeedctrl;
  char arrowpre, ch, timehalving;
  //int gd = DETECT, gm, i, j, k = 1, spawn = 1, tversion;
  int i, j, k, spawn, tversion;
  scorestr = (char *) malloc (sizeof (char) * 10);

restart:
  scorespeedctrl = 0;
  timehalving = 0;
  k = 1;
  spawn = 1;
  motiondelay = startdelay;

  for (i = 0; i < ROWS; i++)
	  for (j = 0; j < COLS; j++)
	    board[i][j] = 0;
/*
to get the ascii characters for up arrow key.
When any of arrow key is pressed, two characters
are sent to buffer. The first one may be different
on different compilers and systems.
The second one is of value 72 for up arrow.

  while (k != KEY_UP)
	{
	  printf ("press 'up' arrow key to start\n");
	  arrowpre = getch ();
	  if (kbhit ())
		  k = getch ();
	}
*/
  //initgraph (&gd, &gm, "C:\\TURBOC3\\BGI\\");
  initgraph (NULL, 7, NULL);
  cleardevice ();

  setcolor (YELLOW);
  rectangle (0, 0, COLS * COLS + 3, ROWS * COLS + 3);
  srand (time (NULL));
  showScore ();
  setcolor (RED);
  settextstyle (SMALL_FONT, HORIZ_DIR, 6);
  outtextxy (getmaxx () - 144, getmaxy () / 2 - 25, "Press 'Q' to quit.");

  while (ch != 'q' && ch != 'Q' && k != 'q' && k != 'Q')
	{
	  if (kbhit () && spawn == 0)
		{
		  k = getch ();
		  if (1) //ch == arrowpre)	//if an arrow key pressed
			{
			  //k = getch ();
			  if (k == KEY_UP)		//if up arrow key is pressed
				{
				  if (fallingblockNum == 0 || fallingblockNum == 1)
					tversion = (fallingBlockVersion + 1) % 4;
				  else if (fallingblockNum == 4 || fallingblockNum == 3)
					tversion = (fallingBlockVersion + 1) % 2;

				  if (fallingblockNum != 2
					  && isDrawable (fallingBlockRow, fallingBlockCol,
									 tversion))
					{
					  clearOldBlockVersion ();
					  fallingBlockVersion = tversion;
					  blockarray = getFallingBlockArray ();
					  drawNewBlockVersion ();
					}
				}
			  else if (k == KEY_LEFT)	//if left arrow key is pressed

				{
				  if (isDrawable
					  (fallingBlockRow, fallingBlockCol - 1,
					   fallingBlockVersion))
					{
					  clearOldBlockVersion ();
					  fallingBlockCol--;
					  drawNewBlockVersion ();
					}
				}
			  else if (k == KEY_RIGHT)	//if right arrow key is pressed
				{
				  if (isDrawable
					  (fallingBlockRow, fallingBlockCol + 1,
					   fallingBlockVersion))
					{
					  clearOldBlockVersion ();
					  fallingBlockCol++;
					  drawNewBlockVersion ();
					}
				}
			  else if (k == KEY_DOWN)	//if down arrow key is pressed
				{
				  if (isDrawable
					  (fallingBlockRow + 1, fallingBlockCol,
					   fallingBlockVersion))
					{
					  clearOldBlockVersion ();
					  fallingBlockRow++;
					  drawNewBlockVersion ();
					}
				}
			  while (kbhit ())
				  getch ();
			}
		}
	  if (isAtBottom () && spawn == 0)
		{
		  for (i = 0; i < 8; i += 2)
			{
			  board[fallingBlockRow + blockarray[i]][fallingBlockCol +
													 blockarray[i + 1]] = 2;
			}
		  spawn = 1;
		  CollapseFullRow ();
		}
	  if (spawn)
		{
		  NextBlock ();
		  blockarray = getFallingBlockArray ();
		  spawn = 0;
		  if (isGameOver ())
			{
			  GameOver ();
			  goto restart;
			}
		}
	  else
		{
		  timehalving = (timehalving + 1) % 3;
		  if (timehalving == 2)
			{
			  clearOldBlockVersion ();
			  fallingBlockRow++;
			  drawNewBlockVersion ();
			}
		}
	  scorespeedctrl = (scorespeedctrl + 1) % 280;
	  if (scorespeedctrl == 0)
		{
		  motiondelay -= 8;
		  scoreInc++;
		}
	  delay (motiondelay);
	}
  return EXIT_SUCCESS;
}

void
GameOver ()
{
  static int style = 0; // TRIPLEX_FONT;
  static int size = 4;
  setcolor (YELLOW);
  settextjustify (CENTER_TEXT, CENTER_TEXT);
  settextstyle (style, HORIZ_DIR, size);
  outtextxy (getmaxx () / 2 - 10, getmaxy () / 2, "Game Over.\n");
  getch ();
}
