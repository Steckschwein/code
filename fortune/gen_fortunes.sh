#!/bin/bash

for i in {0..255} ; do
    echo fortune$i:
    fortune -s | sed -e "s/\t//g" -e "s/\"//g" -e "s/$/\",\$0a/g" -e  "s/^/.byte \"/g"
    echo ".byte \$0a, 0"
done
