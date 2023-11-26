#!/bin/bash
size=256
sectors_clus=4
alignment=1048576

img="steckos.img"
truncate -s $((size * (1<<20) )) "${img}"
parted --machine --script "${img}" mklabel msdos mkpart primary fat32 "${alignment}B" '100%' 
mformat -i "${img}"@@"${alignment}" -c $sectors_clus -F -t $((size>>20))  #-v "steckos"
foo=$(sudo kpartx -av "$img")
if [ $? -ne 0 ] ; then
    exit 1
fi

mcopy -i "${img}"@@"${alignment}" -s dist/* ::/

