// MIT License
//
// Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/**
 * sum of all multiples of 3 and 5 < 1000
 * https://projecteuler.net/problem=1
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/utsname.h>
#include <conio.h>
// #include <stdio.h>
unsigned char buf[16];

unsigned char digit(unsigned long n, unsigned char pos){
	sprintf(buf, "%ld", n);
	return buf[strlen(buf)-1-pos];
}

int main (int argc, const char* argv[])
{ 
	unsigned long e;
	unsigned long p;
	unsigned long i;
	unsigned long sum=0;
	
	cprintf("\n");
	
	if(argc > 1){
		e = atol(argv[1]);

		for(i=0;i<e;i+=3){
			unsigned char d = digit(i, 0);
			if(d == '0' || d == '5'){
				continue; //skip multiples of 3 which are multiples of 5 too
			}
			sum += i;
		}
		for(i=0;i<e;i+=5){
			sum += i;
		}
		cprintf("%ld\n", sum);
	}
	return EXIT_SUCCESS;
} 