CLIB=../../steckos/clib/lib/steckschwein-clib.a
LIBS=../../steckos/lib/steckschwein.a ../../steckos/tools/lib/toollib.a
CC65FLAGS=-I ../../steckos/clib -I ../../steckos/clib/include -D_CC65_V2_17_
CA65FLAGS=-I ../../steckos/asminc -I ../../steckos/kernel
LDFLAGS=-C ../../steckos/prg.ld65.cfg $(LIBS)

OBJS=pacman.boot.o pacman.intro.o pacman.game.o pacman.gfx.o pacman.sound.o

.PHONY: all clean

all: pacman.prg

clean:
	rm -f *.bin *.prg *.dis *.s *.o *.res

%.res: %.xpm
	python3 ../utils/xpm_ca65_16bit.py $< > $@
  
%.o: %.asm ../../steckos/asminc/*.inc *.inc pacman.ghosts.res pacman.pacman.res
	ca65 $(CA65FLAGS) $(@:.o=.asm)

pacman.tiles.bin: pacman.tiles.inc
	ca65 pacman.tiles.inc
	ld65 pacman.tiles.o -t none -o $@
  
#%.o: %.c
#	cc65 -t none $(CC65FLAGS) -O $<
#	ca65 $(CA65FLAGS) $(@:.o=.s)

%.prg: %.o $(OBJS) $(LIBS)
	ld65 $< $(OBJS) $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../transfer.py $< -s 0x1000