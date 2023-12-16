#!/bin/bash 

TARGET=dist

for i in steckos demo games progs basic ; do
    mkdir -p $TARGET/$i
done 

cp steckos/kernel/loader.prg $TARGET/
cp steckos/shell/shell.prg $TARGET/steckos/
cp steckos/tools/*.prg $TARGET/steckos/
cp steckos/demo/*.prg $TARGET/demo/


GAMES="games/dinosaur/dinosaur.prg games/pong/pong.prg games/microchess/mchess.prg"
cp $GAMES $TARGET/games/

PROGS=$(find progs -name "*.prg") 
cp $PROGS $TARGET/progs/

cp progs/ehbasic_65c02/demo/* $TARGET/basic
