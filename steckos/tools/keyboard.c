#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "include/spi.h"

#define KBD_CMD_STATUS 0xe0

void usage(void);

void assertParam(int argc, char **argv) {
	if (!argc || argv[0][0] == '-') {
		usage();
	}
}

void send(unsigned char command, unsigned char value){

	unsigned char r;

	cprintf("send %x %x => ", command, value);
    __asm__("stp");
	spi_select(KEYBOARD);
	r = spi_write(command);
	cprintf("0x%.2x ", r);
	r = spi_write(value);
	cprintf("0x%.2x\n", r);
	spi_deselect();
}

int main (int argc, char** argv)
{
		unsigned char delay = 0;
		unsigned char rate = 0;

		argc--;
		argv++;
		while(argc>0)
		{
			if (!strcmp(argv[0], "-s"))
			{
				unsigned char r = 0;
				cprintf("\nstatus:");
				__asm__("sei");
				spi_select(KEYBOARD);
				while(1) //0xaa end of status bytes
				{
					r = spi_write(KBD_CMD_STATUS);
					while(r == 0) r = spi_read();
					cprintf(" 0x%02x", r);
					if(r == 0xaa) break;
				}
				spi_deselect();
				__asm__("cli");
				cprintf("\n");
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
		"Usage: keyboard [OPTIONS]...\n\n   -s status (default)\n   -r rate\n   -d delay\n   -led leds\n"
	);
	exit(EXIT_FAILURE);
}
