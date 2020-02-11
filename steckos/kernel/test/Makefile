OUT_ADDRESS=0x200
DEFINES=-Dasmunit_char_out=0x200
KERNEL_ADDRESS=0x1000
CA65FLAGS=-I ../../../asmunit -I ../../asminc -I ../ $(DEFINES)
LIBS=../../../asmunit/asmunit.a ../../lib/steckschwein.a
LDFLAGS=-C ../../../asmunit/asmunit.cfg $(DEFINES)

# testing purpose of kernel api from client point of view
LIBS_PRG=../../tools/lib/toollib.a ../../lib/steckschwein.a
LDFLAGS_PRG=-C ../../prg.ld65.cfg

.PHONY: all clean

all: test.util test.textui textui.test.prg

clean:
	rm -f *.prg *.bin *.o *.dis *.log

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

test.%.bin: test.%.o $(LIBS) $(<:test.%=%)
	ld65 $(LDFLAGS) $< ../$(<:test.%=%) $(LIBS) -o $@

test.matcher.bin: test.matcher.o ../matcher.o ../util.o $(LIBS)
	ld65 $(LDFLAGS) $< ../matcher.o ../util.o $(LIBS) -o $@

%.prg: %.o $(LIBS)
	ld65 $(LDFLAGS_PRG) $< $(LIBS_PRG) -o $@

%.dis: %.bin
	dcc6502 -o $(KERNEL_ADDRESS) -d -n -c $< > $@

%.dbg: %.bin
	py65mon -m 65c02 --output 0x0200 $< $(KERNEL_ADDRESS)

test.%: test.%.bin
	../../../asmunit/asmunit_wrapper.sh $@.bin $(KERNEL_ADDRESS)

%: %.prg
	../../../transfer.py $<

../../../asmunit/asmunit.a:
	(cd ../../../asmunit ; make)