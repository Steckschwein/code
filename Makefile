MAKEFILE=Makefile
all: build

clean:
	(cd games; make clean)
	(cd steckos; make clean)
	(cd imfplayer; make clean)
	(cd edlib; make clean)
	(cd ehbasic; make clean)
	(cd asmunit; make clean)
	rm -rf dist/LOADER.BIN dist/STECKOS dist/GAMES dist/DEMO dist/PROGS/EDLPLY.PRG dist/PROGS/BASIC.PRG dist/PROGS/IMF.PRG

build:
	(cd asmunit; make)
	(cd steckos; make)
	(cd imfplayer; make )
	(cd edlib; make )
	(cd ehbasic; make )
	(cd games; make)


dist: build
	./mkdist.sh

img: dist
	./mkimg.sh
