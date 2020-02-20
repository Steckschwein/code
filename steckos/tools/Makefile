CC65FLAGS=-I ../clib
CA65FLAGS=-I ../asminc -I ../kernel
LIBS=../lib/steckschwein.a lib/toollib.a
CLIB=../clib/lib/steckschwein-clib.a
LDFLAGS=-C ../prg.ld65.cfg -m $<.map $(LIBS)


TOOLS=ls.prg ll.prg stat.prg fsinfo.prg attrib.prg rename.prg help.prg view.prg touch.prg rmdir.prg mkdir.prg cp.prg pwd.prg rm.prg du.prg keycode.prg fig.prg vramtest.prg wozmon.prg
# c tools
TOOLS+=\
  clear.prg\
  echo.prg\
  nvram.prg\
  od.prg\
  uname.prg\
  date.prg\
  setdate.prg \
  crc7.prg


.PHONY: all clean

all: $(TOOLS)
	(cd lib; make )
	(cd unrclock; make )
	(cd xmodem; make )
	(cd ppmview; make )
#	(cd clavier; make )

clean:
	rm -f *.prg *.s *.o *.map
	(cd unrclock; make clean)
	(cd xmodem; make clean)
	(cd ppmview; make clean)
#	(cd clavier; make clean)

%.prg: %.c $(LIBS) $(CLIB)
	cl65 -t none $(CA65FLAGS) $(CC65FLAGS) $< $(CLIB) $(LDFLAGS) -o $@

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.prg: %.o $(LIBS)
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

ls.prg: ls.o ls_entry_short.o
	cl65 ls.o $(CA65FLAGS) --target none  ls_entry_short.o $(LDFLAGS) -o ls.prg
ll.prg: ls.o ls_entry_long.o
	cl65 ls.o ls_entry_long.o $(CA65FLAGS) --target none $(LDFLAGS) -o ll.prg
stat.prg: ls.o ls_entry_stat.o
	cl65 ls.o ls_entry_stat.o $(CA65FLAGS) --target none $(LDFLAGS) -o stat.prg

%: %.prg
	../../transfer.py $< -s 0x1000
