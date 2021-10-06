#!/bin/bash

TARGET=dist


cp steckos/kernel/loader.bin $TARGET/LOADER.BIN

mkdir -p $TARGET/STECKOS
cp steckos/shell/shell.prg $TARGET/STECKOS/SHELL.PRG

for n in steckos/tools/*.prg ; do
	un=`basename $n | awk '{print toupper($0)}'`
    cp $n $TARGET/STECKOS/$un
done

mkdir -p $TARGET/DEMO
for n in steckos/demo/*.prg ; do
    un=$(basename $n | awk '{print toupper($0)}')
    cp $n $TARGET/DEMO/$un
done

GAMES="games/dinosaur/dinosaur.prg games/pong/pong.prg games/microchess/mchess.prg"
mkdir -p $TARGET/GAMES
for n in $GAMES ; do
    un=$(basename $n | awk '{print toupper($0)}')
    cp $n $TARGET/GAMES/$un
done

PROGS="progs/unrclock/unrclock.prg progs/ppmview/ppmview.prg progs/imfplayer/imf.prg progs/ehbasic_65c02/basic.prg progs/edlib/edlply.prg progs/clavier/clavier.prg"
mkdir -p $TARGET/PROGS
for n in $PROGS ; do
    un=$(basename $n | awk '{print toupper($0)}')
    cp $n $TARGET/PROGS/$un
done

mkdir -p $TARGET/BASIC
for n in progs/ehbasic_65c02/demo/* ; do
    un=$(basename $n | awk '{print toupper($0)}')
    cp $n $TARGET/BASIC/$un
done
