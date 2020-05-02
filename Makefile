MAKEFILE=Makefile
all: build

clean:
	(cd games; make clean)
	(cd steckos; make clean)
	(cd imfplayer; make clean)
	(cd edlib; make clean)
	(cd ehbasic_65c02; make clean)
	(cd asmunit; make clean)

distclean:
	rm -rf dist/LOADER.BIN dist/STECKOS dist/GAMES dist/DEMO dist/PROGS/EDLPLY.PRG dist/PROGS/BASIC.PRG dist/PROGS/IMF.PRG
	rm steckos.img

build:
	(cd asmunit; make)
	(cd steckos; make)
	(cd imfplayer; make )
	(cd edlib; make )
	(cd ehbasic_65c02; make )
	(cd games; make)


dist: build
	./mkdist.sh

img: dist
	./mkimg.sh
