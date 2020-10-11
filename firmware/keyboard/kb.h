// Keyboard communication routines

#ifndef __KB_INCLUDED
#define __KB_INCLUDED

#include <stdint.h>
#include <avr/sfr_defs.h>

// Keyboard connections
#define PS2_IN PIND
#define PS2_PORT PORTD
#define PS2_DDR DDRD

#define	KBD_DATA_PORT	PS2_PORT				// f�r den DATA Pin genutzer Port
#define	KBD_DATA_DDR	PS2_DDR
#define	KBD_DATA_IN		PS2_IN
#define	KBD_DATA_PIN	PD6					// f�r den DATA Pin genutzer Pin

#define	KBD_CLOCK_PORT	PS2_PORT				// f�r den CLOCK Pin genutzer Port
#define	KBD_CLOCK_DDR	PS2_DDR
#define	KBD_CLOCK_PIN	PD2					// f�r den CLOCK Pin genutzer PIN (muss Interruptf�hig sein!)
#define KBD_INT INT0_vect
#define	KBD_BUFSIZE	8

#define PS2_CLOCK_PIN PD2
#define KBD_DATAPIN PD6
#define MOUSE_DATAPIN PD7

// Bits im Keyboard-Status-Register
#define	KBD_SHIFT		1		// SHIFT is held down
#define	KBD_CTRL		2		// CTRL is held down
#define KBD_ALT			4		// ALT is held down
#define KBD_ALT_GR		8		// ALT-GR (right ALT) is held down
#define	KBD_EX			16		// extended code
#define	KBD_NUMLOCK		32		// NUM LOCK is activated
#define	KBD_BREAK		64		// UP Code was sent
#define	KBD_LOCKED		128		// NUM / CAPS / SCROLL is activated
#define	KBD_BAT_PASSED	256		// Keyboard passed its BAT test
#define	KBD_SEND		512		// This and the next bits are for internal use
#define	KBD_EX_2		1024	// second extended code
#define	KBD_CAPS		2048	// CAPS LOCK is activated
#define	KBD_SCROLL		4096	// SCROLL LOCK is activated
#define	KBD_ECHO_PASSED 8192	// ECHO received

#define KBD_CMD_STATUS		0xe0	// NOT a real ps/2 command, it's used to answer the keyboard status
#define KBD_CMD_ECHO		0xee	// echo
#define KBD_CMD_LEDS		0xed	// 
#define KBD_CMD_RESET		0xff
#define KBD_CMD_RESEND		0xfe	//
#define KBD_CMD_IDENTIFY	0xf2
#define KBD_CMD_TYPEMATIC	0xf3
#define KBD_CMD_SCAN_ON		0xF4	// enable send scan codes
#define KBD_CMD_SCAN_OFF	0xf5

#define KBD_LED_SCRLCK 1<<0
#define KBD_LED_NUMLCK 1<<1
#define KBD_LED_CAPLCK 1<<2

#define KBD_RET_ACK		 0xfa	// 1111 1010
#define KBD_RET_RESEND	 0xfe	// 1111 1010
#define KBD_RET_ECHO	 0xee	// 
#define KBD_RET_BAT_OK	 0xaa	// 
#define KBD_RET_BAT_FAIL1 0xfc	// 1111 1100
#define KBD_RET_BAT_FAIL2 0xfd	// 1111 1100
#define KBD_RET_ERROR	 0xff

void kbd_clock_high();
void kbd_clock_low();
void kbd_data_high();
void kbd_data_low();

void kbd_init(void);
void kbd_send(uint8_t data);
void kbd_update_leds();
void kbd_identify();
void kbd_watchdog();

void decode(uint8_t sc);

void put_kbbuff(unsigned char c);
void put_scanbuff(unsigned char c);
uint8_t get_scancode(void);
uint8_t kbd_receive_command(uint8_t code);
void kbd_process_command();

#define SCAN_BUFF_SIZE 16
uint8_t scan_buffer[SCAN_BUFF_SIZE];
uint8_t *scan_inptr;
uint8_t *scan_outptr;
volatile uint8_t scan_buffcnt;//volatile - main loop / isr modified

#ifdef MOUSE
 int get_mousechar(void);
#define MOUSE_BUFF_SIZE 16
 uint8_t mouse_buffer[SCAN_BUFF_SIZE];
 uint8_t *mouse_inptr;
 uint8_t *mouse_outptr;
 uint8_t mouse_buffcnt;
#endif

#define KB_BUFF_SIZE 16
 uint8_t kb_buffer[KB_BUFF_SIZE];
 uint8_t *kb_inptr;
 uint8_t *kb_outptr;
 uint8_t kb_buffcnt;

#endif

#define RESET_TRIG 	PC0
#define NMI			PC1
#define	IRQ			PC2
