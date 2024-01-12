/*
; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void usage (int status)
{
	if (status != EXIT_SUCCESS){
		printf ("Usage: cat [OPTION]... [FILE]...\n");
	}
	exit (status);
}

unsigned char buf[512];

int main (int argc, const char* argv[])
{
	FILE *fd;
	int r,c;
	if(argc < 2){
		usage(EXIT_FAILURE);
	}
	printf("%x %s\n", argc, argv[1]);
	fd = fopen(argv[1], "r");
	if(fd == NULL){
		fprintf(stderr, "could not open...\n");
		return EXIT_FAILURE;
	}
	while((r = fread(&buf,sizeof(char), sizeof(buf),fd)) != 0){
		for(c=0;c<r;c++){
			printf("%c", buf[c]);
		}
	}

	fclose(fd);


	return EXIT_SUCCESS;
}
