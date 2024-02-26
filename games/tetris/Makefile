CC65FLAGS=-I ../../steckos/clib/include -I ../../steckos/clib/include/vdp -I ../../steckos/clib --cpu 65c02 --debug-info # --standard c99 #-Or
CLIB=../../steckos/clib/lib/steckschwein-clib.a
CA65FLAGS=-I ../../steckos/asminc -I ../../asmunit -I ../../steckos/kernel
LIBS=../../steckos/lib/steckschwein.a
LDFLAGS=-C ../../steckos/prg.ld65.cfg

.PHONY: all clean
all: snake.prg

clean:
	rm -f *.bin *.prg *.o *.log

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.prg: %.c $(LIBS) $(CLIB)
	cl65 -t none $(CA65FLAGS) $(CC65FLAGS) $(LDFLAGS) $< $(CLIB) $(LIBS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../xmodem.sh $<

%.emu: %.prg
	steckschwein-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -upload $^
