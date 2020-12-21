/*****************************************************************
 *
 * SYSVbanner.c
 *
 * This is a PD version of the SYS V banner program (at least I think
 * it is compatible to SYS V) which I wrote to use with the clock
 * program written by:
 **     DCF, Inc.
 **     14623 North 49th Place
 **     Scottsdale, AZ 85254
 * and published in the net comp.sources.misc newsgroup in early July
 * since the BSD banner program works quite differently.
 *
 * There is no copyright or responsibility accepted for the use
 * of this software.
 *
 * Brian Wallis, brw@jim.odr.oz, 4 July 1988
 *
 *****************************************************************/

/* Changes by David Frey, david@eos.lugs.ch, 3 February 1997:
 * 1. protoized and indented, 2. changed @ character to #
 */

#include <stdio.h>
#include <string.h>
#include <conio.h>

char *glyphs[] =
{
  "         ###  ### ###  # #   ##### ###   #  ##     ###  ",
  "         ###  ### ###  # #  #  #  ## #  #  #  #    ###   ",
  "         ###   #   # ########  #   ### #    ##      #   ",
  "          #            # #   #####    #    ###     #    ",
  "                     #######   #  #  # ####   # #       ",
  "         ###           # #  #  #  # #  # ##    #        ",
  "         ###           # #   ##### #   ### #### #       ",

  "   ##    ##                                            #",
  "  #        #   #   #    #                             # ",
  " #          #   # #     #                            #  ",
  " #          # ### ### #####   ###   #####           #   ",
  " #          #   # #     #     ###           ###    #    ",
  "  #        #   #   #    #      #            ###   #     ",
  "   ##    ##                   #             ###  #      ",

  "  ###     #    #####  ##### #      ####### ##### #######",
  " #   #   ##   #     ##     ##    # #      #     ##    # ",
  "# #   # # #         #      ##    # #      #          #  ",
  "#  #  #   #    #####  ##### ####### ##### ######    #   ",
  "#   # #   #   #            #     #       ##     #  #    ",
  " #   #    #   #      #     #     # #     ##     #  #    ",
  "  ###   ##### ####### #####      #  #####  #####   #    ",

  " #####  #####    #     ###      #           #     ##### ",
  "#     ##     #  # #    ###     #             #   #     #",
  "#     ##     #   #            #     #####     #        #",
  " #####  ######         ###   #                 #     ## ",
  "#     #      #   #     ###    #     #####     #     #   ",
  "#     ##     #  # #     #      #             #          ",
  " #####  #####    #     #        #           #       #   ",

  " #####    #   ######  ##### ###### ############## ##### ",
  "#     #  # #  #     ##     ##     ##      #      #     #",
  "# ### # #   # #     ##      #     ##      #      #      ",
  "# # # ##     ####### #      #     ######  #####  #  ####",
  "# #### ########     ##      #     ##      #      #     #",
  "#     ##     ##     ##     ##     ##      #      #     #",
  " ##### #     #######  ##### ###### ########       ##### ",

  "#     #  ###        ##    # #      #     ##     ########",
  "#     #   #         ##   #  #      ##   ####    ##     #",
  "#     #   #         ##  #   #      # # # ## #   ##     #",
  "#######   #         ####    #      #  #  ##  #  ##     #",
  "#     #   #   #     ##  #   #      #     ##   # ##     #",
  "#     #   #   #     ##   #  #      #     ##    ###     #",
  "#     #  ###   ##### #    # ########     ##     ########",

  "######  ##### ######  ##### ########     ##     ##     #",
  "#     ##     ##     ##     #   #   #     ##     ##  #  #",
  "#     ##     ##     ##         #   #     ##     ##  #  #",
  "###### #     #######  #####    #   #     ##     ##  #  #",
  "#      #   # ##   #        #   #   #     # #   # #  #  #",
  "#      #    # #    # #     #   #   #     #  # #  #  #  #",
  "#       #### ##     # #####    #    #####    #    ## ## ",

  "#     ##     ######## ##### #       #####    #          ",
  " #   #  #   #      #  #      #          #   # #         ",
  "  # #    # #      #   #       #         #  #   #        ",
  "   #      #      #    #        #        #               ",
  "  # #     #     #     #         #       #               ",
  " #   #    #    #      #          #      #               ",
  "#     #   #   ####### #####       # #####        #######",

  "  ###                                                   ",
  "  ###     ##   #####   ####  #####  ###### ######  #### ",
  "   #     #  #  #    # #    # #    # #      #      #    #",
  "    #   #    # #####  #      #    # #####  #####  #     ",
  "        ###### #    # #      #    # #      #      #  ###",
  "        #    # #    # #    # #    # #      #      #    #",
  "        #    # #####   ####  #####  ###### #       #### ",

  "                                                        ",
  " #    #    #        # #    # #      #    # #    #  #### ",
  " #    #    #        # #   #  #      ##  ## ##   # #    #",
  " ######    #        # ####   #      # ## # # #  # #    #",
  " #    #    #        # #  #   #      #    # #  # # #    #",
  " #    #    #   #    # #   #  #      #    # #   ## #    #",
  " #    #    #    ####  #    # ###### #    # #    #  #### ",

  "                                                        ",
  " #####   ####  #####   ####   ##### #    # #    # #    #",
  " #    # #    # #    # #         #   #    # #    # #    #",
  " #    # #    # #    #  ####     #   #    # #    # #    #",
  " #####  #  # # #####       #    #   #    # #    # # ## #",
  " #      #   #  #   #  #    #    #   #    #  #  #  ##  ##",
  " #       ### # #    #  ####     #    ####    ##   #    #",

  "                       ###     #     ###   ##    # # # #",
  " #    #  #   # ###### #        #        # #  #  # # # # ",
  "  #  #    # #      #  #        #        #     ## # # # #",
  "   ##      #      #  ##                 ##        # # # ",
  "   ##      #     #    #        #        #        # # # #",
  "  #  #     #    #     #        #        #         # # # ",
  " #    #    #   ######  ###     #     ###         # # # #"};


int main(int argc, char **argv)
{
	unsigned char a, b, c, len,ind;
  unsigned char line[81];

  for (argv++; --argc; argv++) {
    len = strlen(*argv);
    if (len > 10)
      len = 10;
    for (a = 0; a < 7; a++) {
      for (b = 0; b < len; b++) {
	if ((ind = (*argv)[b] - ' ') < 0)
	  ind = 0;
	for (c = 0; c < 7; c++) {
	  line[b * 8 + c] = glyphs[(ind / 8 * 7) + a][(ind % 8 * 7) + c];
	}
	line[b * 8 + 7] = ' ';
      }
      for (b = len * 8 - 1; b >= 0; b--) {
	if (line[b] != ' ')
	  break;
	line[b] = '\0';
      }
      //puts(line);
      cprintf("%s\n", line);
    }
    //puts("");
    cprintf("\n");
  }
	
  return 0;
}
