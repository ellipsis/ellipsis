#!/usr/bin/env bash
#
# ellipsis utility functions

# cross-platform xargs which ignores empty stdin (on linux)
# utils.xargs() {
#     case $(ellipsis.platform) in
#         linux)
#             cat - | xargs --no-run-if-empty $@
#             ;;
#         *)
#             cat - | xargs $@
#             ;;
#     esac
# }

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

# find symlinks in $HOME
utils.find_symlinks() {
    case $(ellipsis.platform) in
        linux|cygwin*)
            for symlink in $(find ${1:-$HOME} -maxdepth 1 -type l | xargs -I{} readlink '{}'); do
                utils.relative_path $symlink
            done
            ;;
        *)
            for symlink in $(find ${1:-$HOME} -maxdepth 1 -type l | xargs readlink); do
                utils.relative_path $symlink
            done
        ;;
    esac
}

# dunno how this isn't part of POSIX
utils.abs_path() {
    echo $(cd $(dirname $1); pwd)/$(basename $1)
}

# return path to file relative to $HOME (if possible)
utils.relative_path() {
    echo ${1/$HOME/\~}
}

utils.strip_leading_dot() {
    echo "${1#.}"
}

# detects slash in string
utils.has_slash() {
    case $1 in
        */*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
