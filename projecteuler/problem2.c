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
 * https://projecteuler.net/problem=2
 */
#include <stdio.h>
#include <stdlib.h>
#include <sys/utsname.h>
#include <conio.h>
// #include <stdio.h>


int main (int argc, const char* argv[]){

	unsigned long sum=0;
	unsigned long f=0;
	unsigned long f1=0;
	unsigned long f2=1;

	cprintf("\n");

	while(f <= 4000000){
		f = f1 + f2;
		if((f & 0x01) == 0){
			sum += f;
			cprintf("+ %8ld\n", f);
		}
		f1 = f2;
		f2 = f;
	}
	cprintf("= %8ld\n", sum);

	return EXIT_SUCCESS;
}
