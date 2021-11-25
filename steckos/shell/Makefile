LIBS=../lib/steckschwein.a
CAFLAGS=-I ../asminc -I ../kernel
LDFLAGS=-C ../prg.ld65.cfg

#DEBUG=-DDEBUG FIXME

.PHONY: all clean
all: version.inc shell.prg

.PHONY: clean
clean:
	rm -f *.o *.prg *.map *.txt version.inc

version.inc:
	echo -n ".byte \"`git rev-parse --short HEAD`\"" > version.inc

%.o: %.asm
	ca65 --target none $(DEBUG) $(CAFLAGS) $<

shell.prg: version.inc shell.o $(LIBS)
	ld65 $(LDFLAGS) -m shell.map -o shell.prg shell.o $(LIBS)

shell: shell.prg
	../../transfer.py shell.prg

%.dis: %.prg
	dcc6502 -o 0xd7fe -d -n -c $< > $@
