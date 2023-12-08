#!/bin/bash
size=128M

img="steckos.img"

if [ -e ${img} ] ; then
  rm ${img}
fi

truncate -s $size ${img}
mkfs -t fat -F 32 -s 2 ${img} -n "STECKOS 2_0"
mcopy -i ${img} -s dist/* ::/

