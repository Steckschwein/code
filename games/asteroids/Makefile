CA65FLAGS=-I ../../steckos/asminc -I ../../steckos/kernel
LDFLAGS=--config ../../steckos/prg.ld65.cfg
LIBS=../../asmunit/asmunit.a ../../steckos/lib/steckschwein.a ../../steckos/tools/lib/toollib.a
UTIL_XPM_8BIT=sh ../utils/xpm_ca65_8bit.sh
UTIL_XPM_16BIT=python3 ../utils/xpm_ca65_16bit.py
all: asteroids.prg

.PHONY: all

clean:
	rm -f *.o *.bin *.prg *.labels *.res

%.res: %.xpm
	$(UTIL_XPM_16BIT) $(@:.res=.xpm) > $@

sprites.res: rock001.res rock002.res rock003.res rock004.res rock005.res rock006.res rock007.res rock008.res \
	ship.res \
	shot.res shot2.res shot3.res \
	bonus_base.res bonus_shield.res bonus_shot.res bonus_speed.res
	cat $^ > sprites.res

%.o: %.asm
	ca65 $(DEBUG) $(CA65FLAGS) -o $@ $(@:.o=.asm)

asteroids.o: asteroids.inc sprites.res

asteroids.prg: asteroids.o intro.o scoreboard.o halloffame.o
	ld65 -o $@ $(LDFLAGS) $^ $(LIBS)

asteroids: asteroids.prg
	../../transfer.py -s 0x1000 $@

emu: asteroids.prg
	steckschwein-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -upload $^
