# hooks.bash
#
# Default hooks used by ellipsis when package hooks are undefined.

load fs
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
    echo -e "\033[1m$PKG_NAME\033[0m"

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
hooks.list() {
    git.list
}

# List repo status if it's changed and show git diffstat.
hooks.status() {
    git.status
}
