# Homebrew 8bit computer based on 65c02 CPU #

[Main Web Site](http://steckschwein.de/)

## Description ##
We are developing a retro style 8bit computer based on the 65c02 CPU.

## Features ##

### Hardware ###
- 65c02 CPU @ 8MHz
- V9958 Video Display Controller
- Yamaha YM3812 (OPL2) Sound
- RS232 serial interface using UART 16550
- 2 Joystick Ports a la Commodore/Atari
- SPI as peripheral bus with
    - SD-Card Interface
    - PS/2 keyboard interface
    - DS1306 RTC

### Software ###
- steckOS operating system with FAT32 support
- Forth interpreter (Taliforth2)
- EhBasic 2.22 with extensions 


The goal is to design a machine that could have existed back in the home computer era, but with "modern" interfaces like PS/2, full fledged rs232, SPI, etc.

We use as much open source tools as possible, such as
- cc65
- make
- galasm
- KiCAD
- avr-gcc
- git

The repository contains the source for the system firmware, the steckOS "operating system", test and demo programs, galasm source for the address decoder.
The KiCAD project files for schematics and layout can be found in the "steckschwein-hardware" repository.
