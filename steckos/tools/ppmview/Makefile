CA65FLAGS=-v -v --include-dir ../../asminc --include-dir ../../../asmunit --include-dir ../../kernel
LDFLAGS=--config ../../prg.ld65.cfg
LIBS=../lib/toollib.a ../../lib/steckschwein.a
TEST_LIBS=$(LIBS) ../../../asmunit/asmunit.a
TEST_LDFLAGS=--config test.cfg -Dasmunit_char_out=0x200

ADDRESS=0x1000

.PHONY: all clean
all: ppmview.prg test.ppmview.main

clean:
	rm -f *.prg *.o

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

test.%.bin: test.%.o $(TEST_LIBS) $(<:test.%=%)
	ld65 $(TEST_LDFLAGS) $< $(<:test.%=%) $(TEST_LIBS) -o $@

test.%: test.%.bin
	../../../asmunit/asmunit_wrapper.sh $@.bin $(ADDRESS)

%.prg: %.main.o %.o $(LIBS)
	ld65 $(LDFLAGS) ppmview.o ppmview.main.o $(LIBS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../../transfer.py $< -s $(ADDRESS)