#!/bin/sh

basedir="$( cd -P "$( dirname "$0" )" && pwd )"

cd $basedir
hg push

for dir in dot*; do
    dir=$basedir/$dir
    if [ -d "$dir" ] && [ -f "$dir/.hg/hgrc" ]; then
        cd $dir
        hg push
    fi
done
