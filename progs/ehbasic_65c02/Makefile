OBJ=basic.prg
ASM_INCLUDE=-I ../../steckos/asminc -I ../../steckos/kernel
LIBS=../../steckos/lib/steckschwein.a
AR65 := $(if $(wildcard ../bin/ar65*),../bin/ar65,ar65)
CA65 := $(if $(wildcard ../bin/ca65*),../bin/ca65,ca65)
CC65 := $(if $(wildcard ../bin/cc65*),../bin/cc65,cc65)
LD65 := $(if $(wildcard ../bin/ld65*),../bin/ld65,ld65)
LDFLAGS=-Ln basic.lbl --config ../../steckos/prg.ld65.cfg -m $@.map

all: $(OBJ)
clean:
	rm -f *.prg *.o *.lbl

%.o: %.asm
	$(CA65) $(ASM_INCLUDE) --target none $(DEFINES) $<

basic.o: basic.asm ext/gfx.asm $(LIBS)
	$(CA65) $(ASM_INCLUDE) --target none $(DEFINES) $<

basic.prg: basic.o ext/gfx.o
	$(LD65) $(LDFLAGS) basic.o ext/gfx.o $(LIBS) -o basic.prg
	grep "^BSS .*00E[4-9]" $@.map && echo "FAIL - SEGMENT OVERFLOW" && rm -f $@ && exit 1 || exit 0

basic.dis: basic.prg
		dcc6502 -o 0xb0fe -d -n -c $< > $@

basic: all
	../../xmodem.sh $(OBJ)

basic.emu: basic.prg
	6502msx-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -upload $<
