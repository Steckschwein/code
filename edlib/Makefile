TARGET=edlply.prg

STECKOS=../steckos
APP_START=0x1000
CAFLAGS=--include-dir $(STECKOS)/asminc --include-dir $(STECKOS)/kernel 
LDFLAGS=--define __LOADADDR__=$(APP_START) --config $(STECKOS)/prg.ld65.cfg --lib $(STECKOS)/lib/steckschwein.a --lib $(STECKOS)/tools/lib/toollib.a
LIBS=$(STECKOS)/lib/steckschwein.a $(STECKOS)/tools/lib/toollib.a

C64LIBS=$(CC65_HOME)/lib/c64.lib
C64LDFLAGS=--config c64-asm.cfg

.PHONY: all allall clean

all: $(TARGET)

allall: all edlply64.prg

clean:
	rm -f *.prg *.s *.o

edlply64.prg: edlply64.o edlib.o $(C64LIBS)
	ld65 $< edlib.o $(C64LDFLAGS) $(C64LIBS) -o $@

edlply.prg: edlply.o edlib.o $(LIBS)
	ld65 -v $< --obj edlib.o $(LDFLAGS) --mapfile $<.map -o $@
  
%.o: %.asm
	ca65 $(CAFLAGS) $(@:.o=.asm)

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../transfer.py $< -s $(APP_START)