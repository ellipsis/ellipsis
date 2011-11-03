#!/bin/sh
# Script to automatically create dotfile symlinks

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

echo "list any additional external repos to install or enter to exit"
read EXTERNAL_REPOS

for REPO in $EXTERNAL_REPOS; do
    echo -n "install dot files from $REPO? (y/n) "
    read INPUT
    if [ "$INPUT" == "y" ]; then
        DEST=~/."$REPO"
        if [ -d "$BASEDIR/dot-$REPO" ]; then
            rm -rf $BASEDIR/dot-$REPO
        fi
        hg clone https://bitbucket.org/zeekay/dot-$REPO
        if [ "$1" == "-f" ]; then
            rm -rf "$DEST"
        fi
        echo linking $DEST
        ln -s $BASEDIR/dot-$REPO $DEST
        if [ -f "$DEST/setup.sh" ]; then
            . $DEST/setup.sh
        fi
    fi
done
