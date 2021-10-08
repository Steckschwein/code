STECKOS_DIR=../..
CPU=65c02 
CC65FLAGS=-I $(STECKOS_DIR)/clib/include
CA65FLAGS=-I $(STECKOS_DIR)/asminc
LIBS=$(STECKOS_DIR)/clib/lib/steckschwein-clib.a $(STECKOS_DIR)/lib/steckschwein.a
LDFLAGS=-C $(STECKOS_DIR)/prg.ld65.cfg $(LIBS)

ADDRESS=0x1000

# Run 'make SYS=<target>' or set a SYS env
# var to build for another target system.
SYS ?=steckschwein

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

%.prg: %.o $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../transfer.py $< -s $(ADDRESS)
