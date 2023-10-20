#include <stdio.h>
#include <stdlib.h>
#include <sdcard.h>

static unsigned char block[512];

int main (int argc, const char* argv[])
{
    unsigned long lba = 0x00000000; // mbr
    unsigned char r;
    unsigned int i=0;

	printf("read block %lu\n", lba);
    r = read_block(block, lba);
	printf("r: %d\n", r);
    for(;i<sizeof(block);i++){
        printf("%x ", block[i]);
        if(i % 16 == 0)
            printf("\n");
    }

    return EXIT_SUCCESS;
}

