# Homebrew 8bit computer based on 65c02 CPU #

## Description ##
We are developing a retro style 8bit computer based on the 65c02 CPU.

## Features ##
- 65c02 CPU @ 8MHz
- V9958 Video Display Controller
- Yamaha YM3812 (OPL2) Sound
- RS232 serial interface using UART 16550
- SD-Card Interface
- SPI as system bus
- PS/2 keyboard interface
- 2 Joystick Ports a la Commodore/Atari

[Steckschwein Web Site](http://steckschwein.de/)

The goal is to design a machine that could have existed back in the home computer era, but with "modern" interfaces like PS/2, full fledged rs232, SPI, etc.

We use as much open source tools as possible, such as
- cc65
- make
- galasm
- KiCAD
- avr-gcc
- git

The repository contains the assembler source for the system firmware, test and demo programs, galasm source for the address decoder.
The KiCAD project files for schematics and layout can be found in the "steckschwein-hardware" repository.
