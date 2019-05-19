
DEBUG=-D__DEBUG
DEBUG+=-D__NO_SOUND
DEBUG+=-D__NO_BOOT
DEBUG+=-D__NO_INTRO

CLIB=../../steckos/clib/lib/steckschwein-clib.a
CC65FLAGS=-I ../../steckos/clib -I ../../steckos/clib/include -D_CC65_V2_17_

LIBS=
CA65FLAGS=-I $(CC65_HOME)/asminc $(DEBUG)

LDFLAGS=-m pacman.map $(LIBS)
OBJS=pacman.o pacman.boot.o pacman.intro.o pacman.ai.o pacman.game.o pacman.system.o

CA65FLAGS_STS=-D__STECKSCHWEIN__ -I ../../asmunit -I ../../steckos/asminc -I ../../steckos/kernel $(DEBUG)
OBJS_STS=$(OBJS) pacman.io.sts.o pacman.gfx.sts.o pacman.sound.sts.o
LIBS_STS=../../asmunit/asmunit.a ../../steckos/lib/steckschwein.a ../../steckos/tools/lib/toollib.a
LDFLAGS_STS=-C ../../steckos/prg.ld65.cfg -m pacman.map

CA65FLAGS_C64=-t c64 -I $(CC65_HOME)/asminc $(DEBUG)
OBJS_C64=$(OBJS) pacman.io.c64.o pacman.gfx.c64.o pacman.sound.c64.o
LIBS_C64=$(CC65_HOME)/lib/c64.lib
#LDFLAGS_C64=-C c64-asm.cfg -m pacman64.map
LDFLAGS_C64=-t c64 -m pacman64.map

DEFINES=-Dasmunit_char_out=0x200
TEST_LDFLAGS=-C ../../asmunit/asmunit.cfg $(DEFINES)

RESOURCES=\
  pacman.ghosts.res \
  pacman.pacman.res \
  pacman.tiles.rot.inc \
  pacman.tiles.colors.inc
  
.PHONY: all clean

all: pacman.prg pacman64.prg

clean:
	rm -f *.bin *.prg *.dis *.s *.o *.res *.map

%.res: %.xpm
	python3 ../utils/xpm_ca65_16bit.py $< > $@
  
pacman.gfx.sts.o: $(RESOURCES)
pacman.gfx.c64.o: $(RESOURCES)

pacman.game.o: pacman.maze.inc

%.o: %.asm ../../steckos/asminc/*.inc pacman.inc
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.sts.o: %.sts.asm ../../steckos/asminc/*.inc pacman.inc pacman.sts.inc
	ca65 $(CA65FLAGS_STS) $(@:.o=.asm)

%.c64.o: %.c64.asm pacman.c64.inc
	ca65 $(CA65FLAGS_C64) $(@:.o=.asm)

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

pacman.prg: $(OBJS_STS) $(LIBS)
	ld65 -o $@ $(LDFLAGS_STS) $(OBJS_STS) $(LIBS_STS)
  
pacman64.prg: $(OBJS_C64) $(LIBS_C64)
	ld65 -o $@ $(LDFLAGS_C64) $(OBJS_C64) $(LIBS_C64)
  
pacman64: pacman64.prg
	x64 -device8 1 -VICIIdscan -VICIIdsize -autostartprgmode 1 $<
#-fullscreen 

pacman.dis: pacman.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

pacman64.dis: pacman64.prg
	dcc6502 -o 0x7ff -d -n -c $< > $@

%: %.prg
	../../transfer.py $< -s 0x1000