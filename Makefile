MAKEFILE=Makefile
all: build

clean:
	(cd progs; make clean)
	(cd games; make clean)
	(cd steckos; make clean)
	(cd asmunit; make clean)
	if [ -e steckos.img ] ; then rm steckos.img ; fi

distclean:
	rm -rf dist/LOADER.PRG dist/STECKOS dist/GAMES dist/DEMO dist/PROGS/EDLPLY.PRG dist/PROGS/BASIC.PRG dist/PROGS/IMF.PRG
	if [ -e steckos.img ] ; then rm steckos.img ; fi

build:
	(cd asmunit; make)
	(cd steckos; make)
	(cd progs; make)
	(cd games; make)


dist: build
	./mkdist.sh

img: dist
	./mkimg.sh
