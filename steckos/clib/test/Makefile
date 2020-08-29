CC65FLAGS=-I .. --target none --cpu 65c02 --standard c99
CA65FLAGS=-I ../../asminc -I ../../kernel
CLIB=../lib/steckschwein-clib.a
LIBS=../../lib/steckschwein.a ../../tools/lib/toollib.a
LDFLAGS=-C ../../prg.ld65.cfg

all: mainarg.prg coniotst.prg time-test.prg

.PHONY: clean

clean:
	rm -f *.prg *.s *.o

%.prg: %.c $(LIBS) $(CLIB)
	cl65 -t none $(CA65FLAGS) $(CC65FLAGS) $< $(CLIB) $(LIBS) $(LDFLAGS) -o $@

coniotst: coniotst.prg
	../../transfer.py coniotst.prg -s 0x1000

mainarg: mainarg.prg
	../../transfer.py mainarg.prg -s 0x1000

stdio_test: stdio_test.prg
	../../transfer.py stdio_test.prg -s 0x1000

time-test: time-test.prg
	../../transfer.py time-test.prg -s 0x1000

%: %.prg
	../../transfer.py $<
