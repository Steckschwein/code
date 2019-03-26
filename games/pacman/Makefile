CLIB=../../steckos/clib/lib/steckschwein-clib.a
LIBS=../../steckos/lib/steckschwein.a ../../steckos/tools/lib/toollib.a
CC65FLAGS=-I ../../steckos/clib -I ../../steckos/clib/include -D_CC65_V2_17_
CA65FLAGS=-I ../../steckos/asminc -I ../../steckos/kernel
LDFLAGS=-C ../../steckos/prg.ld65.cfg $(LIBS)

.PHONY: all clean

all: pacman.prg 

clean:
	rm -f *.prg *.s *.o

%.o: %.asm ../../steckos/asminc/*.inc
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.o: %.c
	cc65 -t none $(CC65FLAGS) -O $<
	ca65 $(CA65FLAGS) $(@:.o=.s)

%.prg: %.o $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../transfer.py $< -s 0x1000