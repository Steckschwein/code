#!/bin/bash
# 
# xpm output from iconmaker
#
if [ ! -e "$1" ]; then
	echo "nicht so!, datei '$1' not found!"
	exit -1;
fi
colors=`head -3 $1 | tail -1 | cut -d ' ' -f3`
offset=`expr "$colors" + 4`
#echo $colors
tail -n+$offset $1 | cut -b 1-9   | tr '!#$ "' '1100 ' | sed "s/^ /.byte %/g" 
#tail -n+$offset $1 | cut -b 10-17 | tr '#$ "' '100 ' | sed "s/^/.byte %/g" 
if [ "$colors" -eq 4 ]; then
	tail -n+$offset $1 | cut -b 1-9   | tr '#$ "' '010 ' | sed "s/^ /.byte %/g"
#	tail -n+$offset $1 | cut -b 10-17 | tr '#$ "' '010 ' | sed "s/^/.byte %/g"
fi