#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "include/spi.h"
#include "include/rtc.h"
#include "include/util/crc7.h"


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

void usage(void);
void read_nvram(void);
void init_nvram(void);
void write_nvram(void);
unsigned long int lookup_divisor(unsigned char);
unsigned char lookup_baudrate(unsigned long int);
unsigned char get_databits(unsigned char);
unsigned char get_parity(unsigned char);
unsigned char get_stopbits(unsigned char);
unsigned char make_line_byte(unsigned char *);
int get_kbrd_repeat(unsigned char);
int get_kbrd_delay(unsigned char);

struct nvram
{
    unsigned char version;
    unsigned char filename[13];
    unsigned char uart_baudrate;
    unsigned char uart_lsr;
    unsigned char keyboard_tm;
    unsigned char crc7;
};

struct baudrate
{
    unsigned char divisor;
    unsigned long int baudrate;
};

const struct baudrate baudrates[] = {
    {192,	600},
    {96,	1200},
    {48,	2400},
    {32,	3600},
    {12,	9600},
    {6,		19200},
    {3,		38400L},
    {2,		56000L},
    {1,		115200}
};


unsigned char i,j,x;
struct nvram n;
unsigned long l;

int main (int argc, const char* argv[])
{
    unsigned char crc;

    read_nvram();

    crc = crc7((unsigned char *)&n, sizeof(struct nvram)-1);

    if (n.crc7 != crc)
    {
        cprintf("NVRAM CRC7 mismatch - CRC: %0x, NVRAM: %0x\n", crc, n.crc7);
        cprintf("Please init with\n  nvram init\n");
    }

	if (strcmp(argv[1], "filename") == 0)
	{
        if (argc == 3)
        {
            if (strlen(argv[2]) > 13)
			{
				cprintf("\r\nInvalid filename\r\n");
				return 1;
			}

            sprintf(n.filename, "%s\0", argv[2]);
		    write_nvram();

        }
		cprintf("%.*s\r\n", 11, n.filename);
	}
	else if (strcmp(argv[1], "baudrate") == 0)
	{
        if (argc == 3)
        {
			unsigned char divisor = lookup_baudrate(atol(argv[2]));
			if (divisor == 0)
			{
				cprintf("Invalid baudrate\r\n");
				return 1;
			}

			n.uart_baudrate = divisor;
		    write_nvram();
        }
		cprintf("%ld\r\n", lookup_divisor(n.uart_baudrate));
	}
	else if (strcmp(argv[1], "line") == 0)
	{
        if (argc == 3)
        {
            unsigned char lsr;
            lsr = make_line_byte((unsigned char *)argv[3]);
            if (lsr == 0xff)
            {
                cprintf("Parameter error\n");
                return EXIT_FAILURE;
            }
            n.uart_lsr = lsr;
            write_nvram();
        }

		cprintf("%c%c%c\n",
            get_databits(n.uart_lsr),
            get_parity(n.uart_lsr),
            get_stopbits(n.uart_lsr)
        );
	}
   else if (!strcmp(argv[1], "keyboard"))
	{
      if (argc == 3)
      {
         n.keyboard_tm = atoi(argv[2]) & 0x7f;
         write_nvram();
         read_nvram();
      }
      cprintf("Keyboard ($%02x)  : %dHz/%dms\n",
         n.keyboard_tm,
         get_kbrd_repeat(n.keyboard_tm),
         get_kbrd_delay(n.keyboard_tm)
		);
   }
	else if (strcmp(argv[1], "list") == 0)
	{
		cprintf("OS filename     : %.11s\nUART baud rate  : %ld\nUART line conf  : %c%c%c\nKeyboard ($%02x)  : %dHz/%dms\nCRC             : $%02x\n",
			n.filename,
			lookup_divisor(n.uart_baudrate),
			get_databits(n.uart_lsr),
			get_parity(n.uart_lsr),
			get_stopbits(n.uart_lsr),
         n.keyboard_tm,
         get_kbrd_repeat(n.keyboard_tm),
         get_kbrd_delay(n.keyboard_tm),
         n.crc7
		);
	}
	else if (strcmp(argv[1], "init") == 0)
    {
        init_nvram();
    }
    else
	{
		usage();
	}

	return EXIT_SUCCESS;
}


unsigned char get_parity(unsigned char lsr)
{
    switch (56 & lsr)
    {
        case UART_PARITY_NONE:
            return 'N';
        case UART_PARITY_ODD:
            return 'O';
        case UART_PARITY_EVEN:
            return 'E';
    }
}

unsigned char get_databits(unsigned char lsr)
{
    switch(0x03 & lsr)
    {
        case UART_DATA_BITS8:
            return '8';
        case UART_DATA_BITS7:
            return '7';
        case UART_DATA_BITS6:
            return '6';
        case UART_DATA_BITS5:
            return '5';
    }
}
unsigned char get_stopbits(unsigned char lsr)
{
    switch(4 & lsr)
    {
        case UART_STOP_BITS1:
            return '1';
        case UART_STOP_BITS2:
            return '2';
    }
}

unsigned char make_line_byte(unsigned char * line)
{
    unsigned char lsr = 0;
    unsigned char * p = line;

    switch (*p)
    {
        case '8':
            lsr |= UART_DATA_BITS8;
            break;
        case '7':
            lsr |= UART_DATA_BITS7;
            break;
        case '6':
            lsr |= UART_DATA_BITS6;
            break;
        case '5':
            lsr |= UART_DATA_BITS6;
            break;
        default:
            return -1;
    }

    p++;
    switch(*p)
    {
        case 'N':
        case 'n':
            lsr |= UART_PARITY_NONE;
            break;
        case 'E':
        case 'e':
            lsr |= UART_PARITY_EVEN;
            break;
        case 'O':
        case 'o':
            lsr |= UART_PARITY_ODD;
            break;
        default:
            return -1;
    }
    p++;
    switch(*p)
    {
        case '1':
            lsr |= UART_STOP_BITS1;
            break;
        case '2':
            lsr |= UART_STOP_BITS2;
            break;
        default:
            return -1;
    }
    return lsr;

}

void write_nvram()
{
   unsigned char *p = (unsigned char *)&n;
   n.crc7 = crc7((unsigned char *)&n, sizeof(struct nvram)-1);

   spi_select(RTC);

	spi_write(0x20|0x80);

	for(i = 0; i<sizeof(n); i++)
	{
		spi_write(*p++);
	}

    spi_deselect();
}

void read_nvram()
{
   unsigned char *p = (unsigned char *)&n;
   spi_select(RTC);
   spi_write(0x20);

	for(i = 0; i<sizeof(n); i++)
	{
        *p++ = spi_read();
	}

    spi_deselect();
}

void usage()
{
	cprintf(
        "set/get nvram values\nusage:\nnvram filename|baudrate|line|keyboard [<value>]\nnvram list|init\n"
	);
}

unsigned long int lookup_divisor(unsigned char div)
{
	static unsigned char i;

	for (i=0; i<=9; ++i)
	{
		if (baudrates[i].divisor == div)
		{
			return baudrates[i].baudrate ;
		}
	}

	return 0;
}
void init_nvram()
{
      cprintf("Setting to default values ... ");
	 	n.version 		= 0;
	 	memcpy(n.filename, "loader.prg\0", 11);

	 	n.uart_baudrate = 0x01; // 115200 baud
	 	n.uart_lsr		= UART_DATA_BITS8|UART_PARITY_NONE|UART_STOP_BITS1; // 8N1

      n.keyboard_tm = 0x20 ; // 30 Zeichen / 500ms

	 	write_nvram();
	 	cprintf("done.\r\n");
}

unsigned char lookup_baudrate(unsigned long int baud)
{
	static unsigned char i;

	for (i=0; i<=9; ++i)
	{
		if (baudrates[i].baudrate == baud )
		{
			return baudrates[i].divisor;
		}
	}

	return 0;
}

//bit 4-0 - Repeat rate (00000b = 30 Hz, ..., 11111b = 2 Hz)
int get_kbrd_repeat(unsigned char typematic){
   return 30 - (typematic & 0x1c);
}

//bit 6,5 - 00b = 250 ms, 01b = 500 ms, 10b = 750 ms, 11b = 1000 ms
int get_kbrd_delay(unsigned char typematic){
   return (((typematic>>5) & 0x3) + 1) * 250;
}
