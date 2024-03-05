DEBUG=-D__DEBUG

LIBS=../../steckos/lib/steckschwein.a
CAFLAGS=-I ../../steckos/asminc -I ../../steckos/kernel
LDFLAGS=--config ../../steckos/prg.ld65.cfg $(LIBS)

CA65FLAGS_C64=-t c64 -I $(CC65_HOME)/asminc $(DEBUG)
LIBS_C64=$(CC65_HOME)/lib/c64.lib
#LDFLAGS_C64=-C c64-asm.cfg -m pacman64.map
LDFLAGS_C64=-t c64 -m $<.map

OBJS=chars_text.o
OBJS+=chars_starfield.o


.PHONY: all clean

all: shmup.prg

clean:
	rm -f *.prg *.o

%.o: %.s
	ca65 $(CAFLAGS) $(@:.o=.s)

%.prg: %.o $(OBJS) $(LIBS)
	ld65 $< -m $(basename $<).map $(OBJS) $(LDFLAGS) -o $@

%.c64.o: %.c64.s
	ca65 $(CA65FLAGS_C64) $(@:.o=.s)

%.c64.prg: %.c64.o $(LIBS_C64)
	ld65 -o $@ $(LDFLAGS_C64) $< $(LIBS_C64)

%.c64: %.c64.prg
	x64 -device8 1 -VICIIdscan -VICIIdsize -autostartprgmode 1 $(ARGS) $<

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../xmodem.sh $<

emu: shmup.prg
	steckschwein-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -upload shmup.prg