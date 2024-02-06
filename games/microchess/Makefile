OBJ=mchess.prg
LIBS=../../steckos/lib/steckschwein.a
INCLUDES=-I ../../steckos/asminc -I ../../steckos/kernel
LDFLAGS=-C ../../steckos/prg.ld65.cfg


all: $(OBJ)
clean:
	rm -f *.prg *.o

%.o: %.asm
	ca65 -t none --cpu 65c02 $(INCLUDES) --feature labels_without_colons $(@:.o=.asm)

%.prg: %.o
	ld65 $(LDFLAGS) $< $(LIBS) -o $@


transfer: all
	../../xmodem.sh mchess.prg
