MAKEFILE=Makefile

.PHONY: all clean
all: build

clean:
	(cd demo; make clean)
	(cd tools; make clean)
	(cd shell; make clean)
	(cd clib/libsrc; make clean)
	(cd bios; make clean)
	(cd kernel; make clean)
	(cd libsrc; make clean)

build:
	(cd libsrc; make )
	(cd kernel; make )
	(cd bios; make )
	(cd clib/libsrc; make )
	(cd shell; make )
	(cd tools; make )
	(cd demo; make )

test:
	(cd libsrc; make test)
	(cd kernel; make test)

img: build
	./mkimg.sh
