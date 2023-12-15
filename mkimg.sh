#!/bin/bash
size=128M

img="steckos.img"

TARGET=::/

if [ -e ${img} ] ; then
  rm ${img}
fi

truncate -s $size ${img}
mkfs -t fat -F 32 -s 2  ${img} -n "STECKOS 2_0"


mmd -i ${img} ::/steckos ::/demo ::/games ::/progs ::/basic


mcopy -i ${img}  steckos/kernel/loader.prg $TARGET/
mcopy -i ${img}  steckos/shell/shell.prg $TARGET/steckos/
mcopy -i ${img}  steckos/tools/*.prg $TARGET/steckos/
mcopy -i ${img}  steckos/demo/*.prg $TARGET/demo/



GAMES="games/dinosaur/dinosaur.prg games/pong/pong.prg games/microchess/mchess.prg"
mcopy -i ${img} $GAMES $TARGET/games/

PROGS=$(find progs -name "*.prg") 
mcopy -i ${img} $PROGS $TARGET/progs/

mcopy -i ${img} progs/ehbasic_65c02/demo/* $TARGET/basic
