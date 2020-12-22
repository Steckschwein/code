#ifndef _SPI_H
#define _SPI_H

enum spi_devices {
	SDCARD = 0,
	KEYBOARD,
	RTC
};

typedef enum spi_devices SpiDevice;

extern unsigned char __fastcall__ spi_select(SpiDevice device);
extern void __fastcall__ spi_deselect(void);

extern unsigned char __fastcall__ spi_read(void);
extern unsigned char __fastcall__ spi_write(unsigned char b);

#endif
