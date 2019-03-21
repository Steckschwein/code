DEFINES=-Dasmunit_char_out=0x200
CA65FLAGS=$(DEFINES)
LDFLAGS=--config asmunit.cfg $(DEFINES)
OBJS=asmunit.o

.PHONY: all clean test

all: test asmunit.a

test: test.asmunit

clean:
	rm -f *.o *.a *.log *.map

%.o: %.asm asmunit.inc
	ca65 $(CA65FLAGS) $(@:.o=.asm)

asmunit.a: $(OBJS) test.asmunit
	ar65 a asmunit.a $(OBJS)

%.bin: %.o asmunit.o
	ld65 -Ln $(<).vmap --dbgfile $(<).dbg $(LDFLAGS) $< asmunit.o -o $@

%.dis: %.bin
	dcc6502 -o 0x1000 -d -n -c $< > $@

test.%: test.%.bin
	#for l in `grep ".test" $@.o.vmap | sort | cut -d ' ' -f2`;do echo $$l; ./asmunit_wrapper.sh $@.bin 0x$$l false ; done
	./asmunit_wrapper.sh $@.bin 1000 false # false - do not fail on error here, we compare the result with our expectation for failed test
	#diff $@.bin.log $@.bin.expect
