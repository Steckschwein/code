LIBS=../../steckos/lib/steckschwein.a
CAFLAGS=-I ../../steckos/asminc -I ../../steckos/kernel
LDFLAGS=--config ../../steckos/prg.ld65.cfg $(LIBS)

.PHONY: all clean

all: shmup.prg

clean:
	rm -f *.prg *.o

%.o: %.s
	ca65 $(CAFLAGS) $(@:.o=.s)

%.prg: %.o $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../xmodem.sh $<

emu: shmup.prg
	steckschwein-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -upload shmup.prg