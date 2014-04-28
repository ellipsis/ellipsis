#!/usr/bin/env bash
#
# utils.sh
# Utility functions used by ellipsis.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

# check if a command or function exists
utils.cmd_exists() {
    hash "$1" &> /dev/null
}

# prompt with message and return true if yes/YES, otherwise false
utils.prompt() {
    read -r -p "$1 " answer
    case $answer in
        y*|Y*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# return path to file in packages dir
utils.strip_packages_dir() {
    echo ${1/$ELLIPSIS_PATH\/packages\//}
}

# detects slash in string
utils.has_slash() {
    case "$1" in
        */*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
