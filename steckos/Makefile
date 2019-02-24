MAKEFILE=Makefile
ifndef DIST_TARGET
    DIST_TARGET=/media/dommas/STCKSCHWN/
endif

.PHONY: all clean
all: build

clean:
	(cd tools; make clean)
	(cd shell; make clean)
	(cd libsrc; make clean)
	(cd kernel; make clean)
	rm -rf dist/*

build:
	(cd kernel; make )
	(cd libsrc; make )
	(cd tools/lib; make )
	(cd shell; make )
	(cd tools; make )

test:
	(cd kernel; make test)
	(cd tools; make test)

dist: build
	./mkdist.sh $(DIST_TARGET)
