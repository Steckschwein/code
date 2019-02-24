MAKEFILE=Makefile
ifndef DIST_TARGET
    DIST_TARGET=/media/dommas/STCKSCHWN/
endif

all: build

clean:
	(cd test; make clean)
	(cd tools; make clean)
	(cd shell; make clean)
	(cd libsrc; make clean)
	(cd kernel; make clean)
	rm -rf dist/*

lib/steckschwein-kernel.lib:
	(cd kernel; make )
	(cd libsrc ; make )

lib: kernel lib/steckschwein-kernel.lib

build: lib
	(cd tools/lib; make )
	(cd shell; make )
	(cd tools; make )
	(cd test; make )

test:
	(cd kernel; make test)
	(cd tools; make test)

dist: build
	./mkdist.sh $(DIST_TARGET)
