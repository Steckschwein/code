LIBS=../../steckos/lib/steckschwein.a 
CAFLAGS=-I ../../steckos/asminc -I ../../steckos/kernel
LDFLAGS=--config ../../steckos/prg.ld65.cfg $(LIBS)

.PHONY: all clean

all: unrclock.prg 

clean:
	rm -f *.prg *.s *.o

%.o: %.asm
	ca65 $(CAFLAGS) $(@:.o=.asm)

%.prg: %.o $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../transfer.py $< -s 0x1000
