#!/bin/bash

list=${1:?}

for scwid in `cat $list`; do 
    echo "scw: $scwid"
    rev=${scwid:0:4}
    echo "rev: $rev"

    
done
