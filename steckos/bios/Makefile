LIBS=../lib/steckschwein.a
OBJS=bios.o charset_8x8.o charset_6x8.o via.o out.o vdp.o sdcard.o fat32.o upload.o
CA65FLAGS=-I ../asminc
LDFLAGS=-C bios.cfg -m bios.map -Ln bios.lbl
# 6x8 characters
DEFINES+=-DCHAR6x8
# if 9958 is used
DEFINES+=-DV9958
# enable 80 cols
#DEFINES+=-DCOLS80


.PHONY: all clean
all: version.inc bios.bin

clean:
	rm -f *.o *.bin *.map *.lbl *.dis version.inc bios_call.inc

bios.asm: version.inc

%.o: %.asm
	ca65 --target none $(CA65FLAGS) $(DEFINES) $<

version.inc:
	echo -n ".byte \"r`hg log -l1 | grep changeset | cut -d ':' -f2 | tr -d ' '`\"" > version.inc

bios.bin: $(OBJS) $(LIBS) bios.inc version.inc
	ld65 $(LDFLAGS) $(OBJS) $(LIBS) -o bios.bin
	cat bios.lbl | sed "s/al 0[0-9]//g" | awk -F' ' '{print $$2" = $$"$$1}'| sed -e "s/^\.//g" > bios_call.inc

bios.dis: bios.bin
	dcc6502 -o 0xe000 -m 0x1fff -d -n -c $< > $@

loader.o: loader.asm bios.bin
	ca65 --target none $(CA65FLAGS) $(DEFINES) $<

loader.bin: loader.o
	ld65 -C loader.cfg -m loader.map loader.o $(LIBS) -o loader.bin

%.dis: %.bin
	dcc6502 -o 0x0300 -d -n -c $< > $@

transfer: loader.bin
	../../transfer.py -s 0x0300 loader.bin
