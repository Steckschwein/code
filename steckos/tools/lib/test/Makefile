DEFINES=-Dasmunit_char_out=0x200
CA65FLAGS=-I ../../../../asmunit -I ../../../asminc -I ../../../kernel $(DEFINES)
LIBS=../toollib.a ../../../lib/steckschwein.a ../../../../asmunit/asmunit.a
LDFLAGS=-C ../../../../asmunit/asmunit.cfg $(DEFINES) $(LIBS)

.PHONY: all clean

all: test_hexout test_bin2dual test_bin2asc test_rot13 test_sqrt8 test_dword2asc test_fsutil

clean:
	rm -f *.bin *.o *.dis *.log *.xml
	rm -rf target/*

%.o: %.asm ../../../../asmunit/*.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.bin: %.o $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.bin
	dcc6502 -o 0x1000 -d -n -c $< > $@

test_%: test_%.bin
	../../../../asmunit/asmunit_wrapper.sh $@.bin 1000
