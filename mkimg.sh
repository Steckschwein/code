#!/bin/bash
size=7831152
size=1048576

img="steckos.img"

if [ -e $img ] ; then
    echo "Image $img already exists"
else
    echo "Creating image $img"
    dd if=/dev/zero of=$img bs=512 count=$size
fi

printf 'o\nn\np\n1\n\n\nt\nc\nw\n' | fdisk $img
foo=$(sudo kpartx -av "$img")
if [ $? -ne 0 ] ; then
    exit 1
fi

loopdev="/dev/mapper/"$(echo $foo | cut -d ' ' -f3)
echo $loopdev
sudo mkfs -t vfat -s 64 $loopdev
mkdir image
sudo mount $loopdev image
sudo rsync -rv dist/ image/
sudo umount image
sudo kpartx -dv "$img"
rmdir image



