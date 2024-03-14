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