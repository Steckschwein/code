OBJS=ff.o
TARGET=ff.prg
CA65FLAGS=--include-dir ../steckos/kernel --include-dir ../steckos/asminc
LIBS=--config ../steckos/prg.ld65.cfg -m $@.map ../steckos/lib/steckschwein.a ../steckos/tools/lib/toollib.a

all: $(TARGET)

%.prg: $(OBJS)
	cl65 --target none -o $@ $(OBJS) $(LIBS)

%.o: %.s
	ca65 $(CA65FLAGS) -o $@ $<

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

clean:
	rm -f $(TARGET) $(OBJS)

transfer: $(TARGET)
	../xmodem.sh $(TARGET)
emu: $(TARGET)
	steckschwein-emu -rom ../steckos/bios/bios.bin -scale 2 -sdcard ../steckos.img -upload $(TARGET)
