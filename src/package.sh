#!/usr/bin/env bash
#
# ellipsis.sh
# Ellipsis package interface. Encapsulates various useful functions for working
# with packages.

# Source globals if they haven't been yet
if [[ $ELLIPSIS_GLOBALS -ne 1 ]]; then
    source $(dirname "${BASH_SOURCE[0]}")/globals.sh
fi

# List of hooks available to package authors.
pkg_hooks=(install uninstall symlinks pull push status list)

# Convert package name to path.
pkg.name_to_path() {
    echo "$HOME/.ellipsis/packages/$1"
}

# Convert package path to name.
pkg.path_to_name() {
    echo ${1##*/.}
}

# Initialize a package and it's hooks.
pkg.init() {
    local name_or_path="$1"

    # we can be passed either a name or path, paths are assumed to be absolute,
    # and should have a slash in them.
    if utils.has_slash $name_or_path; then
        pkg_path="$name_or_path"
        pkg_name="$(pkg.path_to_name $pkg_path)"
    else
        pkg_name="$name_or_path"
        pkg_path="$(pkg.name_to_path $pkg_name)"
    fi

    # source ellipsis.sh if it exists to initialize package hooks
    if [ -f "$pkg_path/ellipsis.sh" ]; then
        source "$pkg_path/ellipsis.sh"
    fi
}

# Find package's symlinks.
pkg.find_symlinks() {
    local pkg_name=${1:-$pkg_name}

    echo -e "\033[1m$pkg_name symlinks\033[0m" | sed 's/\-e //'
    utils.find_symlinks | grep ellipsis/packages/$pkg_name
}

# Run hook or command inside $pkg_path.
pkg.run() {
    local cmd="$1"
    local cwd="$(pwd)"

    # change to package dir
    cd "$pkg_path"

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
                ellipsis.link_files $pkg_path
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
    unset pkg_name
    unset pkg_path
}

# unset any hooks that might have been defined by package
pkg._unset_hooks() {
    for hook in ${pkg_hooks[@]}; do
        unset -f pkg.$hook
    done
}
