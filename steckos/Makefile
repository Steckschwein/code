MAKEFILE=Makefile
ifndef DIST_TARGET
    DIST_TARGET=/media/dommas/STCKSCHWN/
endif

.PHONY: all clean
all: build

clean:
	(cd demo; make clean)
	(cd tools; make clean)
	(cd shell; make clean)
	(cd kernel; make clean)
	(cd bios; make clean)
	(cd libsrc; make clean)
	(cd clib/libsrc; make clean)
	rm -rf dist/*

build:
	(cd libsrc; make )
	(cd kernel; make )
	(cd bios; make )
	(cd clib/libsrc; make )
	(cd tools/lib; make )
	(cd shell; make )
	(cd tools; make )
	(cd demo; make )

test:
	(cd kernel; make test)
	(cd tools; make test)

dist: build
	./mkdist.sh $(DIST_TARGET)
