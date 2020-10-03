#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "include/spi.h"

#define UART_DATA_BITS5 0
#define UART_DATA_BITS6 1
#define UART_DATA_BITS7 2
#define UART_DATA_BITS8 3

#define UART_STOP_BITS1 0
#define UART_STOP_BITS2 4

#define UART_PARITY_NONE 0
#define UART_PARITY_ODD  8
#define UART_PARITY_EVEN 24
#define UART_PARITY_MARK 40
#define UART_PARITY_SPACE 56

#define KBD_STATUS 0xe0

void usage(void);

void assertParam(int argc, char **argv) {
   if (!argc || argv[0][0] == '-') {
      usage();
   }
}

void send(unsigned char command, unsigned char value){

   unsigned char r;

   cprintf("send %x %x => ", command, value);
   spi_select(KEYBOARD);
   r = spi_write(command);
   cprintf("%x ", r);
   spi_write(value);
   cprintf("%x\n", r);
   spi_deselect();
}

int main (int argc, char** argv)
{
   unsigned char delay = 0;
   unsigned char rate = 0;

   argc--;
   argv++;
   while(argc>0){
    if (!strcmp(argv[0], "-s"))
   	{
			 unsigned char r = 0;
			 cprintf("\nstatus:");
			 spi_select(KEYBOARD);
			 while((r = spi_write(KBD_STATUS)) != 0xaa){ //0xaa end of status bytes
					cprintf(" %x", spi_write(KBD_STATUS));
			 }
			 spi_deselect();
		}
    else if (!strcmp(argv[0], "-r"))
   	{
         argc--;
         argv++;
         assertParam(argc, argv);
         rate = atoi(argv[0]);
         send(0xf3, rate);
   	}
   	else if (!strcmp(argv[0], "-d"))
   	{
         argc--;
         argv++;
         assertParam(argc, argv);
         delay = atoi(argv[0]);
         send(0xf3, delay);
   	}
   	else if (!strcmp(argv[0], "-led"))
      {
         argc--;
         argv++;
         assertParam(argc, argv);
         send(0xed, (atoi(argv[0]) & 0x07));
      }
      else
   	{
   		usage();
   	}
      argc--;
      argv++;
   }

	return EXIT_SUCCESS;
}

void usage()
{
	cprintf(
        "Usage: keyboard [OPTIONS]...\n\n   -r rate\n   -d delay\n   -led leds\n"
	);
   exit(EXIT_FAILURE);
}
