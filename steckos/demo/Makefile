CA65FLAGS=--include-dir ../asminc --include-dir ../kernel -D_DEBUG
LDFLAGS=--config ../prg.ld65.cfg -m $@.map ../lib/steckschwein.a
ASM_INCLUDE=--include-dir ../steckos/kernel --include-dir ../steckos/asminc

.PHONY: all clean plasma

all: gfx7pset.prg gfx7line.prg gfx7bench.prg gfx7sort.prg gfx6test.prg \
		rstbars.prg \
		stsdemo.prg \
		gradient.prg \
		mndlbrot.prg \
		plasma

plasma:
	(cd plasma; make)
clean:
	rm -f *.prg *.s *.o *.map
	(cd plasma ; make clean)

 %.o: %.c
	cc65 -t none -O $<
	ca65 $(CA65FLAGS) $(@:.o=.s)

%.o: %.asm
	ca65 $(CA65FLAGS) $(ASM_INCLUDE) $(@:.o=.asm)

stsdemo.prg: stsdemo.o ../lib/steckschwein.a
	ld65 $< $(LDFLAGS) -o $@

%.prg: %.o ../lib/steckschwein.a
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../xmodem.sh $<

%.emu: %.prg
	steckschwein-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -upload $<
