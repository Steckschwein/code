LIBS=../../lib/steckschwein.a
INCLUDES=-I ../../asminc -I ../../kernel
LDFLAGS=-C ../../prg.ld65.cfg $(LIBS)

all: nixie.prg

clean:
	rm -f *.prg *.s *.o
	
%.o: %.asm
	ca65 $(INCLUDES) $(@:.o=.asm)

%.prg: %.o $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

nixie: nixie.prg
	../../../xmodem.sh nixie.prg