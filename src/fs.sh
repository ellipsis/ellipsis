#!/usr/bin/env bash
#
# fs.sh
# Files/path functions used by ellipis.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

# return true if folder is empty
fs.folder_empty() {
    if [ "$(find $1 -prune -empty)" ]; then
        return 0
    fi
    return 1
}

# check whether file exists
fs.file_exists() {
    if [[ -e "$1" ]]; then
        return 0
    fi
    return 1
}

# check whether file is a symlink
fs.is_symlink() {
    if [[ -L "$1" ]]; then
        return 0
    fi
    return 1
}

# Check whether symlink is broken
fs.is_broken_symlink() {
    if [[ -L "$1" && ! -e "$1" ]]; then
        return 0
    fi
    return 1
}

# List symlinks in a folder, defaulting to ELLIPSIS_HOME.
fs.list_symlinks() {
    find "${1:-$ELLIPSIS_HOME}" -maxdepth 1 -type l
}

# dunno how this isn't part of POSIX
fs.abs_path() {
    echo $(cd $(dirname "$1"); pwd)/$(basename "$1")
}

# return path to file relative to HOME (if possible)
fs.relative_path() {
    echo ${1/$HOME/\~}
}
