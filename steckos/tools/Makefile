CC65FLAGS=-I ../clib/include -I ../clib/ --cpu 65c02 # --standard c89 #-Or
CA65FLAGS=-I ../asminc -I ../kernel --cpu 65c02
LIBS=../lib/steckschwein.a
CLIB=../clib/lib/steckschwein-clib.a
LDFLAGS=-C ../prg.ld65.cfg -m $<.map $(LIBS)

#TOOLS=ls.prg ll.prg stat.prg fsinfo.prg attrib.prg rename.prg help.prg view.prg touch.prg rmdir.prg mkdir.prg cp.prg pwd.prg rm.prg keycode.prg fig.prg vramtest.prg wozmon.prg rx.prg

TOOLS=cls.prg ls.prg stat.prg attrib.prg rename.prg help.prg touch.prg cp.prg keycode.prg vramtest.prg wozmon.prg
# c tools
TOOLS+=\
  banner.prg \
  cat.prg \
  clear.prg\
  date.prg\
  crc7.prg \
  echo.prg\
  iobench.prg \
  keyboard.prg \
  nvram.prg\
  od.prg\
  setdate.prg \
  uname.prg \
  fsinfo.prg \
	dirtest.prg \
	stecklnk.prg

.PHONY: all clean

all: $(TOOLS)

clean:
	rm -f *.prg *.o *.map

%.prg: %.c $(LIBS) $(CLIB)
	cl65 -t none $(CA65FLAGS) $(CC65FLAGS) $< $(CLIB) $(LDFLAGS) -o $@

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.o: %.s
	ca65 $(CA65FLAGS) $(@:.o=.s)

%.prg: %.o $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../xmodem.sh $<

%.emu: %.prg
	steckschwein-emu -rom ../bios/bios.bin -sdcard ../../steckos.img -upload $<
