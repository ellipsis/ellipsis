#!/usr/bin/env bash
#
# hooks.sh
# Default hooks used by ellipsis when package hooks are undefined.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

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
    pkg.run_hook pkg.unlink
    rm -rf $PKG_PATH
}

# Show symlink mapping for package.
hooks.symlinks() {
    echo -e "\033[1m$PKG_NAME\033[0m"

    if utils.cmd_exists column; then
        pkg.symlinks_mappings | sort | column -t
    else
        pkg.symlinks_mappings | sort
    fi
}

# Do git pull from package
hooks.pull() {
    pkg.run git.pull
}

# Do git push from package
hooks.push() {
    pkg.run git.push
}

# List repo status.
hooks.list() {
    pkg.run git.list
}

# List repo status if it's changed and show git diffstat.
hooks.status() {
    pkg.run git.status
}
