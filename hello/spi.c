#include <conio.h>  
#include "../cc65/spi.h"

int main ()
{
	unsigned char c;
	
	cprintf("\n\rlos gehts....\n\r");	
	while(1)
	{
		*(unsigned char*) 0x210 = 0x7a;
		c = spi_read();
		c = spi_write(0xa7);	
		*(unsigned char*) 0x210 = 0x7e;

		cprintf("%x\n", c);
	}
	
	return 0;
}
