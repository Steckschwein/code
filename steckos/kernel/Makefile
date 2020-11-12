CPU=65c02
# !!! order counts !!! - kernel.o must be the first module which is linked to output file
OBJS=kernel.o rtc.o out.o exec.o util.o automount.o
OBJS+=textui.o
ASM_INCLUDE=../asminc
LIBS=../lib/steckschwein.a
LDFLAGS=-C kernel.cfg
#LDFLAGS=-C ../prg.ld65.cfg

# if 9958 is used
DEFINES+=-DV9958
# enable 80 cols
# DEFINES+=-DCOLS80
#DEFINES+=-DDISABLE_INTRO
#DEFINES+=-DDISABLE_VDPINIT

# enable debug
#DEBUG += -DDEBUG_KERNEL
# debug rtc updates by kernel
#DEBUG += -DDEBUG_RTC
# debug util
#DEBUG += -DDEBUG_UTIL
# dump fat blocks on write
#DEBUG += -DFAT_DUMP_FAT_WRITE
# do not write anything (metadata)
#DEBUG += -DFAT_NOWRITE
#DEBUG += -DV9958
#DEBUG += -DDEBUG_EXECV
#DEBUG += -DDEBUG_SPI
#DEBUG += -DDEBUG_AUTOMOUNT

# optimize flags
OPT += -DTEXTUI_STROUT
OPT += -DTEXTUI_PRIMM

.PHONY: all clean
all: kernel.bin loader.bin

clean:
	rm -f *.o *.bin *.map *.txt kernel_jumptable.inc version.inc

%.o: %.asm $(ASM_INCLUDE)/*.inc version.inc
	ca65 --cpu $(CPU) --target none $(DEFINES) $(DEBUG) $(OPT) -I $(ASM_INCLUDE) $<

version.inc:
	echo -n ".byte \"`git rev-parse --short HEAD`\"" > version.inc

kernel.bin: version.inc $(OBJS) $(LIBS)
	ld65 $(LDFLAGS) $(OBJS) $(LIBS) -m kernel.map -Ln symbols.txt -o kernel.bin
	grep krn symbols.txt | egrep -v "(krn_tm|krn_ptr)" | sed "s/al 00//" | awk -F' ' '{print $$2" = $$"$$1}'| sed -e "s/^\.//g" > kernel_jumptable.inc

loader.bin: kernel.bin loader.o
	ld65 $(LDFLAGS) loader.o -o loader.bin

	# -m <kernel start adress - $100 (loader)
dis: loader.bin
	dcc6502 -o 0xe700 -m 0x1800 -d -n -c loader.bin > loader.dis
transfer: loader.bin
	../../transfer.py -s 0x1000 loader.bin

test.bin: test.o
	cl65 --target none --config kernel.cfg test.asm -o test.bin

test:
	(cd test; make test)

../lib/steckschwein.a:
	(cd ../libsrc ; make)
