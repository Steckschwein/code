#ifndef _SPI_H
#define _SPI_H

typedef enum SpiDevice{
	SDCARD,
	KEYBOARD,
	RTC,
} SpiDevice;

extern unsigned char __fastcall__ spi_select(SpiDevice device);
extern void __fastcall__ spi_deselect(void);

extern unsigned char __fastcall__ spi_read(void);
extern unsigned char __fastcall__ spi_write(unsigned char b);

#endif
