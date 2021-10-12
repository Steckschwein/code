
TRANSFER=../../../transfer.py

CC65FLAGS=--target none --cpu 65c02 --standard c99 -I ../include
CA65FLAGS=-I ../../asminc
CLIB=../lib/steckschwein-clib.a
LIBS=../../lib/steckschwein.a
LDFLAGS=-C ../../prg.ld65.cfg

all: mainarg.prg coniotst.prg time-test.prg apitest.prg

.PHONY: clean

clean:
	rm -f *.prg *.s *.o

%.prg: %.c $(LIBS) $(CLIB)
	cl65 $(CA65FLAGS) $(CC65FLAGS) $< $(CLIB) $(LIBS) $(LDFLAGS) -o $@

%: %.prg
	$(TRANSFER) $<
