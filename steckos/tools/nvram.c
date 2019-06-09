#include <conio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "include/spi.h"
#include "include/rtc.h"

struct nvram
{
	unsigned char version;
	unsigned char filename[11];
	unsigned char uart_baudrate;
	unsigned char uart_lsr;
	unsigned char crc7;
};

struct baudrate
{
	unsigned char divisor;
	unsigned long int baudrate;
};

const struct baudrate baudrates[] = {
	// {2304,	50},
	// {1536,	75},
	// {1047,	110},
	// {768, 	150},
	// {384,	300},
    // only 8bit divisors supported
    // save space
    // who needs < 600 baud?
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
unsigned char * p;
unsigned long l;

unsigned char CRC7(const unsigned char message[], const unsigned int length) {
  const unsigned char poly = 0x89;
  unsigned char crc = 0;
  unsigned char i,j;
  for (i = 0; i < length; i++) {
     crc ^= message[i];
     for (j = 0; j < 8; j++) {
      crc = (crc & 0x80u) ? ((crc << 1) ^ (poly << 1)) : (crc << 1);
    }
  }
  return crc >> 1;
}

void write_nvram()
{
	n.uart_lsr  = 0x03; // 8N1
	p = (unsigned char *)&n;

    spi_select_rtc();

	spi_write(0xA0);

	for(i = 0; i<=sizeof(n); i++)
	{
		spi_write(*p++);
	}

    spi_deselect();
}

void read_nvram()
{
    unsigned char r;
	p = (unsigned char *)&n;
    spi_select_rtc();
    spi_write(0x20);

	for(i = 0; i<=sizeof(n); i++)
	{
        *p++ = spi_read();
	}

    spi_deselect();
}

void usage()
{
	cprintf(
		"set/get nvram values\r\nusage:\r\nnvram get filename|baudrate\r\nnvram set filename|baudrate <value>\r\nnvram list\r\n",
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
	 	memcpy(n.filename, "LOADER  BIN", 11);

	 	n.uart_baudrate = 0x01; // 115200 baud
	 	n.uart_lsr		= 0x03; // 8N1

        n.crc7 = CRC7((unsigned char *)&n, sizeof(struct nvram)-1);

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

int main (int argc, const char* argv[])
{
    unsigned char crc;

	if (argc == 1)
	{
		usage();
		return 0;
	}

	read_nvram();
    crc = CRC7((unsigned char *)&n, sizeof(struct nvram)-1);

    if (crc != n.crc7)
    {
        cprintf("NVRAM CRC7 mismatch - CRC: %0x, NVRAM: %0x\n", crc, n.crc7);
        init_nvram();
    }

	if (strcmp(argv[1], "get") == 0)
	{
		if (argc < 2)
		{
			usage();
			return 0;
		}

		if (strcmp(argv[2], "filename") == 0)
		{
			cprintf("%.*s\r\n", 11, n.filename);
		}

		else if (strcmp(argv[2], "baudrate") == 0)
		{
			cprintf("%ld\r\n", lookup_divisor(n.uart_baudrate));
		}

	}
	else if (strcmp(argv[1], "set") == 0)
	{
		if (argc < 3)
		{
			usage();
			return 0;
		}

		else if (strcmp(argv[2], "baudrate") == 0)
		{

			unsigned char divisor = lookup_baudrate(atol(argv[3]));
			if (divisor == 0)
			{
				cprintf("Invalid baudrate\r\n");
				return 1;
			}

			n.uart_baudrate = divisor;

		}
		else if (strcmp(argv[2], "filename") == 0)
		{
			if (strlen(argv[3]) > 12)
			{
				cprintf("\r\nInvalid filename\r\n");
				return 1;
			}


			x=0;
			for (i=0;i<10, argv[3][i] != '\0' ;++i)
			{
				if (argv[3][i] == '.')
				{
					for (j=0;j<8-i;++j)
					{
						n.filename[x] = ' ';
						++x;
					}
					continue;
				}

				n.filename[x] = argv[3][i] & ~0x20;
				++x;
			}
		}

        n.crc7 = CRC7((unsigned char *)&n, sizeof(struct nvram)-1);
		write_nvram();
	}
	else if (strcmp(argv[1], "list") == 0)
	{
		cprintf("OS filename: %.11s\nBaud rate  : %ld\nCRC        : $%02x\n",
			n.filename,
			lookup_divisor(n.uart_baudrate),
            n.crc7
		);
	}

	return EXIT_SUCCESS;
}
