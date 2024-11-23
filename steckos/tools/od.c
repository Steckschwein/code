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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>

static unsigned char CHARS = 16;

int main (int argc, const char* argv[])
{
	unsigned char buffer[200];
	char c;
	unsigned int i;
	unsigned char p;
	unsigned char *format = "%c ";
	for(i=1;i<argc;i++){
		if(strncmp(argv[i], "-x", 2) == 0){
			format = "%02x ";
			break;
		}else if(strncmp(argv[i], "-c", 2) == 0){
			format = "%c ";
			break;
		}
	}
	i=0;
	p=0;
	while((c = cgetc()) != 0x1b){
		cprintf("%c", c);
		buffer[p++] = c;
		if(p % CHARS == 0){
			i+=CHARS;
			cprintf("\n%08x ", i);
			for(;p>0;p--)
				cprintf(format, buffer[CHARS-p]);
			cprintf("\n");
		}
	}
    return EXIT_SUCCESS;
}
