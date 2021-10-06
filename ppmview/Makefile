CA65FLAGS=-I ../steckos/asminc -I ../asmunit -I ../steckos/kernel
LDFLAGS=-C ../steckos/prg.ld65.cfg
LIBS=../steckos/lib/steckschwein.a
TEST_LIBS=$(LIBS) ../asmunit/asmunit.a
TEST_LDFLAGS=-C ../asmunit/asmunit.cfg -Dasmunit_char_out=0x200

ADDRESS=0x1000

.PHONY: all clean
all: ppmview.prg

clean:
	rm -f *.bin *.prg *.o *.log

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

test.%.bin: test.%.o $(TEST_LIBS)
	ld65 $(TEST_LDFLAGS) $< $(<:test.%=%) $(TEST_LIBS) -o $@

test.%: test.%.bin
	../../../asmunit/asmunit_wrapper.sh $@.bin $(ADDRESS)

%.prg: %.o $(LIBS)
	ld65 $(LDFLAGS) ppmview.o $(LIBS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../../transfer.py $< -s $(ADDRESS)

emu: ppmview.prg
	steckschwein-emu -rom ../../bios/bios.bin -sdcard ../../../steckos.img -upload $^
