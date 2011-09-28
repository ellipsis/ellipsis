#!/bin/sh
# Script to automatically setup dotfile

BASEDIR="$( cd -P "$( dirname "$0" )" && pwd )"

for DOTFILE in $BASEDIR/dot.*; do
    NAME="$(basename $DOTFILE)"
    DOTNAME="${NAME:3}"
    DEST=~/"$DOTNAME"

    # erasing existing dotfiles
    if [ "$1" == "-f" ]; then
        rm -rf "$DEST"
    fi

    echo linking $DOTNAME
    ln -s "$DOTFILE" "$DEST"
done
