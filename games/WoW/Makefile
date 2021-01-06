DEBUG=-D__DEBUG
#DEBUG+=-D__NO_SOUND
DEBUG+=-D__NO_BOOT
DEBUG+=-D__NO_INTRO

CLIB=../../steckos/clib/lib/steckschwein-clib.a
CC65FLAGS=-I ../../steckos/clib -I ../../steckos/clib/include

LIBS=
CA65FLAGS=-I $(CC65_HOME)/asminc $(DEBUG)

OBJS=wow.o intro.o

CA65FLAGS_STS=-D__STECKSCHWEIN__ -I ../../asmunit -I ../../steckos/asminc -I ../../steckos/kernel $(DEBUG)
OBJS_STS=$(OBJS)
LIBS_STS=../../asmunit/asmunit.a ../../steckos/lib/steckschwein.a
LDFLAGS_STS=-C ../../steckos/prg.ld65.cfg -m wow.map

.PHONY: all clean

all: wow.prg

clean:
	rm -f *.prg *.s *.o

%.o: %.asm
	ca65 $(CA65FLAGS_STS) $(@:.o=.asm)
	
wow.prg: $(OBJS_STS) $(LIBS_STS)
	ld65 $(LDFLAGS_STS) $(OBJS_STS) $(LIBS_STS) -o $@ 
		
wow: wow.prg
	../../transfer.py wow.prg -s 0x1000
	
#https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7EQaLTgGaPL_VGRyXpupFka8nJUtsy9sKNgAOUoo7H8Iw7SLzQQ
