OBJS=bf.o
TARGET=bf.prg
CA65FLAGS=--include-dir ../../steckos/kernel --include-dir ../../steckos/asminc
LIBS=../../steckos/lib/steckschwein.a

all: $(TARGET)

%.prg: $(OBJS) $(LIBS)
	cl65 --target none --config ../../steckos/prg.ld65.cfg -o $@ $(OBJS) $(LIBS)

%.o: %.s
	ca65 $(CA65FLAGS) -o $@ $<

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

clean:
	rm -f $(TARGET) $(OBJS)

brainfck: $(TARGET)
	../../xmodem.sh $(TARGET)
