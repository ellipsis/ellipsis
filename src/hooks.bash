# hooks.bash
#
# Default hooks used by ellipsis when package hooks are undefined.

load fs
load git
load os
load path
load pkg
load utils
load msg
load log

# List of hooks available to package authors.
PKG_HOOKS=(
    add
    install
    installed
    link
    links
    pull
    push
    status
    uninstall
    unlink
)

# Symlink files in PKG_PATH into ELLIPSIS_HOME.
hooks.add() {
    local dst="$PKG_PATH/$(path.strip_dot "$(basename "$1")")"

    if fs.file_exists "$dst"; then
        log.fail "$dst already exists!"
        exit 1
    fi

    if ! fs.file_exists "$1"; then
        log.fail "$1 does not exist!"
        exit 1
    fi

    msg.print "mv $(path.relative_to_home "$1") $(path.relative_to_packages "$dst")"
    mv "$1" "$dst"

    fs.link_file "$dst"
}

# Symlink files in PKG_PATH into ELLIPSIS_HOME.
hooks.link() {
    fs.link_files "$PKG_PATH"
}

# Dummy, by default only symlinks are made.
hooks.install() {
    :
}

# Remove package's symlinks in ELLIPSIS_HOME.
hooks.unlink() {
    for symlink in $(pkg.list_symlinks); do
        rm "$symlink"
    done
}

# Dummy, by default only removing symlinks and package
hooks.uninstall() {
    :
}

# Show symlink mapping for package.
hooks.links() {
    msg.bold "${1:-$PKG_NAME}"

    if utils.cmd_exists column; then
        pkg.list_symlink_mappings | sort | column -t
    else
        pkg.list_symlink_mappings | sort
    fi
}

# Do git pull from package
hooks.pull() {
    git.pull
}

# Do git push from package
hooks.push() {
    git.push
}

# List repo status.
hooks.installed() {
    local sha1="$(git.sha1)"
    local last_updated="$(git.last_updated)"

    msg.print "\033[1m${1:-$PKG_NAME}\033[0m\t$sha1\t(updated $last_updated)"
}

# Show git diffstat if repo has changed
hooks.status() {
    local ahead="$(git.ahead)"

    # Return unless there are changes or we are behind.
    git.has_changes || [ "$ahead" ] || return

    local sha1="$(git.sha1)"
    local last_updated="$(git.last_updated)"

    msg.print "\033[1m${1:-$PKG_NAME}\033[0m $sha1 (updated $last_updated) $ahead"
    git.diffstat
}
