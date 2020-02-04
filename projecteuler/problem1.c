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
 * https://projecteuler.net/problem=1
 */
#include <stdio.h>
#include <stdlib.h>
#include <sys/utsname.h>
#include <conio.h>
// #include <stdio.h>

unsigned long sum3(unsigned long n){
	if(n < 3){
		return 0;
	}
	if(n < 6){
		return 3;
	}
	return n + sum3(n-3);
}

unsigned long sum5(unsigned long n){
	if(n < 5){
		return 0;
	}
	if(n < 10){
		return 5;
	}
	return n + sum5(n-5);
}

int main (int argc, const char* argv[])
{ 
	unsigned long e;
	unsigned long sum;

	cprintf("\n");
	
	if(argc > 1){
		e = atol(argv[1]);
		sum = sum3((e-1)/3*3) + sum5((e-1)/5*5);
		cprintf("%ld\n", sum);
	}
	return EXIT_SUCCESS;
} 