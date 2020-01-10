MAKEFILE=Makefile

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

img: build
	./mkimg.sh
