STECKOS_DIR=..
CC65FLAGS=-I $(STECKOS_DIR)/clib/include -I $(STECKOS_DIR)/clib/include/vdp --cpu 65c02 -O

CA65FLAGS=--include-dir $(STECKOS_DIR)/asminc --include-dir $(STECKOS_DIR)/kernel -D_DEBUG
LIBS=$(STECKOS_DIR)/clib/lib/steckschwein-clib.a $(STECKOS_DIR)/lib/steckschwein.a
LDFLAGS=--config $(STECKOS_DIR)/prg.ld65.cfg -m $(basename $@).map $(LIBS)
ASM_INCLUDE=--include-dir $(STECKOS_DIR)/kernel --include-dir $(STECKOS_DIR)/asminc

.PHONY: all clean plasma qrcode

all: gfx7pset.prg gfx7line.prg gfx7bench.prg gfx7sort.prg gfx6test.prg \
		rstbars.prg \
		stsdemo.prg \
		gradient.prg \
		mandel2.prg \
		mndlbrot.prg \
		vdpdemo.prg \
		rps_sim.prg	\
		hanoi.prg \
		win95.prg \
		lines.prg \
		sortdemo.prg
	(cd plasma ; make )
	(cd qrcode ; make )


clean:
	rm -f *.prg *.s *.o *.map
	(cd plasma ; make clean)
	(cd qrcode ; make clean)


 %.o: %.c
	cc65 $(CC65FLAGS) -O $<
	ca65 $(CA65FLAGS) $(@:.o=.s)

%.o: %.asm
	ca65 $(CA65FLAGS) $(ASM_INCLUDE) $(@:.o=.asm)

%.prg: %.o $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

%.prg: %.o $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../xmodem.sh $<

%.emu: %.prg
	6502msx-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -upload $<
