DEBUG=-D__DEBUG
#DEBUG+=-D__NO_SOUND
DEBUG+=-D__NO_BOOT
DEBUG+=-D__NO_INTRO

CLIB=../../steckos/clib/lib/steckschwein-clib.a
CC65FLAGS=-I ../../steckos/clib -I ../../steckos/clib/include

OBJS=wow.o intro.o

CA65FLAGS=-D__STECKSCHWEIN__ -I ../../asmunit -I ../../steckos/asminc -I ../../steckos/kernel $(DEBUG)
LIBS=../../asmunit/asmunit.a ../../steckos/lib/steckschwein.a
LDFLAGS=-C ../../steckos/prg.ld65.cfg -m wow.map

.PHONY: all clean

all: wow.prg

clean:
	rm -f *.prg *.s *.o

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

wow.prg: $(OBJS) $(LIBS)
	ld65 $(LDFLAGS) $(OBJS) $(LIBS) -o $@

wow: wow.prg
	../../xmodem.sh wow.prg

emu: wow.prg
	6502msx-emu -rom ../../steckos/bios/bios.bin -sdcard ../../steckos.img -upload $<

#https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7EQaLTgGaPL_VGRyXpupFka8nJUtsy9sKNgAOUoo7H8Iw7SLzQQ
