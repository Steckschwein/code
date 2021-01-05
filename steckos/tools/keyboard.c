#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <include/steckschwein.h>
#include "include/spi.h"

#define KBD_HOST_CMD_KBD_STATUS 0x01
#define KBD_HOST_CMD_CMD_STATUS 0x02

void usage(void);

void assertParam(int argc, char **argv)
{
    if (!argc || argv[0][0] == '-')
    {
        usage();
    }
}

void printStatus(unsigned char status_command)
{

    unsigned char r;
    unsigned char cnt = 200;

    printf("status:");
    if ((r == spi_select(KEYBOARD)) == 0)
    {
        while (r != 0xaa && cnt-- > 0) //0xaa end of status bytes
        {
            r = spi_write(status_command);
            if (r != 0xff)
            {
                printf(" 0x%02x", r);
            }
            _delay_ms(10);
        }
        spi_deselect();
        printf("\n");
    }
    else
    {
        printf("error %d, could not select spi device keyboard\n", r);
    }
}

void send(unsigned char command, unsigned char value)
{

    unsigned char r;

    if ((r == spi_select(KEYBOARD)) == 0)
    {
        printf("send 0x%.2x 0x%.2x\n", command, value);
        spi_write(command);
        spi_write(value);
        spi_deselect();
        printStatus(KBD_HOST_CMD_CMD_STATUS);
    }
    else
    {
        printf("error %d, could not select spi device keyboard\n", r);
    }
}

int main(int argc, unsigned char **argv)
{
    while (argc > 0)
    {
        argc--;
        argv++;
        if (!strcmp(argv[0], "-s"))
        {
            printStatus(KBD_HOST_CMD_KBD_STATUS);
        }
        else if (!strcmp(argv[0], "-r"))
        {
            unsigned char rate = 0;
            argc--;
            argv++;
            assertParam(argc, argv);
            rate = atoi(argv[0]);
            send(0xf3, rate);
        }
        else if (!strcmp(argv[0], "-d"))
        {
            unsigned char delay = 0;
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
        else if (!strcmp(argv[0], "-c"))
        {
            unsigned int cmd = 0;
            unsigned int val = 0;

            argc--;
            argv++;
            assertParam(argc, argv);
            sscanf(argv[0], "%x", &cmd);
            if (argc > 0)
            {
                argc--;
                argv++;
                sscanf(argv[0], "%x", &val);
            }
            //printf("0x%.2x 0x%.2x\n", cmd, val);
            send(cmd & 0xff, val & 0xff);
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
    printf(
        "Usage: keyboard [OPTIONS]...\n\n"
        "   -s status (default)\n"
        "   -c 0x<cmd> [0x<value>]\n"
        "   -r rate\n"
        "   -d delay\n"
        "   -led leds\n");
    exit(EXIT_FAILURE);
}
