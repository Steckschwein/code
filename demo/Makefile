CPU=65c02 
CC65FLAGS=-I ../steckos/clib/include
CA65FLAGS=-I ../steckos/asminc
LIB=../steckos/clib/lib/steckschwein-clib.a ../steckos/lib/steckschwein.a
LDFLAGS=-C ../steckos/prg.ld65.cfg $(LIB)

ADDRESS=0x1000

# Run 'make SYS=<target>' or set a SYS env
# var to build for another target system.
SYS ?= steckschwein

.PHONY: all clean
all: plasma.prg

clean:
	rm -f *.prg *.s *.o *.log

%.o: %.c
	cc65 $(CC65FLAGS) -t none --cpu $(CPU) -O $<
	ca65 $(CA65FLAGS) $(@:.o=.s)
  
%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

test.%.bin: test.%.o ppmview.main.o $(TEST_LIBS)
	ld65 $(TEST_LDFLAGS) $< $(<:test.%=%) $(TEST_LIBS) -o $@

test.%: test.%.bin
	../../../asmunit/asmunit_wrapper.sh $@.bin $(ADDRESS)

%.prg: %.o $(LIB)
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../transfer.py $< -s $(ADDRESS)