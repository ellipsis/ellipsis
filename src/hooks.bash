# hooks.bash
#
# Default hooks used by ellipsis when package hooks are undefined.

load fs
load git
load pkg
load utils

# Symlink files in PKG_PATH into ELLIPSIS_HOME.
hooks.install() {
    fs.link_files $PKG_PATH
}

# Remove package's symlinks in ELLIPSIS_HOME.
hooks.unlink() {
    for symlink in $(pkg.list_symlinks); do
        rm $symlink
    done
}

# Remove package's symlinks then remove package.
hooks.uninstall() {
    pkg.run_hook unlink
    rm -rf $PKG_PATH
}

# Show symlink mapping for package.
hooks.symlinks() {
    echo -e "\033[1m${1:-$PKG_NAME}\033[0m"

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
    local sha1=$(git.sha1)
    local last_updated=$(git.last_updated)

    echo -e "\033[1m${1:-$PKG_NAME}\033[0m\t$sha1\t(updated $last_updated)"
}

# Show git diffstat if repo has changed
hooks.status() {
    local ahead="$(git.ahead)"

    # Return unless there are changes or we are behind.
    ! git.has_changes && [ -z "$ahead" ] || return

    local sha1="$(git.sha1)"
    local last_updated=$(git.last_updated)

    echo -e "\033[1m${1:-$PKG_NAME}\033[0m $sha1 (updated $last_updated) $ahead"
    git.diffstat
}
