#!/bin/bash

TARGET=$1
TOOLS='
    ls.prg
    ll.prg
    stat.prg
    rename.prg
    keycode.prg
    view.prg
    rm.prg
    rmdir.prg
    mkdir.prg
    cp.prg
    pwd.prg
    touch.prg
    attrib.prg
    help.prg
    wozmon.prg
    fsinfo.prg
    nvram.prg
    setdate.prg
    clear.prg
    date.prg
'

mkdir -p $TARGET/STECKOS
cp kernel/loader.bin $TARGET/LOADER.BIN
cp shell/shell.prg $TARGET/STECKOS/SHELL.PRG
cp tools/unrclock/unrclock.prg $TARGET/STECKOS/UNRCLOCK.PRG

for n in $TOOLS ; do
	un=`echo $n | awk '{print toupper($0)}'`
	cp tools/$n $TARGET/STECKOS/$un
done

