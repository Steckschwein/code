TARGET=edlply.prg

STECKOS=../../steckos
LIBS:=$(STECKOS)/lib/steckschwein.a
CAFLAGS=--include-dir $(STECKOS)/asminc --include-dir $(STECKOS)/kernel
LDFLAGS=--config $(STECKOS)/prg.ld65.cfg $(LIBS)

C64LIBS=$(CC65_HOME)/lib/c64.lib $(LIBS)
C64LDFLAGS=--config c64-asm.cfg

.PHONY: all allall clean

all: $(TARGET)

allall: all edlply64.prg

clean:
	rm -f *.prg *.s *.o

edlply64.prg: edlply64.o $(C64LIBS)
	ld65 $< $(C64LDFLAGS) $(C64LIBS) -o $@

edlply.prg: edlply.o $(LIBS)
	ld65 -v $< $(LDFLAGS) --mapfile $<.map -o $@

edlplytest.prg: edlplytest.o $(LIBS)
	ld65 -v $< $(LDFLAGS) --mapfile $<.map -o $@

%.o: %.asm
	ca65 $(CAFLAGS) $(@:.o=.asm)

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../xmodem.sh $<
