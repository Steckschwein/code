OBJ=basic.prg
ASM_INCLUDE=-I ../steckos/asminc -I ../steckos/kernel
LIBS=../steckos/lib/steckschwein.a
AR65 := $(if $(wildcard ../bin/ar65*),../bin/ar65,ar65)
CA65 := $(if $(wildcard ../bin/ca65*),../bin/ca65,ca65)
CC65 := $(if $(wildcard ../bin/cc65*),../bin/cc65,cc65)
LD65 := $(if $(wildcard ../bin/ld65*),../bin/ld65,ld65)
LDFLAGS=-Ln basic.lbl --config ../steckos/prg.ld65.cfg -m $@.map
# uncomment for a serial line version
#DEFINES=-DUART

all: $(OBJ)
clean:
	rm -f *.prg *.o *.lbl

steck_mon.o: steck_mon.asm basic.asm ext/*.asm $(LIBS)
	$(CA65) $(ASM_INCLUDE) --target none $(DEFINES)  $<

basic.prg: steck_mon.o
	$(LD65) $(LDFLAGS) steck_mon.o $(LIBS) -o basic.prg

basic.dis: basic.prg
		dcc6502 -o 0xb0fe -d -n -c $< > $@

basic: all
	../transfer.py $(OBJ)
