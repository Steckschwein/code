LIBS=../../steckos/lib/steckschwein.a
CA65FLAGS=-I ../../steckos/asminc -I ../../steckos/kernel
LDFLAGS=-C ../../steckos/prg.ld65.cfg $(LIBS)

.PHONY: all clean

all: pong.prg

clean:
	rm -f *.prg *.s *.o

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.prg: %.o ../../steckos/lib/steckschwein.a
	ld65 $< $(LDFLAGS) -o $@

%: %.prg
	../../xmodem.sh $<