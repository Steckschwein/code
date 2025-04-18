CPU=65c02
# !!! order counts !!! - kernel.o must be the first module which is linked to output file
OBJS=kernel.o rtc.o exec.o automount.o jumptable.o wozmon.o
OBJS+=textui.o
OBJS+=ansi.o
ASM_INCLUDE=../asminc
LIBS=../lib/steckschwein.a
LDFLAGS_KERNEL=-C kernel.cfg
LDFLAGS=-C ../prg.ld65.cfg

# if 9958 is used
DEFINES+=-DV9958
# enable 80 cols
DEFINES+=-DCOLS80
DEFINES+=-DDISABLE_INTRO
#DEFINES+=-DDISABLE_VDPINIT

# enable debug
#DEBUG += -DDEBUG_KERNEL
# debug rtc updates by kernel
#DEBUG += -DDEBUG_RTC
#DEBUG += -DV9958
#DEBUG += -DDEBUG_EXECV
#DEBUG += -DDEBUG_SPI
#DEBUG += -DDEBUG_AUTOMOUNT

.PHONY: all clean test
all: kernel.bin loader.prg

clean:
	rm -f *.o *.bin *.map *.txt kernel_jumptable.inc version.inc

%.o: %.asm $(ASM_INCLUDE)/*.inc version.inc
	ca65 --cpu $(CPU) --target none $(DEFINES) $(DEBUG) $(OPT) -I $(ASM_INCLUDE) $<

version.inc:
	echo -n ".byte \"`git rev-parse --short HEAD`\"" > version.inc

kernel.bin: version.inc $(OBJS) $(LIBS)
	ld65 $(LDFLAGS_KERNEL) $(OBJS) $(LIBS) -m kernel.map -Ln symbols.txt -o kernel.bin
	grep krn symbols.txt | egrep -v "(krn_tm|krn_ptr)" | sed "s/al 00//" | awk -F' ' '{print $$2" = $$"$$1}'| sed -e "s/^\.//g" > kernel_jumptable.inc
	s=0 && for l in $$(cat kernel.map |grep fat32 -A 1|grep CODE |cut -d '=' -f3|cut -d ' ' -f1);do s=$$(($$s + 0x$$l));done && echo "fat32 size: $$s bytes"
loader.prg: kernel.bin loader.o
	ld65 $(LDFLAGS) -m loader.map loader.o -o loader.prg

# -m <kernel start adress - $100 (loader)
dis: kernel.bin
	dcc6502 -o 0xe000 -m 0x1ffe -d -n -c kernel.bin > kernel.dis

transfer: loader.prg
	../../xmodem.sh loader.prg

test.bin: test.o
	cl65 --target none --config kernel.cfg test.asm -o test.bin

test:
	(cd test; make all)

../lib/steckschwein.a:
	(cd ../libsrc ; make)

emu: loader.prg
	6502msx-emu -rom ../bios/bios.bin -sdcard ../../steckos.img -upload ../shell/shell.prg # loader.prg
