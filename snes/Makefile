OBJS=snes.o
TARGET=snes.prg
STECKOS=../steckos
CA65FLAGS=--include-dir $(STECKOS)/asminc --include-dir $(STECKOS)/kernel
LDFLAGS=--define __LOADADDR__=$(APP_START) --config $(STECKOS)/prg.ld65.cfg --lib $(STECKOS)/lib/steckschwein.a --lib $(STECKOS
LIBS=$(STECKOS)/lib/steckschwein.a $(STECKOS)/tools/lib/toollib.a

all: $(TARGET)

%.prg: $(OBJS) $(LIBS)
	cl65 --target none --config ../steckos/prg.ld65.cfg -o $@ $(OBJS) $(LIBS)

%.o: %.asm
	ca65 $(CA65FLAGS) -o $@ $<

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

clean:
	rm -f $(TARGET) $(OBJS)

transfer: $(TARGET)
	../transfer.py $(TARGET)
