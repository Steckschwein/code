MAKEFILE=Makefile
all: doc 

clean:
	rm -f *.md

doc:
	../util/asmdoc.py -d ../steckos/libsrc/ --format md -f libsrc.md
	../util/asmdoc.py -d ../steckos/kernel/ --format md -f jumptable.md --filespec="*.asm"
