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

rm -fr dist/*
mkdir -p ${TARGET}
mkdir -p dist/STECKOS
cp kernel/loader.bin dist/LOADER.BIN
cp shell/shell.prg dist/STECKOS/SHELL.PRG
cp tools/unrclock/unrclock.prg dist/STECKOS/UNRCLOCK.PRG

#for n in `ls tools/*.prg` ; do
#	filename=`basename ${n}`
#	un=`echo ${filename} | awk '{print toupper($0)}'`
#	cp $n dist/STECKOS
#done

for n in $TOOLS ; do
	un=`echo $n | awk '{print toupper($0)}'`
	cp tools/$n dist/STECKOS/$un
done

#for n in `ls tools/*/*.prg` ; do
	#filename=`basename ${n}`
	#un=`echo ${filename} | awk '{print toupper($0)}'`
	#cp $n dist/USR/BIN/$un
#done

#cp tools/xmodem/rx.prg dist/BIN/RX.PRG
#cp ehbasic/basic.prg dist/USR/BIN/BASIC.PRG
#cp imfplayer/imf.prg dist/USR/BIN/IMF.PRG
#cp edlib/edlply.prg dist/USR/BIN/EDLPLY.PRG

cp -a dist/* $TARGET && umount $TARGET
