LIBS=../lib/steckschwein.a
OBJS=bios.o charset_6x8.o vdp.o
CA65FLAGS=-I ../asminc
LDFLAGS=-C bios.cfg -m bios.map -Ln bios.lbl
# 6x8 characters
DEFINES+=-DCHAR6x8
# if 9958 is used
DEFINES+=-DV9958
# enable 80 cols
DEFINES+=-DCOLS80
# debug fat32
# DEFINES += -DDEBUG_FAT32

.PHONY: all clean
all: version.inc bios.bin

clean:
	rm -f *.o *.bin *.prg *.map *.lbl *.dis version.inc bios_call.inc

bios.asm: version.inc


version.inc:
	echo -n ".byte \"`git log -1 --format="%t (%cd)" --date=format-local:%Y/%m/%d\ %H:%M:%S`\"" > version.inc

bios.bin: $(OBJS) $(LIBS) bios.inc version.inc
	ld65 $(LDFLAGS) $(OBJS) $(LIBS) -o bios.bin
	cat bios.lbl | sed "s/al 0[0-9]//g" | awk -F' ' '{print $$2" = $$"$$1}'| sed -e "s/^\.//g" > bios_call.inc

bios.dis: bios.bin
	dcc6502 -o 0x8000 -m 0x7fff -d -n -c $< > $@

%.o: %.asm
	ca65 --target none $(CA65FLAGS) $(DEFINES) $<

%.prg: %.o
	ld65 -C ../prg.ld65.cfg -m $(basename $<).map $< $(LIBS) -o $@

%.dis: %.bin
	dcc6502 -o 0x0300 -d -n -c $< > $@

%: %.prg
	../../xmodem.sh $<

bios: bios.bin
	../../xmodem.sh bios.bin

mettwurst: mettwurst.prg
	../../xmodem.sh mettwurst.prg

emu: bios.bin
	steckschwein-emu -rom $< -upload ../../steckos/kernel/loader.prg # ../../progs/edlib/edlplytest.prg

burn: bios.bin
	minipro --device AT28C256 --write bios.bin -s

