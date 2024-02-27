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
#include <time.h>

unsigned char buf[16384];

int main (int argc, const char* argv[])
{
	FILE *fd = NULL;
	int r = 0;
	unsigned long int count = 0;
	unsigned long int ms = 0;
	struct timespec ts;

	if(argc < 2){
		printf ("Usage: %s [OPTION]... [FILE]...\n", argv[0]);
		exit (EXIT_FAILURE);
	}
	fd = fopen(argv[1], "r");
	if(fd == NULL){
		fprintf(stderr, "could not open...\n");
		return EXIT_FAILURE;
	}

	printf("file %s with size %lu bench... \n", argv[1], 0);

	clock_gettime(CLOCK_REALTIME, &ts);
	ms = ts.tv_sec * 1000;
	while((r = fread(buf,sizeof(char), sizeof(buf),fd)) > 0){
		count+=r;
	}
	clock_gettime(CLOCK_REALTIME, &ts);

	fclose(fd);

	printf("bytes read: %lu took %lu ms\n", count, ts.tv_sec*1000 - ms);

	return EXIT_SUCCESS;
}
