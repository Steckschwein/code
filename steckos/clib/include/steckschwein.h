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

#ifndef _STECKSCHWEIN_H
#define _STECKSCHWEIN_H


extern unsigned int __fastcall__ getch(void);


/**
 * delay millis
 */
extern void __fastcall__ _delay_ms(unsigned int);

// #define sleep(sec) _delay_ms(sec * 1000)

// extern long __fastcall__ random(void);

extern void __fastcall__ _randomize(void);

extern void __fastcall__ sound(unsigned int);

extern void __fastcall__ nosound();

#define randomize(void)

#define random(i) (rand() % i)

#endif