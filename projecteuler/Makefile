CPU=65c02
CC65FLAGS=--cpu $(CPU) -I ../steckos/clib/include
CA65FLAGS=--cpu $(CPU) -I ../steckos/asminc -I ../steckos/kernel
LIBS=../steckos/lib/steckschwein.a ../steckos/tools/lib/toollib.a
CLIB=../steckos/clib/lib/steckschwein-clib.a
LDFLAGS=-C ../steckos/prg.ld65.cfg -m $<.map $(LIBS)

PRGS=problem1.prg \
	problem2.prg

.PHONY: all clean

all: $(PRGS)

clean:
	rm -f *.prg *.s *.o *.map

#%.prg: %.c $(LIBS) $(CLIB)
#	cl65 -t none $(CA65FLAGS) $(CC65FLAGS) $< $(CLIB) $(LDFLAGS) -o $@

%.prg: %.o $(LIBS)
	ld65 $< $(CLIB) $(LDFLAGS) -o $@

#%.o: %.asm
#	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.o: %.c
	cc65 $(CC65FLAGS) -t none --cpu $(CPU) -O $<
	ca65 $(CA65FLAGS) $(@:.o=.s)

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../transfer.py $< -s 0x1000
