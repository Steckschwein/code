MAKEFILE=Makefile
all: build

clean:
	(cd progs; make clean)
	(cd games; make clean)
	(cd steckos; make clean)
	(cd asmunit; make clean)
	(cd doc; make clean)
	rm -f steckos.img


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
	(cd doc; make)
