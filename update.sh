#!/bin/sh

BASEDIR="$( cd -P "$( dirname "$0" )" && pwd )"

cd $BASEDIR
hg pull && hg up

for DIR in dot*; do
    DIR=$BASEDIR/$DIR
    if [ -d "$DIR" ] && [ -f "$DIR/.hg/hgrc" ]; then
        cd $DIR
        hg pull && hg up
    fi
done
