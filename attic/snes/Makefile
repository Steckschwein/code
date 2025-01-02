OBJS=snes.o
TARGET=snes.prg
STECKOS=../../steckos
CA65FLAGS=--include-dir $(STECKOS)/asminc --include-dir $(STECKOS)/kernel
LIBS=$(STECKOS)/lib/steckschwein.a
LDFLAGS=--config $(STECKOS)/prg.ld65.cfg $(LIBS) --mapfile snes.map

all: $(TARGET)

%.prg: $(OBJS) $(LIBS)
	cl65 -t none $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

%.o: %.asm
	ca65 $(CA65FLAGS) -o $@ $<

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

clean:
	rm -f $(TARGET) $(OBJS)

transfer: $(TARGET)
	../xmodem.sh $(TARGET)

%.emu: %.prg
	6502msx-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -joy1 SNES -upload $<
