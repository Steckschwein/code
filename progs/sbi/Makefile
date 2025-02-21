CPU=65c02
CC65FLAGS=-I ../../steckos/clib/include
CA65FLAGS=-I ../../steckos/asminc
LIBS=../../steckos/clib/lib/steckschwein-clib.a ../../steckos/lib/steckschwein.a
LDFLAGS=-C ../../steckos/prg.ld65.cfg $(LIBS)# -Dchar_out=0xFFB3

.PHONY: all clean

all: sbi.prg opl.prg

clean:
	rm -f *.prg *.s *.o

%.o: %.c
	cc65 $(CC65FLAGS) --cpu $(CPU) -O $<

%.prg: %.c $(LIBS)
	cl65 -t none $(CA65FLAGS) $(CC65FLAGS) $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../xmodem.sh $<

%.emu: %.prg
	6502msx-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -upload $<
