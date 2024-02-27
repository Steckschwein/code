MAKEFILE=Makefile
all: doc 

clean:
	rm -f *.md

doc:
	../util/asmdoc.py -d ../steckos/libsrc/ --format md --title library -f libsrc.md
	../util/asmdoc.py -d ../steckos/kernel/ --format md --title jumptable -f jumptable.md --filespec="*.asm"
