

/**
 * delay millis
 */
extern void __fastcall__ _delay_ms(unsigned int);

// #define sleep(sec) _delay_ms(sec * 1000)

// extern long __fastcall__ random(void);

#define random(i) (rand() % i)

extern void __fastcall__ sound(unsigned int);

extern void __fastcall__ nosound();
