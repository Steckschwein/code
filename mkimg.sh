#!/bin/bash
size=128

img="steckos.img"

if [ -e $img ] ; then
    echo "Image $img already exists"
    exit 1
else
    echo "Creating image $img"
    dd if=/dev/zero of=$img bs=1024k count=$size
fi

printf 'o\nn\np\n1\n\n\nt\nc\nw\n' | fdisk $img
foo=$(sudo kpartx -av "$img")
if [ $? -ne 0 ] ; then
    exit 1
fi

loopdev="/dev/mapper/"$(echo $foo | cut -d ' ' -f3)
echo $loopdev
sudo mkfs -t fat -F 32 -s 16 -S 512 $loopdev
sudo mkdir image
sudo mount $loopdev image
sudo rsync -rv dist/ image/
sudo umount image
sudo kpartx -dv "$img"
sudo rm -fr image
