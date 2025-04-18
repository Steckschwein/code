LIBS=../../steckos/lib/steckschwein.a
INCLUDES=-I ../../steckos/asminc -I ../../steckos/kernel
LDFLAGS=-C ../../steckos/prg.ld65.cfg $(LIBS)

UTIL_XPM_8BIT=sh ../utils/xpm_ca65_8bit.sh
UTIL_XPM_16BIT=python3 ../utils/xpm_ca65_16bit.py

.PHONY: clean all
all: dinosaur.prg

%.res: %.xpm
	$(UTIL_XPM_16BIT) dinosaur.sprites.xpm > dinosaur.sprites.res
	$(UTIL_XPM_16BIT) dinosaur.sprites.pterodactyl.xpm > dinosaur.sprites.pterodactyl.res
	$(UTIL_XPM_8BIT) dinosaur.chars.reload.xpm > dinosaur.chars.reload.res
	$(UTIL_XPM_8BIT) dinosaur.chars.1.xpm > dinosaur.chars.1.res
	$(UTIL_XPM_8BIT) dinosaur.chars.2.xpm > dinosaur.chars.2.res
	$(UTIL_XPM_8BIT) dinosaur.chars.3.xpm > dinosaur.chars.3.res
	$(UTIL_XPM_8BIT) dinosaur.chars.4.xpm > dinosaur.chars.4.res
	$(UTIL_XPM_8BIT) dinosaur.chars.5.xpm > dinosaur.chars.5.res
	$(UTIL_XPM_8BIT) dinosaur.chars.6.xpm > dinosaur.chars.6.res
	$(UTIL_XPM_8BIT) dinosaur.chars.1.4px.xpm > dinosaur.chars.1.4px.res
	$(UTIL_XPM_8BIT) dinosaur.chars.2.4px.xpm > dinosaur.chars.2.4px.res
	$(UTIL_XPM_8BIT) dinosaur.chars.3.4px.xpm > dinosaur.chars.3.4px.res
	$(UTIL_XPM_8BIT) dinosaur.chars.4.4px.xpm > dinosaur.chars.4.4px.res
	$(UTIL_XPM_8BIT) dinosaur.chars.5.4px.xpm > dinosaur.chars.5.4px.res
	$(UTIL_XPM_8BIT) dinosaur.chars.6.4px.xpm > dinosaur.chars.6.4px.res

	$(UTIL_XPM_8BIT) dinosaur.chars.1.xmas.xpm > dinosaur.chars.1.xmas.res
	$(UTIL_XPM_8BIT) dinosaur.chars.1.4px.xmas.xpm > dinosaur.chars.1.4px.xmas.res
	$(UTIL_XPM_8BIT) dinosaur.chars.2.xmas.xpm > dinosaur.chars.2.xmas.res
	$(UTIL_XPM_8BIT) dinosaur.chars.2.4px.xmas.xpm > dinosaur.chars.2.4px.xmas.res
	$(UTIL_XPM_8BIT) dinosaur.chars.3.xmas.xpm > dinosaur.chars.3.xmas.res
	$(UTIL_XPM_8BIT) dinosaur.chars.3.4px.xmas.xpm > dinosaur.chars.3.4px.xmas.res
	$(UTIL_XPM_8BIT) dinosaur.chars.4.xmas.xpm > dinosaur.chars.4.xmas.res
	$(UTIL_XPM_8BIT) dinosaur.chars.4.4px.xmas.xpm > dinosaur.chars.4.4px.xmas.res

clean:
	rm -f *.prg *.labels *.res *.dbg

gfx.res: *.res

%.o: %.asm *.res
	ca65 -g $(INCLUDES) $(@:.o=.asm)

%.prg: %.o $(LIBS)
	ld65 $< --dbgfile $(basename $<).dbg -Ln $(basename $<).lbl -m $(basename $<).map $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

dinosaur: all
	../../xmodem.sh dinosaur.prg

emu: dinosaur.prg
	6502msx-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -upload dinosaur.prg
