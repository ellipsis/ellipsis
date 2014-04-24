#!/usr/bin/env bash
#
# package.sh
# Ellipsis package interface. Encapsulates various useful functions for working
# with packages.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

# List of hooks available to package authors.
PKG_HOOKS=(install uninstall symlinks pull push status list)

# Convert package name to path.
pkg.name_to_path() {
    echo "$HOME/.ellipsis/packages/$1"
}

# Convert package path to name.
pkg.path_to_name() {
    # basename
    local basename=${1##*/}
    # strip any leading dots
    echo ${basename##*/.}
}

# Initialize a package and it's hooks.
pkg.init() {
    local name_or_path="${1:-$PKG_PATH}"

    # we can be passed either a name or path, paths are assumed to be absolute,
    # and should have a slash in them.
    if utils.has_slash $name_or_path; then
        PKG_PATH="$name_or_path"
        PKG_NAME="$(pkg.path_to_name $PKG_PATH)"
    else
        PKG_NAME="$name_or_path"
        PKG_PATH="$(pkg.name_to_path $PKG_NAME)"
    fi

    # source ellipsis.sh if it exists to initialize package hooks
    if [ -f "$PKG_PATH/ellipsis.sh" ]; then
        source "$PKG_PATH/ellipsis.sh"
    fi
}

# Find package's symlinks.
pkg.find_symlinks() {
    echo -e "\033[1m$PKG_NAME symlinks\033[0m" | sed 's/\-e //'
    utils.find_symlinks | grep ellipsis/packages/$PKG_NAME
}

# Run hook or command inside $PKG_PATH.
pkg.run() {
    local cmd="$1"
    local cwd="$(pwd)"

    # change to package dir
    cd "$PKG_PATH"

    # run hook or command
    case $cmd in
        pkg.*)
            pkg.run_hook $cmd
            ;;
        *)
            $cmd
            ;;
    esac

    # return after running command
    cd "$cwd"
}

# run hook if it's defined, otherwise use default implementation
pkg.run_hook() {
    local hook=$1

    if utils.cmd_exists $hook; then
        $hook
    else
        case $hook in
            pkg.install)
                ellipsis.link_files $PKG_PATH
                ;;
            pkg.uninstall)
                for symlink in $(pkg.find_symlinks); do
                    rm $symlink
                done
                ;;
            pkg.symlinks)
                pkg.find_symlinks
                ;;
            pkg.pull)
                pkg.run git.pull
                ;;
            pkg.push)
                pkg.run git.push
                ;;
            pkg.list)
                pkg.run git.list
                ;;
            pkg.status)
                pkg.run git.status
                ;;
        esac
    fi
}

# clear globals, hooks
pkg.del() {
    pkg._unset_vars
    pkg._unset_hooks
}

# unset global packages
pkg._unset_vars() {
    unset PKG_NAME
    unset PKG_PATH
}

# unset any hooks that might have been defined by package
pkg._unset_hooks() {
    for hook in ${PKG_HOOKS[@]}; do
        unset -f pkg.$hook
    done
}
