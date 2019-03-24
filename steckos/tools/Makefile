CC65FLAGS=-I ../clib -D_CC65_V2_17_
CA65FLAGS=-I ../asminc -I ../kernel
LIBS=../lib/steckschwein.a lib/toollib.a
CLIB=../clib/lib/steckschwein-clib.a
LDFLAGS=-C ../prg.ld65.cfg $(LIBS)


TOOLS=ls.prg ll.prg stat.prg fsinfo.prg attrib.prg rename.prg help.prg view.prg touch.prg rmdir.prg mkdir.prg cp.prg pwd.prg rm.prg du.prg keycode.prg fig.prg vramtest.prg wozmon.prg
# c tools
TOOLS+=\
  clear.prg\
  echo.prg\
  nvram.prg\
  od.prg\
  uname.prg\
  date.prg\
  setdate.prg
  
  
.PHONY: all clean

all: toollib $(TOOLS)
	(cd unrclock; make )
	(cd xmodem; make )
	(cd ppmview; make )
	(cd clavier; make )

clean:
	rm -f *.prg *.s *.o toollib.a
	(cd unrclock; make clean)
	(cd xmodem; make clean)
	(cd ppmview; make clean)
	(cd clavier; make clean)

toollib:
	( cd lib ; make )

%.prg: %.c $(LIBS) $(CLIB)
	cl65 -t none $(CA65FLAGS) $(CC65FLAGS) $< $(LDFLAGS) $(CLIB) -o $@

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.prg: %.o toollib $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

ls.prg: toollib ls.o ls_entry_short.o
	cl65 ls.o ls_entry_short.o $(CA65FLAGS) --target none $(LDFLAGS) -o ls.prg
ll.prg: toollib ls.o ls_entry_long.o
	cl65 ls.o ls_entry_long.o $(CA65FLAGS) --target none $(LDFLAGS) -o ll.prg
stat.prg: toollib ls.o ls_entry_stat.o
	cl65 ls.o ls_entry_stat.o $(CA65FLAGS) --target none $(LDFLAGS) -o stat.prg

%: %.prg
	../../transfer.py $< -s 0x1000
