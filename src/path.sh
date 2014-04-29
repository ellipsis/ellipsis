#!/usr/bin/env bash
#
# path.sh
# Pathname functions used by ellipis.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

# dunno how this isn't part of POSIX
path.abs_path() {
    echo $(cd $(dirname "$1"); pwd)/$(basename "$1")
}

# Tries to determine if string is a path.
path.is_path() {
    case "$1" in
        */*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# return path to file relative to HOME (if possible)
path.relative_path() {
    echo ${1/$HOME/\~}
}

# Path relative to packagesreturn path to file in packages dir
path.relative_packages_path() {
    echo ${1/$ELLIPSIS_PATH\/packages\//}
}

# Convert package name to path.
path.pkg_path_from_name() {
    echo "$ELLIPSIS_PATH/packages/$1"
}

# Convert package path to name, stripping any leading dots.
path.pkg_name_from_path() {
    echo ${1##*/} | sed -e "s/^\.//"
}
