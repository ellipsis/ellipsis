# fs.bash
#
# Files/path functions used by ellipis.

load msg
load path

# return true if folder is empty
fs.folder_empty() {
    local files=($(shopt -s nullglob; shopt -s dotglob; echo "$1"/*))
    if [ ${#files[@]} -gt 0 ]; then
        return 1
    fi
    return 0
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
    if [[ -L "$1" && "$(readlink "$1")" == $ELLIPSIS_PATH/* ]]; then
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

# List broken symlinks in a folder, defaulting to ELLIPSIS_HOME.
fs.list_broken_symlinks() {
    find "${1:-$ELLIPSIS_HOME}" -maxdepth 1 -type l -exec test ! -e {} \; -print
}

# List symlinks in a folder, defaulting to ELLIPSIS_HOME.
fs.list_symlinks() {
    find "${1:-$ELLIPSIS_HOME}" -maxdepth 1 -type l
}

fs.list_dirs() {
    dir="${1:-.}"
    find "$dir" -maxdepth 1 ! -path "$dir" -type d
}

# backup existing file, ensuring you don't overwrite existing backups
fs.backup() {
    local original="$1"
    local backup="$original.bak"
    local name="${original##*/}"

    # remove broken symlink
    if fs.is_broken_symlink "$original"; then
        msg.dim "rm ~/$name (broken link to $(readlink "$original"))"
        rm "$original"
        return
    fi

    # no file exists, simply ignore
    if ! fs.file_exists "$original"; then
        return
    fi

    # if file exists and is a symlink to ellipsis, remove
    if fs.is_ellipsis_symlink "$original"; then
        msg.dim "rm ~/$name (linked to $(path.relative_to_packages "$(readlink "$original")"))"
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

    msg.print "mv ~/$name $backup"
    mv "$original" "$backup"
}

# symlink a single (regular) file into ELLIPSIS_HOME
fs.link_rfile() {
    local src="$(path.abs_path "$1")"
    local name="${src##*/}"
    local default="$ELLIPSIS_HOME/$name"
    local dest="${2:-$default}"

    fs.backup "$dest"

    msg.print "linking $(path.relative_to_packages "$src") -> $(path.relative_to_home "$dest")"
    ln -s "$src" "$dest"
}

# symlink a single file into ELLIPSIS_HOME
fs.link_file() {
    local name="${1##*/}"
          name="${name#.}"
    local default="$ELLIPSIS_HOME/.$name"
    local dest="${2:-$default}"
    fs.link_rfile "$1" "$dest"
}

# find all files in dir excluding the dir itself, hidden files, README,
# LICENSE, *.rst, *.md, and *.txt and symlink into ELLIPSIS_HOME.
fs.link_files() {
    local src_dir="${1:-.}"
    local dest_dir="${2:-$ELLIPSIS_HOME}"

    fs.link_rfiles "$src_dir" "$dest_dir" '.'
}

# find all files in dir excluding the dir itself, hidden files, README,
# LICENSE, *.rst, *.md, and *.txt and symlink into ELLIPSIS_HOME.
fs.link_rfiles() {
    local src_dir="${1:-.}"
    local dest_dir="${2:-$ELLIPSIS_HOME}"
    local prefix="$3"

    for file in $(find "$1" -maxdepth 1 -name '*' \
                                      ! -name '.*' \
                                      ! -name 'README' \
                                      ! -name 'LICENSE' \
                                      ! -name '*.md' \
                                      ! -name '*.rst' \
                                      ! -name '*.txt' \
                                      ! -name "ellipsis.sh" | sort); do
        if [ ! "$1" = "$file" ]; then
            local src="$(path.abs_path "$file")"
            local name="${src##*/}"
            local dest="${dest_dir}/${prefix}${name}"
            fs.link_rfile "$file" "$dest"
        fi
    done
}

fs.strip_dot() {
    dir="${1:-.}"
    for file in $(find "$dir" -maxdepth 1 ! -path "$dir" -name '.*'); do
        base="$(basename "$file")"
        stripped="${base/./}"
        mv "$file" "$dir/$stripped"
    done
}

# Echo first file found
fs.first_found() {
    for file in "$@"; do
        if [ -f "$file" ]; then
            echo "$file"
            return 0
        fi
    done
    return 1
}
