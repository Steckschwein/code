OBJS=snes.o
TARGET=snes.prg
STECKOS=../steckos
CA65FLAGS=--include-dir $(STECKOS)/asminc --include-dir $(STECKOS)/kernel
LDFLAGS=--config $(STECKOS)/prg.ld65.cfg --lib $(STECKOS)/lib/steckschwein.a --mapfile snes.map
LIBS=$(STECKOS)/lib/steckschwein.a $(STECKOS)/tools/lib/toollib.a

all: $(TARGET)

%.prg: $(OBJS) $(LIBS)
	cl65 --target none $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

%.o: %.asm
	ca65 $(CA65FLAGS) -o $@ $<

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

clean:
	rm -f $(TARGET) $(OBJS)

transfer: $(TARGET)
	../xmodem.sh $(TARGET)
