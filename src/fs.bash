# fs.bash
#
# Files/path functions used by ellipis.

load path

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

# check whether file is a symlink
fs.is_ellipsis_symlink() {
    if [[ -L "$1" && "$(readlink $1)" == $ELLIPSIS_PATH/* ]]; then
        echo symlink
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

# backup existing file, ensuring you don't overwrite existing backups
fs.backup() {
    local original="$1"
    local backup="$original.bak"
    local name="${original##*/}"

    # remove broken symlink
    if fs.is_broken_symlink "$original"; then
        echo "rm ~/$name (broken link to $(readlink $original))"
        rm $original
        return
    fi

    # no file exists, simply ignore
    if ! fs.file_exists "$original"; then
        return
    fi

    # if file exists and is a symlink to ellipsis, remove
    if fs.is_elipsis_symlink "$original"; then
        rm "$original"
        return
    fi

    # backup file
    if fs.file_exists "$backup"; then
        n=1
        while fs.file_exists "$backup.$n"; do
            n=$((n+1))
        done
        backup="$backup.$n"
    fi

    echo "mv ~/$name $backup"
    mv "$original" "$backup"
}

# symlink a single file into ELLIPSIS_HOME
fs.link_file() {
    local src="$(path.abs_path $1)"
    local name="${src##*/}"
    local dest="${2:-$ELLIPSIS_HOME}/.$name"

    fs.backup "$dest"

    echo linking "$dest"
    ln -s "$src" "$dest"
}

# find all files in dir excluding the dir itself, hidden files, README,
# LICENSE, *.rst, *.md, and *.txt and symlink into ELLIPSIS_HOME.
fs.link_files() {
    for file in $(find "$1" -maxdepth 1 -name '*' \
                                      ! -name '.*' \
                                      ! -name 'README' \
                                      ! -name 'LICENSE' \
                                      ! -name '*.md' \
                                      ! -name '*.rst' \
                                      ! -name '*.txt' \
                                      ! -wholename "$1" \
                                      ! -name "ellipsis.sh" | sort); do
        fs.link_file "$file"
    done
}
