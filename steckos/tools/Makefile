CC65FLAGS=-I ../clib
CA65FLAGS=-I ../asminc -I ../kernel
LDFLAGS=--config ../prg.ld65.cfg ../lib/steckschwein.a ../clib/lib/steckschwein-clib.a
ASM_INCLUDE=--include-dir ../steckos/kernel --include-dir ../steckos/asminc
TOOLLIB=lib/toollib.a

TOOLS=ls.prg ll.prg stat.prg fsinfo.prg attrib.prg rename.prg help.prg view.prg touch.prg rmdir.prg mkdir.prg cp.prg pwd.prg rm.prg du.prg keycode.prg fig.prg vramtest.prg wozmon.prg
# c tools
TOOLS+=\
  clear.prg\
  echo.prg\
  nvram.prg\
  od.prg\
  uname.prg
#  setdate.prg\
#  date.prg\
  
.PHONY: all clean


all: toollib $(TOOLS)
	(cd unrclock; make )
	(cd xmodem; make )
	(cd ppmview; make )

clean:
	rm -f *.prg *.s *.o toollib.a
	(cd unrclock; make clean)
	(cd xmodem; make clean)
	(cd ppmview; make clean)

toollib:
	( cd lib ; make )

%.o: %.c
	cc65 -t none $(CC65FLAGS) -O $<
	ca65 $(CA65FLAGS) $(@:.o=.s)

%.o: %.asm
	ca65 $(CA65FLAGS) $(ASM_INCLUDE) $(@:.o=.asm)

%.prg: %.o toollib ../lib/steckschwein.a
	ld65 $< $(LDFLAGS) $(TOOLLIB) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

ls.prg: toollib ls.o ls_entry_short.o
	cl65 ls.o ls_entry_short.o $(CA65FLAGS) --target none $(LDFLAGS) $(TOOLLIB) -o ls.prg
ll.prg: toollib ls.o ls_entry_long.o
	cl65 ls.o ls_entry_long.o $(CA65FLAGS) --target none $(LDFLAGS) $(TOOLLIB) -o ll.prg
stat.prg: toollib ls.o ls_entry_stat.o
	cl65 ls.o ls_entry_stat.o $(CA65FLAGS) --target none $(LDFLAGS) $(TOOLLIB) -o stat.prg

%: %.prg
	../../transfer.py $< -s 0x1000
