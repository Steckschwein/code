STECKOS_DIR=../..
CC65FLAGS=-I $(STECKOS_DIR)/clib/include -I $(STECKOS_DIR)/clib/include/vdp --cpu 65c02 -O

CA65FLAGS=--include-dir $(STECKOS_DIR)/asminc --include-dir $(STECKOS_DIR)/kernel -D_DEBUG
LIBS=$(STECKOS_DIR)/clib/lib/steckschwein-clib.a $(STECKOS_DIR)/lib/steckschwein.a
LDFLAGS=--config $(STECKOS_DIR)/prg.ld65.cfg -m $(basename $@).map $(LIBS)
ASM_INCLUDE=--include-dir $(STECKOS_DIR)/kernel --include-dir $(STECKOS_DIR)/asminc

OBJS=qrtiny.o qrcode.o
.PHONY: all clean

all: qrcode.prg

qrcode.prg: $(OBJS)

clean:
	rm -f *.prg *.s *.o *.map

 %.o: %.c
	cc65 $(CC65FLAGS) -t none -O $<
	ca65 $(CA65FLAGS) $(@:.o=.s)

%.o: %.asm
	ca65 $(CA65FLAGS) $(ASM_INCLUDE) $(@:.o=.asm)

%.prg: %.o $(LIBS) $(OBJS)
	ld65 $(OBJS) $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../../xmodem.sh $<

%.emu: %.prg
	steckschwein-emu -rom ../../../steckos/bios/bios.bin -sdcard ../../../steckos.img -upload $<
