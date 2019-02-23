OBJS=fortune.o
TARGET=fortune.prg
CA65FLAGS=--include-dir ../steckos/kernel --include-dir ../steckos/asminc
LIBS=../steckos/tools/lib/toollib.a

all: $(TARGET)

%.prg: $(OBJS) $(LIBS)
	cl65 --target none --config ../steckos/kernel/steckosapp.cfg -o $@ $(OBJS) $(LIBS)

%.o: %.asm
	ca65 $(CA65FLAGS) -o $@ $<

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

clean:
	rm -f $(TARGET) $(OBJS)

transfer: $(TARGET)
	../transfer.py $(TARGET)
