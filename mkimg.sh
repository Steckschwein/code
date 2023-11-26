#!/bin/bash
size=256
sectors_clus=4
alignment=1048576

img="steckos.img"


if [ -e ${img} ] ; then
	rm ${img}
fi

truncate -s $((size * (1<<20) )) "${img}"
parted --machine --script "${img}" mklabel msdos mkpart primary fat32 "${alignment}B" '100%' 
mformat -i "${img}"@@"${alignment}" -c $sectors_clus -F -t $((size>>20))  #-v "steckos"
mcopy -i "${img}"@@"${alignment}" -s dist/* ::/

