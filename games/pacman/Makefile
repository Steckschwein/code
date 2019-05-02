CLIB=../../steckos/clib/lib/steckschwein-clib.a
LIBS=../../asmunit/asmunit.a ../../steckos/lib/steckschwein.a ../../steckos/tools/lib/toollib.a
CC65FLAGS=-I ../../steckos/clib -I ../../steckos/clib/include -D_CC65_V2_17_
CA65FLAGS=-I ../../asmunit -I ../../steckos/asminc -I ../../steckos/kernel
LDFLAGS=-C ../../steckos/prg.ld65.cfg -m pacman.map $(LIBS)
OBJS=pacman.o pacman.boot.o pacman.intro.o pacman.ai.o pacman.game.o pacman.gfx.o pacman.sound.opl2.o pacman.system.o pacman.io.o

DEFINES=-Dasmunit_char_out=0x200
TEST_LDFLAGS=-C ../../asmunit/asmunit.cfg $(DEFINES)

C64_LIBS=$(CC65_HOME)/lib/c64.lib
C64_LDFLAGS=-C c64-asm.cfg -m pacman64.map $(C64_LIBS)
C64_OBJS=pacman.o pacman.boot.o pacman.intro.o pacman.ai.o pacman.game.o pacman.gfx.c64.o pacman.sound.sid.o pacman.system.o pacman.io.c64.o


.PHONY: all clean

all: pacman.prg pacman64.prg

clean:
	rm -f *.bin *.prg *.dis *.s *.o *.res

%.res: %.xpm
	python3 ../utils/xpm_ca65_16bit.py $< > $@
  
pacman.gfx.o: pacman.ghosts.res pacman.pacman.res pacman.tiles.rot.inc pacman.tiles.colors.inc

pacman.game.o: pacman.maze.inc

%.o: %.asm ../../steckos/asminc/*.inc pacman.inc
	ca65 $(CA65FLAGS) $(@:.o=.asm)

pacman.tiles.bin: pacman.tiles.inc
	ca65 pacman.tiles.inc
	ld65 pacman.tiles.o -t none -o $@

test.%.bin: test.%.o $(LIBS) $(<:test.%=%)
	ld65 $(LDFLAGS) $< $(<:test.%=%) $(LIBS) -o $@
  
test.%: test.%.bin
	../../asmunit/asmunit_wrapper.sh $@.bin

#%.o: %.c
#	cc65 -t none $(CC65FLAGS) -O $<
#	ca65 $(CA65FLAGS) $(@:.o=.s)

pacman.prg: $(OBJS) $(LIBS)
	ld65 $(OBJS) $(LDFLAGS) -o $@
  
pacman64.prg: $(C64_OBJS) $(C64_LIBS)
	ld65 $(C64_LDFLAGS) $(C64_OBJS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../transfer.py $< -s 0x1000