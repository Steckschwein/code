OBJS=sort.o
TARGET=sort.prg
LIBS=../steckos/tools/lib/toollib.a
LDFLAGS=--config ../steckos/prg.ld65.cfg ../steckos/lib/steckschwein.a
CA65FLAGS=--include-dir ../steckos/kernel --include-dir ../steckos/asminc


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
