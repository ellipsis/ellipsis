#!/usr/bin/env bash
#
# ellipsis utility functions

# check if a command or function exists
utils.cmd_exists() {
    if hash $1 2>/dev/null; then
        return 0
    fi
    return 1
}

# return true if folder is empty
utils.folder_empty() {
    if [ $(find $1 -prune -empty) ]; then
        return 0
    fi
    return 1
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
