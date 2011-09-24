#!/bin/sh
# Script to automatically create dotfile symlinks

DOTDIR="$( cd -P "$( dirname "$0" )" && pwd )"

for DOTFILE in $DOTDIR/.*; do
    echo linking $(basename $DOTFILE)
    ln -s "$DOTFILE" ~/"$(basename $DOTFILE)"
done
