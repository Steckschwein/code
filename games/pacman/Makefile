LIBS=../../steckos/lib/steckschwein.a ../../steckos/tools/lib/toollib.a ../../steckos/clib/lib/steckschwein-clib.a
CC65FLAGS=-I ../../steckos/clib -I ../../steckos/clib/include -D_CC65_V2_17_
CA65FLAGS=-I ../../steckos/asminc # -I ../../steckos/kernel
LDFLAGS=--config ../../steckos/prg.ld65.cfg $(LIBS)

.PHONY: all clean

all: pacman.prg 

clean:
	rm -f *.prg *.s *.o

%.o: %.c
	cc65 -t none $(CC65FLAGS) -O $<
	ca65 $(CA65FLAGS) $(@:.o=.s)

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.prg: %.o $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

%: %.prg
	../../transfer.py $< -s 0x1000