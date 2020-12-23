#ifndef _SPI_H
#define _SPI_H

enum spi_devices {
	SDCARD   = 0b00011100,
	KEYBOARD = 0b00011010,
	RTC      = 0b00010110
};

typedef enum spi_devices SpiDevice;

extern unsigned char __fastcall__ spi_select(SpiDevice device);
extern void __fastcall__ spi_deselect(void);

extern unsigned char __fastcall__ spi_read(void);
extern unsigned char __fastcall__ spi_write(unsigned char b);

#endif
