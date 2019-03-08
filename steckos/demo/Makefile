CA65FLAGS=--include-dir ../asminc --include-dir ../kernel
LDFLAGS=--config ../prg.ld65.cfg ../lib/steckschwein.a
ASM_INCLUDE=--include-dir ../steckos/kernel --include-dir ../steckos/asminc

.PHONY: all clean

all: gfx7pset.prg gfx7line.prg gfx7bench.prg

clean:
	rm -f *.prg *.s *.o

%.o: %.c
	cc65 -t none -O $<
	ca65 $(CA65FLAGS) $(@:.o=.s)

%.o: %.asm
	ca65 $(CA65FLAGS) $(ASM_INCLUDE) $(@:.o=.asm)

%.prg: %.o ../lib/steckschwein.a
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../transfer.py $< -s 0x1000
