#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
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
char * get_color(uint8_t);
uint8_t get_color_num(const char *);

struct nvram
{
    unsigned char version;
    unsigned char filename[13];
    unsigned char uart_baudrate;
    unsigned char uart_lsr;
    unsigned char keyboard_tm;
    unsigned char textui_color;
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

struct color
{
    uint8_t value;
    unsigned char * name; 
};


const struct color textui_colors[] = {
    { 0x00, "transparent" },    
    { 0x01, "black" },           
    { 0x02, "mediumgreen" },    
    { 0x03, "lightgreen" },     
    { 0x04, "darkblue" },      
    { 0x05, "lightblue" },      
    { 0x06, "darkred" },        
    { 0x07, "cyan" },            
    { 0x08, "mediumred" },      
    { 0x09, "lightred" },       
    { 0x0a, "darkyellow" },    
    { 0x0b, "lightyellow" },    
    { 0x0c, "darkgreen" },      
    { 0x0d, "magenta" },         
    { 0x0e, "gray" },            
    { 0x0f, "white" }           
};
#define NCOLORS (sizeof(textui_colors)/sizeof(struct color))


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
        printf("NVRAM CRC7 mismatch - CRC: %0x, NVRAM: %0x\n", crc, n.crc7);
        printf("Please init with\n  nvram init\n");
    }

	if (strcmp(argv[1], "filename") == 0)
	{
        if (argc == 3)
        {
            if (strlen(argv[2]) > 13)
			{
				printf("\r\nInvalid filename\r\n");
				return 1;
			}

            sprintf(n.filename, "%s\0", argv[2]);
		    write_nvram();

        }
		printf("%.*s\r\n", 11, n.filename);
	}
	else if (strcmp(argv[1], "baudrate") == 0)
	{
        if (argc == 3)
        {
			unsigned char divisor = lookup_baudrate(atol(argv[2]));
			if (divisor == 0)
			{
				printf("Invalid baudrate\r\n");
				return 1;
			}

			n.uart_baudrate = divisor;
		    write_nvram();
        }
		printf("%ld\r\n", lookup_divisor(n.uart_baudrate));
	}
	else if (strcmp(argv[1], "line") == 0)
	{
        if (argc == 3)
        {
            unsigned char lsr;
            lsr = make_line_byte((unsigned char *)argv[3]);
            if (lsr == 0xff)
            {
                printf("Parameter error\n");
                return EXIT_FAILURE;
            }
            n.uart_lsr = lsr;
            write_nvram();
        }

		printf("%c%c%c\n",
            get_databits(n.uart_lsr),
            get_parity(n.uart_lsr),
            get_stopbits(n.uart_lsr)
        );
	}
    else if (strcmp(argv[1], "fgcolor") == 0)
    {
        if (argc == 3)
        {
            x = get_color_num(argv[2]);
            if (x == NULL)
            {
                printf("unknown color\n");
                return 1;
            }
            n.textui_color &= ~0xf0;
            n.textui_color |= (x << 4);

            write_nvram();
        }

        printf("Color           : %s/%s\n",
            get_color((n.textui_color >> 4)),
            get_color((n.textui_color & ~0xf0))
        );
    }
    else if (strcmp(argv[1], "bgcolor") == 0)
    {
        if (argc == 3)
        {
            x = get_color_num(argv[2]);
            if (x == NULL)
            {
                printf("unknown color\n");
                return 1;
            }
            n.textui_color &= ~0x0f;
            n.textui_color |= x;
            
            write_nvram();
        }

        printf("Color           : %s/%s\n",
            get_color((n.textui_color >> 4)),
            get_color((n.textui_color & ~0xf0))
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
        printf("Keyboard ($%02x)  : %dHz/%dms\n",
            n.keyboard_tm,
            get_kbrd_repeat(n.keyboard_tm),
            get_kbrd_delay(n.keyboard_tm)
        );
    }
	else if (strcmp(argv[1], "list") == 0)
	{
    	printf("OS filename     : %.11s\nUART baud rate  : %ld\nUART line conf  : %c%c%c\nKeyboard ($%02x)  : %dHz/%dms\nColor           : %s/%s\nCRC             : $%02x\n",
			n.filename,
			lookup_divisor(n.uart_baudrate),
			get_databits(n.uart_lsr),
			get_parity(n.uart_lsr),
			get_stopbits(n.uart_lsr),
            n.keyboard_tm,
            get_kbrd_repeat(n.keyboard_tm),
            get_kbrd_delay(n.keyboard_tm),
            get_color((n.textui_color >> 4)),
            get_color((n.textui_color & ~0xf0)),

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

char * get_color(uint8_t color)
{
    return textui_colors[color].name;
}

uint8_t get_color_num(const char * name)
{
    uint8_t i;

    for (i = 0; i < NCOLORS; i++)
    {
        if (strcmp(name, textui_colors[i].name) == 0)
        {
            return textui_colors[i].value;
        }
    }

    return NULL;
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
	printf(
        "set/get nvram values\nusage:\nnvram filename|baudrate|line|keyboard|fgcolor|bgcolor [<value>]\nnvram list|init\n"
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
        printf("Setting to default values ... ");
	 	n.version 		= 0;
	 	memcpy(n.filename, "loader.prg\0", 11);

	 	n.uart_baudrate = 0x01; // 115200 baud
	 	n.uart_lsr		= UART_DATA_BITS8|UART_PARITY_NONE|UART_STOP_BITS1; // 8N1

        n.keyboard_tm = 0x20 ; // 30 Zeichen / 500ms
        n.textui_color = 0x31;
	 	write_nvram();
	 	printf("done.\r\n");
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
