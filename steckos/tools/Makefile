CC65FLAGS=-I ../clib --cpu 65c02 # --standard c89 #-Or
CA65FLAGS=-I ../asminc -I ../kernel --cpu 65c02
LIBS=../lib/steckschwein.a 
CLIB=../clib/lib/steckschwein-clib.a
LDFLAGS=-C ../prg.ld65.cfg -m $<.map $(LIBS)


TOOLS=ls.prg ll.prg stat.prg fsinfo.prg attrib.prg rename.prg help.prg view.prg touch.prg rmdir.prg mkdir.prg cp.prg pwd.prg rm.prg keycode.prg fig.prg vramtest.prg wozmon.prg rx.prg
# c tools
TOOLS+=\
  banner.prg \
  cat.prg \
  clear.prg\
  date.prg\
  crc7.prg \
  echo.prg\
  fatbench.prg \
  keyboard.prg \
  nvram.prg\
  od.prg\
  setdate.prg \
  uname.prg


.PHONY: all clean

all: $(TOOLS)
	(cd unrclock; make )
	(cd ppmview; make )

clean:
	rm -f *.prg *.o *.map
	(cd unrclock; make clean)
	(cd ppmview; make clean)

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
	../../transfer.py $< -s 0x1000
