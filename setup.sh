#!/bin/sh
# Script to automatically create dotfile symlinks

BASEDIR="$( cd -P "$( dirname "$0" )" && pwd )"

for DOTFILE in $BASEDIR/.*; do
    DOTNAME="$(basename $DOTFILE)"

    echo linking $DOTNAME
    # check if file exists and overwrite if -f passed
    [ "$1" == "-f" ] && [ -f ~/"$DOTNAME" ] && rm -rf ~/"$DOTNAME"
    ln -s "$DOTFILE" ~/"$DOTNAME"
done
