MAKEFILE=Makefile
all: build

clean:
	(cd progs; make clean)
	(cd games; make clean)
	(cd steckos; make clean)
	(cd asmunit; make clean)
	if [ -e steckos.img ] ; then rm steckos.img ; fi
	rm libsrc.html


build:
	(cd asmunit; make)
	(cd steckos; make)
	(cd progs; make)
	(cd games; make)

test: build
	(cd steckos; make test)

img: build
	./mkimg.sh

doc:
	./util/asmdoc.py -d steckos/libsrc/ --format md -f libsrc.md
