# path.bash
#
# Pathname functions used by ellipis.

# dunno how this isn't part of POSIX
path.abs_path() {
    echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
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
path.relative_to_home() {
    echo ${1/$HOME/\~}
}

# Expands '~', '$HOME' and '$ELLIPSIS_HOME' to $HOME or $ELLIPSIS_HOME" {
# Expand tilde to $HOME
path.expand() {
    local path="$1"
    path="${path/\~/$HOME}"
    path="${path/\$HOME/$HOME}"
    path="${path/\$ELLIPSIS_HOME/$ELLIPSIS_HOME}"

    echo "$path"
}

# Path relative to packages dir
path.relative_to_packages() {
    echo "${1/$ELLIPSIS_PACKAGES\//}"
}

# Strip dot from hidden file
path.strip_dot() {
    echo "$1" | sed -e "s/^\.//"
}
