#DEBUG+=-D__DEBUG
#DEBUG+=-D__NO_SOUND
#DEBUG+=-D__NO_BOOT
#DEBUG+=-D__NO_INTRO
#DEBUG+=-D__INTERLUDE
DEBUG+=-D__ASSERTIONS
#DEBUG+=-D__DEVMODE

LIBS=
CA65FLAGS=$(DEBUG)

LDFLAGS=-m pacman.map $(LIBS)
OBJS=pacman.o pacman.boot.o pacman.intro.o pacman.game.o pacman.system.o

CA65FLAGS_STS=-I ../../asmunit -I ../../steckos/asminc -I ../../steckos/kernel $(DEBUG)
# ym3812
OBJS_STS=$(OBJS) pacman.io.sts.o pacman.gfx.v99x8.o pacman.sound.ym3812.o
# sn76489
# OBJS_STS=$(OBJS) pacman.io.sts.o pacman.gfx.v99x8.o pacman.sound.sn76489.o

LIBS_STS=$(LIBS) ../../asmunit/asmunit.a ../../steckos/lib/steckschwein.a
LDFLAGS_STS=-C ../../steckos/prg.ld65.cfg -m pacman.map -Ln pacman.lbl --dbgfile pacman.dbg

CA65FLAGS_JC=$(DEBUG)
OBJS_JC=$(OBJS) pacman.io.jc.o pacman.gfx.v99x8.o pacman.nosound.o
LIBS_JC=$(LIBS) ../../steckos/lib/steckschwein.a
LDFLAGS_JC=-C jc.ld65.cfg -m pacmanjc.map -Ln pacmanjc.lbl --dbgfile pacmanjc.dbg

CA65FLAGS_C64=-t c64 -I $(CC65_HOME)/asminc $(DEBUG)
OBJS_C64=$(OBJS) pacman.io.c64.o pacman.gfx.c64.o pacman.sound.c64.o
#LDFLAGS_C64=-C c64-asm.cfg -m pacman64.map
LDFLAGS_C64=-t c64 -m pacman64.map --lib c64.lib

TEST_LIBS := ../../asmunit/asmunit.a
TEST_LDFLAGS=-C ../../asmunit/asmunit.cfg $(TEST_LIBS)


RESOURCES_C64=\
	pacman.c64.res \
	pacman.tiles.rot.inc

RESOURCES=\
  pacman.ghosts.res \
  pacman.pacman.res \
	pacman.dying.res \
	pacman.bonus.res \
	pacman.interlude.res \
	ghost.interlude.sprites.res \
	bonus.res \
  pacman.tiles.rot.inc

RESOURCES_4BPP := $(patsubst %.4bpp.xpm,%.4bpp.res,$(foreach dir,.,$(wildcard ./*.4bpp.xpm)))

.PHONY: all clean

all: pacman.prg pacman64.prg pacmanjc.bin

clean:
	rm -f *.bin *.prg *.com *.dis *.s *.o *.res *.map *.lbl

#%.res: %.spm
%.res: %.raw
	egrep -v "(LDA|STA|sprite_.*:)" $< | sed "s/^\/\//;/g" > $@

%.res: %.res.txt
	grep -v sprite_.*: $< | sed "s/^\/\//;/g" > $@

%.res: %.xpm
	python3 ../utils/xpm_ca65_16bit.py $< > $@

%.4bpp.res: %.4bpp.xpm
	python3 ../utils/xpm_ca65_4bpp.py $< > $@


pacman.gfx.c64.o: $(RESOURCES_C64)

pacman.game.o: pacman.maze.inc pacman.inc

%.o: %.asm pacman.inc
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.jc.o: %.jc.asm pacman.inc pacman.jc.inc
	ca65 $(CA65FLAGS_JC) $(@:.o=.asm)

%.sts.o: %.sts.asm ../../steckos/asminc/*.inc pacman.inc pacman.sts.inc
	ca65 $(CA65FLAGS_STS) $(@:.o=.asm)

pacman.gfx.v99x8.o: pacman.gfx.v99x8.asm pacman.inc pacman.v99x8.inc $(RESOURCES) $(RESOURCES_4BPP)
	ca65 $(CA65FLAGS_STS) $(@:.o=.asm)

%.ym3812.o: %.ym3812.asm pacman.inc
	ca65 $(CA65FLAGS_STS) $(@:.o=.asm)

%.sn76489.o: %.sn76489.asm pacman.inc
	ca65 $(CA65FLAGS_STS) $(@:.o=.asm)

sndtest.o: sndtest.asm pacman.inc
	ca65 $(CA65FLAGS_STS) $(@:.o=.asm)

%.c64.o: %.c64.asm pacman.inc pacman.c64.inc
	ca65 $(CA65FLAGS_C64) $(@:.o=.asm)

pacman.tiles.bin: pacman.tiles.inc
	ca65 pacman.tiles.inc
	ld65 pacman.tiles.o -o $@

test.%.bin: test.%.o $(TEST_LIBS)
	ld65 $(TEST_LDFLAGS) $< $(TEST_LIBS) -o $@

test.%: test.%.bin
	ASMUNIT_VERBOSE=true TARGET_DIR=. ../../asmunit/asmunit_wrapper.sh $< 0x1000

sndtest.prg: sndtest.o pacman.sound.sn76489.o $(LIBS_STS)
	ld65 -o $@ $(LDFLAGS_STS) $^

pacman.prg: $(OBJS_STS) $(LIBS_STS)
	ld65 -o $@ $(LDFLAGS_STS) $(OBJS_STS) $(LIBS_STS)

pacman64.prg: $(OBJS_C64) $(LIBS_C64)
	ld65 -o $@ $(LDFLAGS_C64) $(OBJS_C64) $(LIBS_C64)

pacmanjc.bin: $(OBJS_JC) $(LIBS_JC)
	ld65 -o $@ $(LDFLAGS_JC) $(OBJS_JC) $(LIBS_JC)

gfx4test.bin: gfx4test.asm $(LIBS_JC)
	ca65 -o gfx4test.o  -I ../../steckos/asminc $(CA65FLAGS_JC) $<
	ld65 -o $@ $(LDFLAGS_JC) gfx4test.o $(LIBS_JC)

pacman64: pacman64.prg
	x64 -device8 1 -VICIIdscan -VICIIdsize -autostartprgmode 1 $(ARGS) $<
#-fullscreen

pacmanjc.dis: pacmanjc.bin
	dcc6502 -o 0x3000 -d -n -c $< > $@

pacman.dis: pacman.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

pacman64.dis: pacman64.prg
	dcc6502 -o 0x7ff -d -n -c $< > $@

%: %.prg
	../../xmodem.sh $<

%.emu: %.bin
#	6502msx-emu -rotate -quality linear -upload $<,0x3000 -debug 0x3000 -joy2 SNES
	6502msx-emu -upload $<,0x3000 -debug 0x3000 -joy2 SNES
#	6502msx-emu -rotate -quality linear -upload ../../VPU.com,0x3000 -debug 0x3000

%.emu: %.prg
	6502msx-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -quality linear -rotate -upload $<
#	6502msx-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -quality linear -upload $<
