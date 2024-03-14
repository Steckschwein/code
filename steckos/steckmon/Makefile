LIBS=../lib/steckschwein.a
CAFLAGS=-I ../asminc -I ../kernel
LDFLAGS=-C ../prg.ld65.cfg

.PHONY: all clean
all: steckmon.prg

.PHONY: clean
clean:
	rm -f *.o *.prg *.map *.txt version.inc

%.o: %.s
	ca65 --target none $(CAFLAGS) $<

steckmon.prg: steckmon.o $(LIBS)
	ld65 $(LDFLAGS) -m steckmon.map -o steckmon.prg steckmon.o $(LIBS)
